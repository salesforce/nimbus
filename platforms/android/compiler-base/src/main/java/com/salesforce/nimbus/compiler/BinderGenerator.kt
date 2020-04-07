package com.salesforce.nimbus.compiler

import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.PluginOptions
import com.squareup.kotlinpoet.ClassName
import com.squareup.kotlinpoet.CodeBlock
import com.squareup.kotlinpoet.FileSpec
import com.squareup.kotlinpoet.FunSpec
import com.squareup.kotlinpoet.KModifier
import com.squareup.kotlinpoet.LambdaTypeName
import com.squareup.kotlinpoet.ParameterizedTypeName
import com.squareup.kotlinpoet.ParameterizedTypeName.Companion.parameterizedBy
import com.squareup.kotlinpoet.PropertySpec
import com.squareup.kotlinpoet.TypeSpec
import com.squareup.kotlinpoet.asClassName
import com.squareup.kotlinpoet.asTypeName
import kotlinx.metadata.KmFunction
import kotlinx.metadata.KmType
import kotlinx.metadata.KmValueParameter
import kotlinx.metadata.jvm.KotlinClassHeader
import kotlinx.metadata.jvm.KotlinClassMetadata
import javax.annotation.processing.AbstractProcessor
import javax.annotation.processing.Messager
import javax.annotation.processing.ProcessingEnvironment
import javax.annotation.processing.RoundEnvironment
import javax.lang.model.SourceVersion
import javax.lang.model.element.Element
import javax.lang.model.element.ElementKind
import javax.lang.model.element.ExecutableElement
import javax.lang.model.element.TypeElement
import javax.lang.model.element.VariableElement
import javax.lang.model.type.DeclaredType
import javax.lang.model.type.TypeKind
import javax.lang.model.type.WildcardType
import javax.lang.model.util.Types
import javax.tools.Diagnostic

const val nimbusPackage = "com.salesforce.nimbus"

/**
 * Base class to generate plugin Binder classes from classes which are annotated with [PluginOptions]
 */
abstract class BinderGenerator : AbstractProcessor() {

    private lateinit var messager: Messager
    private lateinit var types: Types

    /**
     * The [ClassName] of the javascript engine that the Binder class will target
     */
    abstract val javascriptEngine: ClassName

    /**
     * The [ClassName] of the annotation for which each bound method will be annotated with
     */
    abstract val functionAnnotationClassName: ClassName?

    override fun init(processingEnvironment: ProcessingEnvironment) {
        super.init(processingEnvironment)
        messager = processingEnvironment.messager
        types = processingEnvironment.typeUtils
    }

    override fun process(
        annotations: MutableSet<out TypeElement>?,
        env: RoundEnvironment
    ): Boolean {
        try {

            // get all plugins
            val pluginElements = env.getElementsAnnotatedWith(PluginOptions::class.java)

            // find any duplicate plugin names
            val duplicates =
                pluginElements.groupingBy { it.getAnnotation(PluginOptions::class.java).name }
                    .eachCount().filterValues { it > 1 }.keys

            // if we have any duplicate plugin names then give an error
            if (duplicates.isNotEmpty()) {
                val name = duplicates.first()
                error(
                    pluginElements.first { it.getAnnotation(PluginOptions::class.java).name == name },
                    "A ${PluginOptions::class.java.simpleName} with name $name already exists."
                )
            } else {

                // loop through each plugin to create a binder class for it
                pluginElements.forEach { pluginElement ->

                    // make sure it implements `Plugin`
                    if (types.directSupertypes(pluginElement.asType()).map { it.toString() }.none { it == "$nimbusPackage.Plugin" }) {
                        error(
                            pluginElement,
                            "${PluginOptions::class.java.simpleName} class must extend $nimbusPackage.Plugin."
                        )
                    } else {

                        // process each plugin element to create a type spec
                        val typeSpec = processPluginElement(pluginElement)

                        // create the binder class for the plugin
                        FileSpec.builder(
                            processingEnv.elementUtils.getPackageOf(pluginElement).qualifiedName.toString(),
                            typeSpec.name!!
                        )
                            .addType(typeSpec)
                            .indent("    ")
                            .build()
                            .writeTo(processingEnv.filer)
                    }
                }
            }
        } catch (e: Exception) {
            messager.printMessage(Diagnostic.Kind.ERROR, e.message)
        }

        return true
    }

