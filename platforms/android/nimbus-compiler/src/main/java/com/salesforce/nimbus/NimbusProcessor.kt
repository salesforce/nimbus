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

                var closuresToPromisify = mutableListOf<String>()

                methods.forEach {
                    val methodElement = it as ExecutableElement

                    val methodSpec = MethodSpec.methodBuilder(it.simpleName.toString())
                        .addAnnotation(
                            AnnotationSpec.builder(ClassName.get("android.webkit", "JavascriptInterface"))
                                .build())
                        .addModifiers(Modifier.PUBLIC)
                        .returns(TypeName.get(methodElement.returnType))

                    val arguments = mutableListOf<String>()
                    var argIndex = 0

                    val promisifyClosure = methodElement.getAnnotation(ExtensionMethod::class.java).promisifyClosure
                    if (promisifyClosure) {
                        closuresToPromisify.add(methodElement.simpleName.toString())
                    }

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

                                            val supertypes = processingEnv.typeUtils.directSupertypes(wild.superBound)
                                            var found = false
                                            for (supertype in supertypes) {
                                                if (supertype.toString().equals("com.salesforce.nimbus.JSONSerializable")) {
                                                    found = true
                                                }
                                            }
                                            if (found) {
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
                                    var javascriptMethodToCall = "nimbus.callCallback2"
                                    if (promisifyClosure) {
                                        javascriptMethodToCall = "nimbus.resolvePromise"
                                    }
                                    invoke.addCode(
                                            CodeBlock.builder()
                                                    .add("if (webView != null) {\n")
                                                    .indent()
                                                    .addStatement("callJavascript(\$N, \$S, \$N, null)", "webView", javascriptMethodToCall, "args")
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
                    when (it.returnType.kind) {
                        TypeKind.VOID -> {
                            if (promisifyClosure) {
                                val supertypes = processingEnv.typeUtils.directSupertypes(it.returnType)
                                var found = false
                                for (supertype in supertypes) {
                                    if (supertype.toString().equals("com.salesforce.nimbus.JSONSerializable")) {
                                        found = true
                                    }
                                }

                                if (found) {
                                    methodSpec.returns(String::class.java)
                                    methodSpec.addStatement("target.\$N($argsString).stringify()", it.simpleName.toString())
                                } else {
                                    // TODO: should we even allow this? what should the behavior be?
                                    methodSpec.addStatement("target.\$N($argsString)", it.simpleName.toString())
                                }

                            } else {
                                methodSpec.addStatement("target.\$N($argsString)", it.simpleName.toString())
                            }
                        }
                        TypeKind.DECLARED -> {
                            if (promisifyClosure) {
                                throw Exception("Method with closure to be promisified can not have a return type")
                            } else {
                                if (it.returnType.toString().equals("java.lang.String")) {
                                    methodSpec.addStatement("return \$T.quote(target.\$N($argsString))",
                                        ClassName.get("org.json", "JSONObject"),
                                        it.simpleName.toString())
                                } else {

                                    val supertypes = processingEnv.typeUtils.directSupertypes(it.returnType)
                                    var found = false
                                    for (supertype in supertypes) {
                                        if (supertype.toString().equals("com.salesforce.nimbus.JSONSerializable")) {
                                            found = true
                                        }
                                    }

                                    if (found) {
                                        methodSpec.returns(String::class.java)
                                        methodSpec.addStatement("return target.\$N($argsString).stringify()", it.simpleName.toString())
                                    } else {
                                        // TODO: should we even allow this? what should the behavior be?
                                        methodSpec.addStatement("return target.\$N($argsString)", it.simpleName.toString())
                                    }
                                }
                            }
                        }
                        else -> {
                            // TODO: we should whitelist types we know work rather than just hoping for the best
                            methodSpec.addStatement("return target.\$N($argsString)", it.simpleName.toString())
                        }
                    }

                    type.addMethod(methodSpec.build())
                }

                if (closuresToPromisify.count() > 0) {
                    val methodSpec = MethodSpec.methodBuilder("getMethodsWithClosuresToPromisify")
                            .addAnnotation(
                                    AnnotationSpec.builder(ClassName.get("android.webkit", "JavascriptInterface"))
                                            .build())
                            .addModifiers(Modifier.PUBLIC)
                            .returns(TypeName.get(String::class.java))

                    methodSpec.addStatement("java.util.List<String> closureNames = new java.util.ArrayList<>()")
                    closuresToPromisify.forEach { it ->
                        methodSpec.addStatement("closureNames.add(\"\$N\")", it)
                    }
                    val commaSeparatedClosures = closuresToPromisify.joinToString(separator = ",");
                    methodSpec.addStatement("return \"\$N\"", commaSeparatedClosures)
                    type.addMethod(methodSpec.build())
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

    override fun getSupportedAnnotationTypes(): MutableSet<String> {
        return mutableSetOf(
                ExtensionMethod::class.java.canonicalName,
                Extension::class.java.canonicalName)
    }

    override fun getSupportedSourceVersion(): SourceVersion {
        return SourceVersion.latestSupported()
    }

    private fun error(element: Element, message: String) {
        messager.printMessage(
            Diagnostic.Kind.ERROR,
            message,
            element
        )
    }
}
