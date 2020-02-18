package com.salesforce.nimbus

import com.squareup.javapoet.AnnotationSpec
import com.squareup.javapoet.ClassName
import com.squareup.javapoet.CodeBlock
import com.squareup.javapoet.FieldSpec
import com.squareup.javapoet.JavaFile
import com.squareup.javapoet.MethodSpec
import com.squareup.javapoet.ParameterizedTypeName
import com.squareup.javapoet.TypeName
import com.squareup.javapoet.TypeSpec
import javax.annotation.processing.AbstractProcessor
import javax.annotation.processing.Messager
import javax.annotation.processing.ProcessingEnvironment
import javax.annotation.processing.RoundEnvironment
import javax.lang.model.SourceVersion
import javax.lang.model.element.Element
import javax.lang.model.element.ElementKind
import javax.lang.model.element.ExecutableElement
import javax.lang.model.element.Modifier
import javax.lang.model.element.TypeElement
import javax.lang.model.type.DeclaredType
import javax.lang.model.type.TypeKind
import javax.lang.model.type.TypeMirror
import javax.lang.model.type.WildcardType
import javax.lang.model.util.Types
import javax.tools.Diagnostic

class NimbusProcessor : AbstractProcessor() {

    private lateinit var messager: Messager
    private lateinit var types: Types

    override fun init(processingEnvironment: ProcessingEnvironment) {
        super.init(processingEnvironment)
        messager = processingEnvironment.messager
        types = processingEnvironment.typeUtils
    }

    override fun process(annotations: MutableSet<out TypeElement>?, env: RoundEnvironment): Boolean {

        // keep track of used extension names to make sure we don't have duplicates
        val extensionNames = hashSetOf<String>()

        // get all extension classes
        env.getElementsAnnotatedWith(Extension::class.java).forEach { extensionElement ->

            // make sure this is a class
            if (extensionElement.kind != ElementKind.CLASS) {
                error(extensionElement, "Only classes can be annotated with ${Extension::class.java.simpleName}.")
                return true
            }

            // make sure it implements NimbusExtension
            if (types.directSupertypes(extensionElement.asType()).map { it.toString() }.none { it == "com.salesforce.nimbus.NimbusExtension" }) {
                error(extensionElement, "${Extension::class.java.simpleName} class must extend com.salesforce.nimbus.NimbusExtension.")
                return true
            }

            // get extension name
            val extensionName = extensionElement.getAnnotation(Extension::class.java).name

            // check if we already have used this name
            if (extensionName in extensionNames) {
                error(extensionElement, "A ${Extension::class.java.simpleName} with name $extensionName already exists.")
                return true
            } else {
                extensionNames.add(extensionName)
            }

            // get all methods annotated with ExtensionMethod
            val extensionMethodsElements = extensionElement.enclosedElements.filter {
                it.kind == ElementKind.METHOD && it.getAnnotation(ExtensionMethod::class.java) != null
            }

            extensionMethodsElements.groupBy { it.enclosingElement }.forEach { (element, methods) ->
                val packageName = processingEnv.elementUtils.getPackageOf(element).qualifiedName.toString()
                val typeName = element.simpleName.toString() + "Binder"
                val stringClassName = ClassName.get(String::class.java)

                val webViewClassName = ClassName.get("android.webkit", "WebView")
                // the binder needs to capture the bound target to pass through calls to it
                val type = TypeSpec.classBuilder(typeName)
                    .addSuperinterface(ClassName.get("com.salesforce.nimbus", "NimbusBinder"))
                    .addModifiers(Modifier.PUBLIC)
                    .addMethod(MethodSpec.constructorBuilder()
                        .addParameter(TypeName.get(element.asType()), "target")
                        .addModifiers(Modifier.PUBLIC)
                        .addStatement("this.\$N = \$N", "target", "target")
                        .build())
                    .addField(TypeName.get(element.asType()), "target", Modifier.FINAL, Modifier.PRIVATE)
                    .addField(webViewClassName, "webView", Modifier.PRIVATE)
                    .addField(FieldSpec.builder(stringClassName, "extensionName", Modifier.FINAL, Modifier.PRIVATE)
                        .initializer("\"$extensionName\"")
                        .build())
                    .addMethod(MethodSpec.methodBuilder("getExtension")
                        .addAnnotation(Override::class.java)
                        .addModifiers(Modifier.PUBLIC)
                        .returns(ClassName.get("com.salesforce.nimbus", "NimbusExtension"))
                        .addStatement("return target")
                        .build())
                    .addMethod(MethodSpec.methodBuilder("getExtensionName")
                        .addAnnotation(Override::class.java)
                        .addModifiers(Modifier.PUBLIC)
                        .returns(stringClassName)
                        .addStatement("return extensionName")
                        .build())
                    .addMethod(MethodSpec.methodBuilder("setWebView")
                        .addAnnotation(Override::class.java)
                        .addModifiers(Modifier.PUBLIC)
                        .addParameter(webViewClassName, "webView")
                        .addStatement("this.\$N = \$N", "webView", "webView")
                        .build())

                methods.forEach {
                    val methodElement = it as ExecutableElement
                    val bindingType = it.getAnnotation(ExtensionMethod::class.java).bindingType
                    when (bindingType) {
                        BindingType.Native -> addNativeMethod(type, methodElement)
                        BindingType.PromisedJavascript -> addPromisedJavascriptMethod(extensionName, type, methodElement)
                        else -> error(it, "Unknown binding type on ${it.simpleName} in $extensionName.")
                    }
                }

                JavaFile.builder(packageName, type.build())
                    .indent("    ")
                    .addStaticImport(ClassName.get("com.salesforce.nimbus", "WebViewExtensionsKt"), "callJavascript")
                    .build()
                    .writeTo(processingEnv.filer)
            }
        }

        return true
    }