    override fun getSupportedAnnotationTypes(): MutableSet<String> {
        return mutableSetOf(
            BoundMethod::class.java.canonicalName,
            PluginOptions::class.java.canonicalName
        )
    }

    override fun getSupportedSourceVersion(): SourceVersion {
        return SourceVersion.latestSupported()
    }

    private fun processPluginElement(pluginElement: Element): TypeSpec {

        // the binder class name will be <PluginClass><JavascriptEngine>Binder, such as DeviceInfoPluginWebViewBinder
        val binderTypeName = "${pluginElement.getName()}${javascriptEngine.simpleName}Binder"
        val pluginName = pluginElement.getAnnotation(PluginOptions::class.java).name
        val pluginTypeName = pluginElement.asKotlinType()

        // read kotlin metadata so we can determine which types are nullable
        val kotlinClass =
            pluginElement.getAnnotation(Metadata::class.java)?.let { metadata ->
                (KotlinClassMetadata.read(
                    KotlinClassHeader(
                        metadata.kind,
                        metadata.metadataVersion,
                        metadata.bytecodeVersion,
                        metadata.data1,
                        metadata.data2,
                        metadata.extraString,
                        metadata.packageName,
                        metadata.extraInt
                    )
                ) as KotlinClassMetadata.Class).toKmClass()
            }

        val stringClassName = String::class.asClassName()
        val runtimeClassName =
            ClassName(nimbusPackage, "Runtime").parameterizedBy(javascriptEngine)

        // the binder needs to capture the bound target to pass through calls to it
        val type = TypeSpec.classBuilder(binderTypeName)

            // the Binder implements Binder<JavascriptEngine>
            .addSuperinterface(
                ClassName(nimbusPackage, "Binder").parameterizedBy(javascriptEngine)
            )
            .addModifiers(KModifier.PUBLIC)

            // add the <PluginClass> as a constructor property
            .primaryConstructor(
                FunSpec.constructorBuilder()
                    .addParameter("target", pluginTypeName)
                    .build()
            )

            // create the <PluginClass> property initializer
            .addProperty(
                PropertySpec.builder(
                    "target",
                    pluginTypeName,
                    KModifier.FINAL,
                    KModifier.PRIVATE
                )
                    .initializer("target")
                    .build()
            )

            // add the Runtime property
            .addProperty(
                PropertySpec.builder(
                    "runtime",
                    runtimeClassName.copy(nullable = true),
                    KModifier.PRIVATE
                )
                    .mutable()
                    .initializer("null")
                    .build()
            )

            // add the property to hold the plugin name
            .addProperty(
                PropertySpec.builder(
                    "pluginName",
                    stringClassName,
                    KModifier.FINAL,
                    KModifier.PRIVATE
                )
                    .initializer("\"$pluginName\"")
                    .build()
            )

            // add a getter for the plugin (implement Binder.getPlugin())
            .addFunction(
                FunSpec.builder("getPlugin")
                    .addModifiers(KModifier.OVERRIDE)
                    .returns(ClassName(nimbusPackage, "Plugin"))
                    .addStatement("return target")
                    .build()
            )

            // add a getter for the plugin name (implement Binder.getPluginName())
            .addFunction(
                FunSpec.builder("getPluginName")
                    .addModifiers(KModifier.OVERRIDE)
                    .returns(stringClassName)
                    .addStatement("return pluginName")
                    .build()
            )

            // add the bind function to bind the Runtime
            // (implement Binder.bind(Runtime<JavascriptEngine>))
            .addFunction(
                FunSpec.builder("bind")
                    .addModifiers(KModifier.OVERRIDE)
                    .addParameter("runtime", runtimeClassName)
                    .addStatement("this.%N = %N", "runtime", "runtime")
                    .build()
            )

            // add the unbind function to unbind the runtime
            // (implement Binder.unbind(Runtime<JavascriptEngine>))
            .addFunction(
                FunSpec.builder("unbind")
                    .addModifiers(KModifier.OVERRIDE)
                    .addParameter("runtime", runtimeClassName)
                    .addStatement("this.%N = null", "runtime")
                    .build()
            )

        // get all methods annotated with BoundMethod
        val boundMethodElements = pluginElement.enclosedElements.filter {
            it.kind == ElementKind.METHOD && it.getAnnotation(BoundMethod::class.java) != null
        }

        // loop through each bound function to generate a binder function
        boundMethodElements
            .map { it as ExecutableElement }

            // process the function to create a FunSpec
            .map { functionElement ->
                processFunctionElement(
                    functionElement,
                    kotlinClass?.functions?.find { it.name == functionElement.getName() }
                )
            }

            // add each FunSpec to the TypeSpec
            .forEach { funSpec -> type.addFunction(funSpec) }

        return type.build()
    }

