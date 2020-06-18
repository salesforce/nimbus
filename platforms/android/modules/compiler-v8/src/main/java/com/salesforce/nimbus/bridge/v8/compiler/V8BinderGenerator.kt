package com.salesforce.nimbus.bridge.v8.compiler

import com.salesforce.nimbus.PluginOptions
import com.salesforce.nimbus.compiler.BinderGenerator
import com.salesforce.nimbus.compiler.asKotlinTypeName
import com.salesforce.nimbus.compiler.asRawTypeName
import com.salesforce.nimbus.compiler.asTypeName
import com.salesforce.nimbus.compiler.getName
import com.salesforce.nimbus.compiler.isNullable
import com.salesforce.nimbus.compiler.nimbusPackage
import com.salesforce.nimbus.compiler.salesforceNamespace
import com.salesforce.nimbus.compiler.typeArguments
import com.squareup.kotlinpoet.ClassName
import com.squareup.kotlinpoet.CodeBlock
import com.squareup.kotlinpoet.FunSpec
import com.squareup.kotlinpoet.KModifier
import com.squareup.kotlinpoet.LambdaTypeName
import com.squareup.kotlinpoet.PropertySpec
import com.squareup.kotlinpoet.TypeSpec
import kotlinx.metadata.KmFunction
import kotlinx.metadata.KmValueParameter
import javax.lang.model.element.Element
import javax.lang.model.element.ExecutableElement
import javax.lang.model.element.VariableElement
import javax.lang.model.type.ArrayType
import javax.lang.model.type.DeclaredType
import javax.lang.model.type.TypeKind
import javax.lang.model.type.WildcardType

private const val v8Package = "com.eclipsesource.v8"
private const val k2v8Package = "$salesforceNamespace.k2v8"
private const val nimbusV8Package = "$nimbusPackage.bridge.v8"

class V8BinderGenerator : BinderGenerator() {
    override val javascriptEngine = ClassName(v8Package, "V8")
    override val serializedOutputType = ClassName(v8Package, "V8Object")

    private val v8ClassName = javascriptEngine
    private val v8ObjectClassName = serializedOutputType
    private val v8ArrayClassName = ClassName(v8Package, "V8Array")
    private val v8FunctionClassName = ClassName(v8Package, "V8Function")
    private val k2V8ClassName = ClassName(k2v8Package, "K2V8")

    override fun shouldGenerateBinder(pluginElement: Element): Boolean {
        return pluginElement.getAnnotation(PluginOptions::class.java).supportsV8
    }

    override fun processClassProperties(builder: TypeSpec.Builder) {

        // add k2v8 property so we can serialize to/from v8
        builder.addProperties(
            listOf(
                PropertySpec.builder(
                    "k2v8",
                    k2V8ClassName.copy(nullable = true),
                    KModifier.PRIVATE
                )
                    .mutable()
                    .initializer("null")
                    .build(),
                PropertySpec.builder(
                    "pluginBridge",
                    v8ObjectClassName.copy(nullable = true),
                    KModifier.PRIVATE
                )
                    .mutable()
                    .initializer("null")
                    .build()
            )
        )
    }

    override fun processBindFunction(
        boundMethodElements: List<ExecutableElement>,
        builder: FunSpec.Builder
    ) {
        val codeBlock = CodeBlock.builder()
            .addStatement("val v8 = runtime.getJavascriptEngine()")
            .beginControlFlow("if (v8 != null) {")

            // grab the nimbus object
            .addStatement(
                "val nimbus = v8.getObject(%T)",
                ClassName(nimbusPackage, "NIMBUS_BRIDGE")
            )

            // grab the plugins array
            .addStatement(
                "val plugins = nimbus.getObject(%T)",
                ClassName(nimbusPackage, "NIMBUS_PLUGINS")
            )

            // create our K2V8 instance
            .addStatement(
                "this.k2v8 = %T(%T(v8))",
                k2V8ClassName,
                ClassName(k2v8Package, "Configuration")
            )

            // create our plugin bridge and add our callback methods
            .beginControlFlow(
                "pluginBridge = %T(v8).apply {",
                v8ObjectClassName
            )

            // register a v8 java callback for each bound method
            .apply {
                boundMethodElements.forEach { boundMethod ->
                    addStatement(
                        "%T(\"%N\", ::%N)",
                        ClassName(nimbusV8Package, "registerJavaCallback"),
                        boundMethod.getName(),
                        boundMethod.getName()
                    )
                }
            }
            .endControlFlow()

            // add the plugin to the nimbus plugins
            .addStatement("plugins.add(\"\$pluginName\", pluginBridge)")

            // need to close the nimbus object
            .addStatement("nimbus.close()")

            // need to close the plugins object
            .addStatement("plugins.close()")
            .endControlFlow()

        // add code block to the bind function
        builder.addCode(codeBlock.build())
    }