    private fun addPromisedJavascriptMethod(extensionName: String, type: TypeSpec.Builder, methodElement: ExecutableElement) {
        val lastParam = methodElement.parameters.lastOrNull()
        if (lastParam == null || !lastParam.asType().toString().startsWith("kotlin.jvm.functions.Function")) {
            error(methodElement, "Expected a callback function as the last parameter of ${methodElement.simpleName}.")
            return
        }

        val lastParamType = lastParam.asType() as DeclaredType
        if (lastParamType.typeArguments.count() != 3) {
            error(methodElement, "Expected the trailing callback function for ${methodElement.simpleName} to be of type (String?, R?) -> Void")
            return
        }
        val resultTypeArg = lastParamType.typeArguments[1]
        val resultType = if (resultTypeArg.kind == TypeKind.WILDCARD) (resultTypeArg as WildcardType).superBound else resultTypeArg

        val finishedSpec = MethodSpec.methodBuilder("__${methodElement.simpleName}_finished")
                .addAnnotation(
                        AnnotationSpec.builder(ClassName.get("android.webkit", "JavascriptInterface"))
                                .build())
                .addModifiers(Modifier.PUBLIC)
                .addParameter(String::class.java, "promiseId")
                .addParameter(String::class.java, "error")
                .addParameter(String::class.java, "resultString")

        val extClass = ClassName.get("com.salesforce.nimbus", "PrimitiveExtensionsKt")
        when (resultType.kind) {
            TypeKind.BOOLEAN -> finishedSpec.addStatement("boolean result = Boolean.parseBoolean(resultString)")
            TypeKind.INT -> finishedSpec.addStatement("int result = Integer.parseInt(resultString)")
            TypeKind.DOUBLE -> finishedSpec.addStatement("double result = Double.parseDouble(resultString)")
            TypeKind.FLOAT -> finishedSpec.addStatement("float result = Float.parseFloat(resultString)")
            TypeKind.LONG -> finishedSpec.addStatement("long result = Long.parseLong(resultString)")
            TypeKind.DECLARED -> {
                when (resultType.toString()) {
                    "java.lang.String" -> {
                        finishedSpec.addStatement("\$T result = resultString", resultType, extClass, resultType)
                    }
                    "java.lang.Boolean" -> finishedSpec.addStatement("Boolean result = \"null\".equals(resultString) ? null : Boolean.parseBoolean(resultString)")
                    "java.lang.Integer" -> finishedSpec.addStatement("Integer result = \"null\".equals(resultString) ? null : Integer.parseInt(resultString)")
                    "java.lang.Double" -> finishedSpec.addStatement("Double result = \"null\".equals(resultString) ? null : Double.parseDouble(resultString)")
                    "java.lang.Float" -> finishedSpec.addStatement("Float result = \"null\".equals(resultString) ? null : Float.parseFloat(resultString)")
                    "java.lang.Long" -> finishedSpec.addStatement("Long result = \"null\".equals(resultString) ? null : Long.parseLong(resultString)")
                    "kotlin.Unit" -> finishedSpec.addStatement("Unit result = Unit.INSTANCE")
                    else -> {
                        val declaredType = resultType as DeclaredType
                        if (resultType.toString().startsWith("java.util.ArrayList")) {
                            finishedSpec.addStatement("\$T result = \$T.\$N(resultString, \$T.class)",
                                    resultType,
                                    extClass,
                                    "arrayFromJSON",
                                    TypeName.get(declaredType.typeArguments[0]))
                        } else if (resultType.toString().startsWith("java.util.HashMap")) {
                            finishedSpec.addStatement("\$T result = \$T.\$N(resultString, \$T.class, \$T.class)",
                                    resultType,
                                    extClass,
                                    "hashMapFromJSON",
                                    TypeName.get(declaredType.typeArguments[0]),
                                    TypeName.get(declaredType.typeArguments[1]))
                        } else {
                            // TODO: we also want to support kotlinx.serializable eventually

                            // The Binder will fail to compile if a static `fromJSON` method is not found.
                            // Probably want to emit an error from the annotation processor to fail faster.
                            finishedSpec.addStatement("\$T result = \$T.fromJSON(resultString)", resultType, resultType)
                        }
                    }
                }
            }
            else -> {
                error(methodElement, "Result type is not allowed")
            }
        }

        finishedSpec.addStatement(CodeBlock.of("\$N_promises.finishPromise(promiseId, error, result)", methodElement.simpleName))
        type.addMethod(finishedSpec.build())

        val promisesFieldName = "${methodElement.simpleName}_promises"
        type.addField(FieldSpec.builder(ClassName.get("com.salesforce.nimbus", "PromiseTracker"), promisesFieldName, Modifier.FINAL, Modifier.PRIVATE)
                .initializer("new PromiseTracker<\$T>()", TypeName.get(resultType))
                .build())
        val methodSpec = MethodSpec.methodBuilder(methodElement.simpleName.toString())
                .addModifiers(Modifier.PUBLIC)
                .returns(TypeName.get(methodElement.returnType))

        methodElement.parameters.dropLast(1).forEach { methodSpec.addParameter(TypeName.get(it.asType()), it.simpleName.toString()) }
        methodSpec.addParameter(ParameterizedTypeName.get(ClassName.get("kotlin.jvm.functions", "Function2"), TypeName.get(lastParamType.typeArguments[0]), TypeName.get(resultTypeArg), TypeName.get(Unit::class.java)), lastParam.simpleName.toString())
        methodSpec.addCode(CodeBlock.builder().add("String promiseId = java.util.UUID.randomUUID().toString();\n").build())
        val argBlock = CodeBlock.builder()
                .add("\$T[] args = new \$T[] {\n", ClassName.get("com.salesforce.nimbus", "JSONSerializable"), ClassName.get("com.salesforce.nimbus", "JSONSerializable"))
                .indent()
                .add("new \$T(\$S),\n", ClassName.get("com.salesforce.nimbus", "PrimitiveJSONSerializable"), extensionName)
                .add("new \$T(\$S),\n", ClassName.get("com.salesforce.nimbus", "PrimitiveJSONSerializable"), methodElement.simpleName)
                .add("new \$T(\$N),\n", ClassName.get("com.salesforce.nimbus", "PrimitiveJSONSerializable"), "promiseId")

        methodElement.parameters.dropLast(1).forEach {
            if (isJSONSerializable(it.asType())) {
                argBlock.add("${it.simpleName}, \n")
            } else {
                when (it.asType().kind) {
                    TypeKind.BOOLEAN,
                    TypeKind.INT,
                    TypeKind.DOUBLE,
                    TypeKind.FLOAT,
                    TypeKind.LONG -> {
                        argBlock.add("new \$T(${it.simpleName}),\n", ClassName.get("com.salesforce.nimbus", "PrimitiveJSONSerializable"))
                    }
                    else -> {
                        argBlock.add("${it.simpleName} != null ? new \$T(${it.simpleName}) : null,\n", ClassName.get("com.salesforce.nimbus", "PrimitiveJSONSerializable"))
                    }
                }
            }
        }

        argBlock.unindent().add("};\n")
        methodSpec.addCode(argBlock.build())
        val body = CodeBlock.builder()
                .add("if (webView != null) {\n")
                .indent()
                .addStatement("\$N.registerAndInvoke(\$N, \$N, \$N, \$N)", promisesFieldName, "webView", "promiseId", "args", lastParam.simpleName)
                .unindent()
                .add("} else {\n")
                .indent()
                .addStatement("${lastParam.simpleName}.invoke(\"The webView is not set\", null)")
                .unindent()
                .add("}\n")
                .build()

        methodSpec.addCode(body)
        type.addMethod(methodSpec.build())
    }