    private fun processFunctionElement(
        functionElement: ExecutableElement,
        kotlinFunction: KmFunction?
    ): FunSpec {
        val functionName = functionElement.simpleName.toString()

        // try to find the fun from the kotlin class metadata to see if the
        // return type is nullable
        val kotlinReturnType = kotlinFunction?.returnType

        // create the binder function
        val funSpec = FunSpec.builder(functionName).apply {

            // annotate the function if necessary
            functionAnnotationClassName?.let { annotationClassName ->
                addAnnotation(annotationClassName)
            }
        }

        val funArgs = mutableListOf<String>()
        functionElement.parameters.forEachIndexed { argIndex, parameter ->

            // try to get the value parameter from the kotlin class metadata
            // to determine if it is nullable
            val kotlinParameter = kotlinFunction?.valueParameters?.get(argIndex)

            // check if param needs conversion
            when (parameter.asType().kind) {
                TypeKind.BOOLEAN,
                TypeKind.INT,
                TypeKind.DOUBLE,
                TypeKind.FLOAT,
                TypeKind.LONG -> {
                    processPrimitiveParameter(parameter, kotlinParameter, funSpec)
                }
                TypeKind.DECLARED -> {
                    val declaredType = parameter.asType() as DeclaredType
                    val parameterType = declaredType.toString()

                    when {

                        // map a java or kotlin string to a kotlin string
                        parameterType in listOf("java.lang.String", "kotlin.String") -> {
                            processStringParameter(parameter, kotlinParameter, funSpec)
                        }
                        parameterType.startsWith("kotlin.jvm.functions.Function") -> {
                            val functionParameterReturnType = declaredType.typeArguments.last()

                            // throw a compiler error if the callback does not return void
                            if ((functionParameterReturnType.asKotlinTypeName() as ClassName).simpleName != "Unit") {
                                error(
                                    functionElement,
                                    "Only a Unit (Void) return type in callbacks is supported."
                                )
                            } else {
                                processFunctionParameter(
                                    declaredType,
                                    parameter,
                                    kotlinParameter,
                                    funSpec
                                )
                            }
                        }
                        parameterType.startsWith("java.util.ArrayList") -> {
                            processArrayListParameter(
                                declaredType,
                                parameter,
                                kotlinParameter,
                                funSpec
                            )
                        }
                        parameterType.startsWith("java.util.HashMap") -> {
                            processHashMapParameter(
                                declaredType,
                                parameter,
                                kotlinParameter,
                                funSpec
                            )
                        }
                        else -> {
                            processOtherDeclaredParameter(
                                declaredType,
                                parameter,
                                kotlinParameter,
                                funSpec
                            )
                        }
                    }
                }

                // unsupported kind
                else -> {
                    error(
                        functionElement,
                        "${parameter.asKotlinType().toString()} is an unsupported parameter type."
                    )
                }
            }

            // add parameter to list of function args for later
            funArgs.add(parameter.getName())
        }

        // JSON Encode the return value if necessary
        val argsString = funArgs.joinToString(", ")
        val returnType = functionElement.returnType
        when (returnType.kind) {
            TypeKind.VOID -> {
                processVoidReturnType(functionElement, argsString, kotlinReturnType, funSpec)
            }
            TypeKind.DECLARED -> {
                when {
                    returnType.toString() in listOf("java.lang.String", "kotlin.String") -> {
                        processStringReturnType(
                            functionElement,
                            argsString,
                            kotlinReturnType,
                            funSpec
                        )
                    }
                    else -> {
                        processOtherDeclaredReturnType(
                            functionElement,
                            argsString,
                            kotlinReturnType,
                            funSpec
                        )
                    }
                }
            }
            else -> {
                // TODO: we should whitelist types we know work rather than just hoping for the best
                funSpec.addStatement(
                    "return target.%N($argsString)",
                    functionElement.simpleName.toString()
                )
            }
        }

        return funSpec.build()
    }

    protected open fun processPrimitiveParameter(
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        funSpec: FunSpec.Builder
    ) {
        funSpec.addParameter(
            parameter.getName(),
            parameter.asKotlinType(nullable = kotlinParameter.isNullable())
        )
    }