    override fun processUnbindFunction(builder: FunSpec.Builder) {
        builder.addStatement("pluginBridge?.close()")
    }

    override fun createBinderExtensionFunction(pluginElement: Element, binderClassName: ClassName): FunSpec {
        return FunSpec.builder("v8Binder")
            .receiver(pluginElement.asTypeName())
            .addStatement(
                "return %T(this)",
                binderClassName
            )
            .returns(binderClassName)
            .build()
    }

    override fun processFunctionElement(
        functionElement: ExecutableElement,
        serializableElements: Set<Element>,
        kotlinFunction: KmFunction?
    ): FunSpec {
        val functionName = functionElement.simpleName.toString()

        // create the binder function
        val parameters = "parameters"
        val funSpec = FunSpec.builder(functionName)
            .addModifiers(KModifier.PRIVATE)
            .addParameter(
                parameters,
                v8ArrayClassName
            )
        val funBody = CodeBlock.builder()
            .addStatement(
                "val v8 = runtime?.getJavascriptEngine() as %T",
                v8ClassName
            )
            .beginControlFlow("return try {")

        val funArgs = mutableListOf<String>()
        functionElement.parameters.forEachIndexed { parameterIndex, parameter ->

            // try to get the value parameter from the kotlin class metadata
            // to determine if it is nullable
            val kotlinParameter = kotlinFunction?.valueParameters?.get(parameterIndex)

            // check if param needs conversion
            val paramCodeBlock: CodeBlock = when (parameter.asType().kind) {
                TypeKind.BOOLEAN,
                TypeKind.INT,
                TypeKind.DOUBLE,
                TypeKind.FLOAT,
                TypeKind.LONG -> processPrimitiveParameter(parameter, parameterIndex)
                TypeKind.ARRAY -> processArrayParameter(parameter, parameterIndex)
                TypeKind.DECLARED -> {
                    val declaredType = parameter.asType() as DeclaredType
                    when {
                        declaredType.isStringType() -> processStringParameter(parameter, parameterIndex)
                        declaredType.isKotlinSerializableType() -> processSerializableParameter(
                            parameter,
                            parameterIndex,
                            declaredType
                        )
                        declaredType.isFunctionType() -> {
                            val functionParameterReturnType = declaredType.typeArguments.last()
                            when {

                                // throw a compiler error if the callback does not return void
                                !functionParameterReturnType.isUnitType() -> {
                                    error(
                                        functionElement,
                                        "Only a Unit (Void) return type in callbacks is supported."
                                    )
                                    return@forEachIndexed
                                }
                                else -> processFunctionParameter(declaredType, parameter, kotlinParameter, parameterIndex)
                            }
                        }
                        declaredType.isListType() -> processListParameter(declaredType, parameter, kotlinParameter, parameterIndex)
                        declaredType.isMapType() -> {
                            val parameterKeyType = declaredType.typeArguments[0]

                            // Currently only string key types are supported
                            if (!parameterKeyType.isStringType()) {
                                error(
                                    functionElement,
                                    "${parameterKeyType.asKotlinTypeName()} is an unsupported " +
                                        "value type for Map. Currently only String is supported."
                                )
                                return@forEachIndexed
                            } else processMapParameter(declaredType, parameter, kotlinParameter, parameterIndex)
                        }
                        else -> {
                            error(
                                functionElement,
                                "${parameter.asKotlinTypeName()} is an unsupported parameter type."
                            )
                            return@forEachIndexed
                        }
                    }
                }

                // unsupported kind
                else -> {
                    error(
                        functionElement,
                        "${parameter.asKotlinTypeName()} is an unsupported parameter type."
                    )
                    return@forEachIndexed
                }
            }

            // add parameter to function body
            funBody
                .add(paramCodeBlock)
                .add("\n")

            // add parameter to list of function args for later
            funArgs.add(parameter.getName())
        }

        // join args to a string
        val argsString = funArgs.joinToString(", ")

        // invoke plugin function and get result
        funBody
            .addStatement(
                "val result = target.%N($argsString)",
                functionElement.getName()
            )

            // wrap return result in a promise
            .add(
                "v8.%T(",
                ClassName(nimbusV8Package, "resolvePromise")
            )

        // process the result (may need to serialize)
        funBody.add(processResult(functionElement))

        // close out the try {} catch and reject the promise if we encounter an exception
        funBody
            .addStatement(")")
            .nextControlFlow("catch (throwable: Throwable)")
            .addStatement(
                "v8.%T(throwable.message ?: \"Error\")", // TODO what default error message?
                ClassName(nimbusV8Package, "rejectPromise")
            )
            .endControlFlow()

        // add our function body and return a V8Object
        funSpec
            .addCode(funBody.build())
            .returns(v8ObjectClassName)

        return funSpec.build()
    }