    private fun addNativeMethod(type: TypeSpec.Builder, methodElement: ExecutableElement) {
        val methodSpec = MethodSpec.methodBuilder(methodElement.simpleName.toString())
                .addAnnotation(
                        AnnotationSpec.builder(ClassName.get("android.webkit", "JavascriptInterface"))
                                .build())
                .addModifiers(Modifier.PUBLIC)
                .returns(TypeName.get(methodElement.returnType))

        val arguments = mutableListOf<String>()
        var argIndex = 0

        methodElement.parameters.forEach {

            // check if param needs conversion
            when (it.asType().kind) {
                TypeKind.BOOLEAN,
                TypeKind.INT,
                TypeKind.DOUBLE,
                TypeKind.FLOAT,
                TypeKind.LONG -> {
                    methodSpec.addParameter(TypeName.get(it.asType()), it.simpleName.toString())
                }
                TypeKind.DECLARED -> {
                    val declaredType = it.asType() as DeclaredType

                    if (it.asType().toString().equals("java.lang.String")) {
                        methodSpec.addParameter(String::class.java, it.simpleName.toString())
                    } else if (it.asType().toString().startsWith("kotlin.jvm.functions.Function")) {
                        methodSpec.addParameter(String::class.java, it.simpleName.toString() + "Id", Modifier.FINAL)

                        val invoke = MethodSpec.methodBuilder("invoke")
                            .addAnnotation(Override::class.java)
                            .addModifiers(Modifier.PUBLIC)
                            // TODO: only Void return is supported in callbacks, emit an error if not void
                            .returns(TypeName.get(declaredType.typeArguments.last()))

                        val argBlock = CodeBlock.builder()
                            .add("\$T[] args = {\n", ClassName.get("com.salesforce.nimbus", "JSONSerializable"))
                            .indent()
                            .add("new \$T(\$NId),\n", ClassName.get("com.salesforce.nimbus", "PrimitiveJSONSerializable"), it.simpleName)

                        declaredType.typeArguments.dropLast(1).forEachIndexed { index, typeMirror ->
                            if (typeMirror.kind == TypeKind.WILDCARD) {
                                val wild = typeMirror as WildcardType
                                invoke.addParameter(TypeName.get(wild.superBound), "arg$index")

                                if (isJSONSerializable(wild.superBound)) {
                                    argBlock.add("arg$index, \n")
                                } else {
                                    argBlock.add("arg$index != null ? new \$T(arg$index) : null,\n", ClassName.get("com.salesforce.nimbus", "PrimitiveJSONSerializable"))
                                }
                            } else {
                                argBlock.add("arg$index != null ? new \$T(arg$index) : null,\n", ClassName.get("com.salesforce.nimbus", "PrimitiveJSONSerializable"))
                            }
                        }

                        argBlock.unindent().add("};\n")

                        invoke.addCode(argBlock.build())
                        invoke.addCode(
                            CodeBlock.builder()
                                .add("if (webView != null) {\n")
                                    .indent()
                                    .addStatement("callJavascript(\$N, \$S, \$N, null)", "webView", "__nimbus.callCallback2", "args")
                                    .unindent()
                                    .add("}\n")
                                    .addStatement("return null")
                                    .build()
                        )

                        val typeArgs = declaredType.typeArguments.map {
                            if (it.kind == TypeKind.WILDCARD) {
                                val wild = it as WildcardType
                                TypeName.get(wild.superBound)
                            } else {
                                TypeName.get(it)
                            }
                        }

                        val className = ClassName.get(declaredType.asElement() as TypeElement)
                        val superInterface = ParameterizedTypeName.get(className, *typeArgs.toTypedArray())

                        val func = TypeSpec.anonymousClassBuilder("")
                            .addSuperinterface(superInterface)
                            .addMethod(invoke.build())
                            .build()
                        methodSpec.addStatement("\$T \$N = \$L", it.asType(), it.simpleName, func)
                    } else if (it.asType().toString().startsWith("java.util.ArrayList")) {
                        methodSpec.addParameter(String::class.java, it.simpleName.toString() + "String")
                        val extClass = ClassName.get("com.salesforce.nimbus", "PrimitiveExtensionsKt")
                        methodSpec.addStatement("\$T \$N = \$T.\$N(\$NString, \$T.class)",
                            it.asType(),
                            it.simpleName,
                            extClass,
                            "arrayFromJSON",
                            it.simpleName,
                            TypeName.get(declaredType.typeArguments[0]))
                    } else if (it.asType().toString().startsWith("java.util.HashMap")) {
                        methodSpec.addParameter(String::class.java, it.simpleName.toString() + "String")
                        val extClass = ClassName.get("com.salesforce.nimbus", "PrimitiveExtensionsKt")
                        methodSpec.addStatement("\$T \$N = \$T.\$N(\$NString, \$T.class, \$T.class)",
                            it.asType(),
                            it.simpleName,
                            extClass,
                            "hashMapFromJSON",
                            it.simpleName,
                            TypeName.get(declaredType.typeArguments[0]),
                            TypeName.get(declaredType.typeArguments[1]))
                    } else {
                        // TODO: we also want to support kotlinx.serializable eventually

                        // The Binder will fail to compile if a static `fromJSON` method is not found.
                        // Probably want to emit an error from the annotation processor to fail faster.
                        methodSpec.addParameter(String::class.java, it.simpleName.toString() + "String")
                        methodSpec.addStatement("\$T \$N = \$T.fromJSON(\$NString)", it.asType(), it.simpleName, it.asType(), it.simpleName)
                    }
                }
                else -> {
                    // What should this do? Probs emit a compile error or something...
                    methodSpec.addStatement("\$T \$N = args.get($argIndex)", it.asType(), it.simpleName)
                }
            }

            arguments.add(it.simpleName.toString())
            argIndex++
        }

        // JSON Encode the return value if necessary
        val argsString = arguments.joinToString(", ")
        when (methodElement.returnType.kind) {
            TypeKind.VOID -> {
                methodSpec.addStatement("target.\$N($argsString)", methodElement.simpleName.toString())
            }
            TypeKind.DECLARED -> {

                if (methodElement.returnType.toString().equals("java.lang.String")) {
                    methodSpec.addStatement("return \$T.quote(target.\$N($argsString))",
                            ClassName.get("org.json", "JSONObject"),
                            methodElement.simpleName.toString())
                } else {

                    val supertypes = processingEnv.typeUtils.directSupertypes(methodElement.returnType)
                    var found = false
                    for (supertype in supertypes) {
                        if (supertype.toString().equals("com.salesforce.nimbus.JSONSerializable")) {
                            found = true
                        }
                    }

                    if (found) {
                        methodSpec.returns(String::class.java)
                        methodSpec.addStatement("return target.\$N($argsString).stringify()", methodElement.simpleName.toString())
                    } else {
                        // TODO: should we even allow this? what should the behavior be?
                        methodSpec.addStatement("return target.\$N($argsString)", methodElement.simpleName.toString())
                    }
                }
            }
            else -> {
                // TODO: we should whitelist types we know work rather than just hoping for the best
                methodSpec.addStatement("return target.\$N($argsString)", methodElement.simpleName.toString())
            }
        }

        type.addMethod(methodSpec.build())
    }

    override fun getSupportedAnnotationTypes(): MutableSet<String> {
        return mutableSetOf(
            ExtensionMethod::class.java.canonicalName,
            Extension::class.java.canonicalName)
    }

    override fun getSupportedSourceVersion(): SourceVersion {
        return SourceVersion.latestSupported()
    }

    private fun isJSONSerializable(type: TypeMirror): Boolean {
        val supertypes = processingEnv.typeUtils.directSupertypes(type)
        var found = false
        for (supertype in supertypes) {
            if (supertype.toString().equals("com.salesforce.nimbus.JSONSerializable")) {
                found = true
            }
        }

        return found
    }

    private fun error(element: Element, message: String) {
        messager.printMessage(
            Diagnostic.Kind.ERROR,
            message,
            element
        )
    }
}