    protected open fun processStringParameter(
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        funSpec: FunSpec.Builder
    ) {
        funSpec.addParameter(
            parameter.getName(),
            String::class.asClassName().copy(nullable = kotlinParameter.isNullable())
        )
    }

    protected open fun processFunctionParameter(
        declaredType: DeclaredType,
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        funSpec: FunSpec.Builder
    ) {

        // try to get the parameter type from the kotlin class
        // metadata to determine if it is nullable
        val kotlinParameterType = kotlinParameter?.type

        // add a String parameter <parameter>Id
        funSpec.addParameter(
            "${parameter.getName()}Id",
            String::class
        )

        // create the callback function body
        val invoke = CodeBlock.builder()
        val argBlock = CodeBlock.builder()
            .add(
                "val args = arrayOf<%T>(\n",
                ClassName(
                    nimbusPackage,
                    "JSONSerializable"
                ).nullable(true)
            )
            .indent()
            .add(
                "%T(%NId),\n",
                ClassName(
                    nimbusPackage,
                    "PrimitiveJSONSerializable"
                ),
                parameter.simpleName
            )

        // loop through each argument (except for last)
        // and add to the array created above
        declaredType.typeArguments.dropLast(1).forEachIndexed { index, typeMirror ->

            // try to get the type from the kotlin class metadata
            // to determine if it is nullable
            val kotlinType = kotlinParameterType?.arguments?.get(index)
            val kotlinTypeNullable = kotlinType.isNullable()

            // function to wrap a value in a PrimitiveJSONSerializable if needed
            val wrapValueInPrimitiveJSONSerializable = {
                argBlock.add(
                    if (kotlinTypeNullable) {
                        "arg$index?.let { %T(arg$index) }"
                    } else {
                        "%T(arg$index)"
                    },
                    ClassName(
                        nimbusPackage,
                        "PrimitiveJSONSerializable"
                    )
                )
            }

            if (typeMirror.kind == TypeKind.WILDCARD) {
                val wild = typeMirror as WildcardType
                val supertypes =
                    processingEnv.typeUtils.directSupertypes(
                        wild.superBound
                    )

                // if the parameter implements JSONSerializable we are good
                if (supertypes.any { it.toString() == "$nimbusPackage.JSONSerializable" }) {
                    argBlock.add("arg$index")
                } else {

                    // if it does not then we nee to wrap it in a PrimitiveJSONSerializable
                    wrapValueInPrimitiveJSONSerializable()
                }
            } else {
                wrapValueInPrimitiveJSONSerializable()
            }

            // add another element to the array
            if (index < declaredType.typeArguments.size - 2) {
                argBlock.add(",")
            }

            argBlock.add("\n")
        }

        // finish (close) the array
        argBlock.unindent().add(")\n")

        // add the arg block to the invoke function
        invoke.add(argBlock.build())

        // add a statement to invoke runtime
        invoke.add(
            CodeBlock.builder()
                .addStatement(
                    "runtime?.invoke(%S, %N, null)",
                    "__nimbus.callCallback",
                    "args"
                )
                .build()
        )

        // get the type args for the lambda function
        val lambdaTypeArgs =
            declaredType.typeArguments.mapIndexed { index, type ->
                val kotlinType = kotlinParameterType?.arguments?.get(index)
                val typeIsNullable = kotlinType.isNullable()
                if (type.kind == TypeKind.WILDCARD) {
                    val wild = type as WildcardType
                    wild.superBound.asKotlinTypeName(nullable = typeIsNullable)
                } else {
                    type.asKotlinTypeName(nullable = typeIsNullable)
                }
            }

        val lambdaType = LambdaTypeName.get(
            null,
            parameters = *lambdaTypeArgs.dropLast(1).toTypedArray(),
            returnType = lambdaTypeArgs.last()
        )
        val lambda = CodeBlock.builder()
            .add(
                "val %N: %T = { ${declaredType.typeArguments.dropLast(
                    1
                ).mapIndexed { index, _ -> "arg$index" }.joinToString(
                    separator = ", "
                )} ->",
                parameter.simpleName,
                lambdaType
            )
            .add("\n")
            .indent()
            .add("%L", invoke.build())
            .unindent()
            .add("}")
            .add("\n")

        funSpec.addCode(lambda.build())
    }

    protected open fun processArrayListParameter(
        declaredType: DeclaredType,
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        funSpec: FunSpec.Builder
    ) {
        val parameterNullable = kotlinParameter?.type?.arguments?.firstOrNull().isNullable()
        funSpec.addParameter(
            parameter.simpleName.toString() + "String",
            String::class
        )
        funSpec.addStatement(
            "val %N = %T<%T>(%NString)",
            parameter.simpleName,
            ClassName(nimbusPackage, "arrayFromJSON"),
            declaredType.typeArguments.first().asKotlinTypeName(nullable = parameterNullable),
            parameter.simpleName
        )
    }

    protected open fun processHashMapParameter(
        declaredType: DeclaredType,
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        funSpec: FunSpec.Builder
    ) {
        val firstParameterNullable = kotlinParameter?.type?.arguments?.get(0).isNullable()
        val secondParameterNullable = kotlinParameter?.type?.arguments?.get(1).isNullable()
        funSpec.addParameter(
            parameter.simpleName.toString() + "String",
            String::class
        )
        funSpec.addStatement(
            "val %N = %T<%T, %T>(%NString)",
            parameter.simpleName,
            ClassName(nimbusPackage, "hashMapFromJSON"),
            declaredType.typeArguments[0].asKotlinTypeName(nullable = firstParameterNullable),
            declaredType.typeArguments[1].asKotlinTypeName(nullable = secondParameterNullable),
            parameter.simpleName
        )
    }

    protected open fun processOtherDeclaredParameter(
        declaredType: DeclaredType,
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        funSpec: FunSpec.Builder
    ) {

        // TODO: we also want to support kotlinx.serializable eventually

        // The Binder will fail to compile if a static `fromJSON` method is not found.
        // Probably want to emit an error from the annotation processor to fail faster.
        funSpec.addParameter(
            "${parameter.getName()}String",
            String::class
        )
        funSpec.addStatement(
            "val %N = %T.fromJSON(%NString)",
            parameter.simpleName,
            parameter.asKotlinType(),
            parameter.simpleName
        )
    }

    protected open fun processVoidReturnType(
        functionElement: ExecutableElement,
        argsString: String,
        kotlinReturnType: KmType?,
        funSpec: FunSpec.Builder
    ) {
        funSpec.apply {
            addStatement(
                "target.%N($argsString)",
                functionElement.simpleName.toString()
            )
            returns(functionElement.returnType.asKotlinTypeName(nullable = kotlinReturnType.isNullable()))
        }
    }

    protected open fun processStringReturnType(
        functionElement: ExecutableElement,
        argsString: String,
        kotlinReturnType: KmType?,
        funSpec: FunSpec.Builder
    ) {
        funSpec.apply {
            addStatement(
                "return %T.quote(target.%N($argsString))",
                ClassName("org.json", "JSONObject"),
                functionElement.simpleName.toString()
            )
            returns(functionElement.returnType.asKotlinTypeName(nullable = kotlinReturnType.isNullable()))
        }
    }

    protected open fun processOtherDeclaredReturnType(
        functionElement: ExecutableElement,
        argsString: String,
        kotlinReturnType: KmType?,
        funSpec: FunSpec.Builder
    ) {
        val supertypes =
            processingEnv.typeUtils.directSupertypes(functionElement.returnType)

        // if the parameter implements JSONSerializable we are good
        if (supertypes.any { it.toString() == "$nimbusPackage.JSONSerializable" }) {

            // stringify the return value
            funSpec.apply {
                addStatement(
                    "return target.%N($argsString).stringify()",
                    functionElement.simpleName.toString()
                )
                returns(String::class)
            }
        } else {

            // TODO: should we even allow this? what should the behavior be?
            // Map to nullable parameters if necessary
            if (functionElement.returnType.asTypeName() is ParameterizedTypeName) {
                val parameterizedReturnType =
                    functionElement.returnType.asKotlinTypeName() as ParameterizedTypeName
                val returnType =
                    parameterizedReturnType.rawType.parameterizedBy(
                        parameterizedReturnType.typeArguments.mapIndexed { index, type ->
                            val nullable = kotlinReturnType?.arguments?.get(index).isNullable()
                            type.toKotlinTypeName(nullable = nullable)
                        }
                    )
                funSpec.returns(returnType)
            } else {
                funSpec.returns(functionElement.returnType.asKotlinTypeName(nullable = kotlinReturnType.isNullable()))
            }
            funSpec.addStatement(
                "return target.%N($argsString)",
                functionElement.simpleName.toString()
            )
        }
    }

    private fun error(element: Element, message: String) {
        messager.printMessage(
            Diagnostic.Kind.ERROR,
            message,
            element
        )
    }
}