    private fun processPrimitiveParameter(
        parameter: VariableElement,
        parameterIndex: Int
    ): CodeBlock {
        val declaration = "val ${parameter.getName()}"
        return when (parameter.asType().kind) {
            TypeKind.BOOLEAN -> CodeBlock.of("$declaration = parameters.getBoolean($parameterIndex)")
            TypeKind.INT -> CodeBlock.of("$declaration = parameters.getInteger($parameterIndex)")
            TypeKind.DOUBLE -> CodeBlock.of("$declaration = parameters.getDouble($parameterIndex)")
            TypeKind.FLOAT -> CodeBlock.of("$declaration = parameters.getDouble($parameterIndex).toFloat()")
            TypeKind.LONG -> CodeBlock.of("$declaration = parameters.getInteger($parameterIndex).toLong()")
            // TODO support rest of primitive types
            else -> {
                error(
                    parameter,
                    "${parameter.asKotlinTypeName()} is an unsupported parameter type."
                )
                throw IllegalArgumentException()
            }
        }
    }

    private fun processArrayParameter(
        parameter: VariableElement,
        parameterIndex: Int
    ): CodeBlock {
        return CodeBlock.of(
            "val ${parameter.getName()} = parameters.getObject($parameterIndex).let { k2v8!!.fromV8(%T(%T.%T()), it) }",
            arraySerializerClassName,
            parameter.asType().typeArguments().first(),
            serializerFunctionName
        )
    }

    private fun processStringParameter(
        parameter: VariableElement,
        parameterIndex: Int
    ): CodeBlock {
        return CodeBlock.of("val ${parameter.getName()} = parameters.getString($parameterIndex)")
    }

    private fun processSerializableParameter(
        parameter: VariableElement,
        parameterIndex: Int,
        declaredType: DeclaredType
    ): CodeBlock {
        return CodeBlock.of(
            "val ${parameter.getName()} = parameters.getObject($parameterIndex).let { k2v8!!.fromV8(%T.%T(), it) }",
            declaredType,
            serializerFunctionName
        )
    }

    private fun processFunctionParameter(
        declaredType: DeclaredType,
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        parameterIndex: Int
    ): CodeBlock {

        // Check if there are more than two parameters in callback. Only two parameters (result, error) are allowed.
        if (declaredType.typeArguments.size > 3) { // one type is for the return type (should be void)
            error(parameter, "Only two parameters are allowed in callbacks.")
            return CodeBlock.of("")
        }
        val functionBlock = CodeBlock.Builder()
            .addStatement(
                "val callback$parameterIndex = parameters.get($parameterIndex) as %T",
                v8FunctionClassName
            )

        // try to get the parameter type from the kotlin class
        // metadata to determine if it is nullable
        val kotlinParameterType = kotlinParameter?.type

        // create the callback function body
        val argBlock = CodeBlock.builder()
            .add("val params = listOf(")

        // loop through each argument (except for last)
        // and add to the array created above
        declaredType.typeArguments.dropLast(1)
            .forEachIndexed { index, functionParameterType ->

                // try to get the type from the kotlin class metadata
                // to determine if it is nullable
                val kotlinType =
                    kotlinParameterType?.arguments?.get(index)
                val kotlinTypeNullable = kotlinType.isNullable()

                when (functionParameterType.kind) {
                    TypeKind.WILDCARD -> {
                        val wildcardParameterType = (functionParameterType as WildcardType).superBound
                        when {
                            wildcardParameterType.isKotlinSerializableType() -> {
                                val statement =
                                    "k2v8!!.toV8(%T.%T(), p$index)"
                                argBlock.add(
                                    if (kotlinTypeNullable) {
                                        "p$index?.let { $statement }"
                                    } else statement,
                                    wildcardParameterType.asRawTypeName(),
                                    serializerFunctionName
                                )
                            }
                            wildcardParameterType.isListType() -> {
                                val listValueType = wildcardParameterType.typeArguments().first()
                                val statement =
                                    "k2v8!!.toV8(%T(%T.%T()), p$index)"
                                argBlock.add(
                                    if (kotlinTypeNullable) {
                                        "p$index?.let { $statement }"
                                    } else statement,
                                    listSerializerClassName,
                                    listValueType,
                                    serializerFunctionName
                                )
                            }
                            wildcardParameterType.isMapType() -> {
                                val mapTypeArguments = wildcardParameterType.typeArguments()
                                val mapKeyType = mapTypeArguments[0]
                                val mapValueType = mapTypeArguments[1]
                                val statement =
                                    "k2v8!!.toV8(%T(%T.%T(), %T.%T()), p$index)"
                                argBlock.add(
                                    if (kotlinTypeNullable) {
                                        "p$index?.let { $statement }"
                                    } else statement,
                                    mapSerializerClassName,
                                    mapKeyType,
                                    serializerFunctionName,
                                    mapValueType,
                                    serializerFunctionName
                                )
                            }
                            wildcardParameterType.isArrayType() -> {
                                val arrayType = wildcardParameterType.typeArguments().first()
                                val statement =
                                    "k2v8!!.toV8(%T(%T.%T()), p$index)"
                                argBlock.add(
                                    if (kotlinTypeNullable) {
                                        "p$index?.let { $statement }"
                                    } else statement,
                                    arraySerializerClassName,
                                    arrayType,
                                    serializerFunctionName
                                )
                            }
                            else -> argBlock.add("p$index")
                        }
                    }
                    else -> {
                        // shouldn't need to handle this
                    }
                }

                // add another element to the array
                if (index < declaredType.typeArguments.size - 2) {
                    argBlock.add(", ")
                }
            }

        // finish (close) the array
        argBlock
            .addStatement(")")
            .addStatement(
                "callback$parameterIndex.use { it.call(v8, params.%T(v8)) }",
                ClassName(k2v8Package, "toV8Array")
            )

        // get the type args for the lambda function
        val lambdaTypeArgs =
            declaredType.typeArguments.mapIndexed { index, type ->
                val kotlinType =
                    kotlinParameterType?.arguments?.get(index)
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
            .beginControlFlow(
                "val ${parameter.getName()}: %T = { ${declaredType.typeArguments.dropLast(
                    1
                ).mapIndexed { index, _ -> "p$index" }.joinToString(
                    separator = ", "
                )} ->",
                lambdaType
            )
            .add("%L", argBlock.build())
            .endControlFlow()

        // add lambda to function block
        functionBlock.add(lambda.build())

        return functionBlock.build()
    }

    private fun processListParameter(
        declaredType: DeclaredType,
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        parameterIndex: Int
    ): CodeBlock {
        val parameterValueType = declaredType.typeArguments.first()
        return CodeBlock.of(
            "val ${parameter.getName()} = parameters.getObject($parameterIndex).let { k2v8!!.fromV8(%T(%T.%T()), it) }",
            listSerializerClassName,
            parameterValueType.asKotlinTypeName(kotlinParameter.isNullable()),
            serializerFunctionName
        )
    }

    private fun processMapParameter(
        declaredType: DeclaredType,
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        parameterIndex: Int
    ): CodeBlock {
        val parameterKeyType = declaredType.typeArguments[0]
        val parameterValueType = declaredType.typeArguments[1]
        return CodeBlock.of(
            "val ${parameter.getName()} = parameters.getObject($parameterIndex).let { k2v8!!.fromV8(%T(%T.%T(), %T.%T()), it) }",
            mapSerializerClassName,
            parameterKeyType.asKotlinTypeName(kotlinParameter.isNullable()),
            serializerFunctionName,
            parameterValueType.asKotlinTypeName(kotlinParameter.isNullable()),
            serializerFunctionName
        )
    }

    private fun processResult(
        functionElement: ExecutableElement
    ): CodeBlock {
        return when (val returnType = functionElement.returnType) {
            is DeclaredType -> {
                when {
                    returnType.isStringType() -> CodeBlock.of("result")
                    returnType.isKotlinSerializableType() -> CodeBlock.of(
                        "k2v8!!.toV8(%T.%T(), result)",
                        returnType,
                        serializerFunctionName
                    )
                    returnType.isListType() -> {
                        val parameterType = returnType.typeArguments.first().asKotlinTypeName()
                        CodeBlock.of(
                            "k2v8!!.toV8(%T(%T.%T()), result)",
                            listSerializerClassName,
                            parameterType,
                            serializerFunctionName
                        )
                    }
                    returnType.isMapType() -> {
                        val keyParameterType = returnType.typeArguments[0].asKotlinTypeName()
                        val valueParameterType = returnType.typeArguments[1].asKotlinTypeName()
                        CodeBlock.of(
                            "k2v8!!.toV8(%T(%T.%T(), %T.%T()), result)",
                            mapSerializerClassName,
                            keyParameterType,
                            serializerFunctionName,
                            valueParameterType,
                            serializerFunctionName
                        )
                    }
                    else -> {
                        error(
                            functionElement,
                            "${returnType.asKotlinTypeName()} is an unsupported return type."
                        )
                        throw IllegalArgumentException()
                    }
                }
            }
            is ArrayType -> {
                val arrayType = returnType.typeArguments().first()
                CodeBlock.of(
                    "k2v8!!.toV8(%T(%T.%T()), result)",
                    arraySerializerClassName,
                    arrayType,
                    serializerFunctionName
                )
            }

            // if a primitive type just return the result
            else -> CodeBlock.of("result")
        }
    }
}
