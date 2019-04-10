package com.salesforce.nimbus;

import com.squareup.javapoet.*
import javax.annotation.processing.AbstractProcessor
import javax.annotation.processing.RoundEnvironment
import javax.lang.model.SourceVersion
import javax.lang.model.element.ExecutableElement
import javax.lang.model.element.Modifier
import javax.lang.model.element.TypeElement
import javax.lang.model.type.DeclaredType
import javax.lang.model.type.TypeKind
import javax.lang.model.type.WildcardType
import javax.tools.Diagnostic

class NimbusProcessor: AbstractProcessor() {

    override fun process(annotations: MutableSet<out TypeElement>?, env: RoundEnvironment): Boolean {

        val bindings = env.getElementsAnnotatedWith(ExtensionMethod::class.java)
                .groupBy { it.enclosingElement }
        processingEnv.messager.printMessage(Diagnostic.Kind.WARNING, "method? ${bindings}")

        bindings.forEach { element, methods ->
            val packageName = processingEnv.elementUtils.getPackageOf(element).qualifiedName.toString()
            val typeName = element.simpleName.toString() + "Binder"

            val webViewClassName = ClassName.get("android.webkit", "WebView")
            // the binder needs to capture the bound target to pass through calls to it
            val type = TypeSpec.classBuilder(typeName)
                    .addModifiers(Modifier.PUBLIC)
                    .addMethod(MethodSpec.constructorBuilder()
                            .addParameter(TypeName.get(element.asType()), "target")
                            .addParameter(webViewClassName, "webView")
                            .addModifiers(Modifier.PUBLIC)
                            .addStatement("this.\$N = \$N", "target", "target")
                            .addStatement("this.\$N = \$N", "webView", "webView")
                            .build())
                    .addField(TypeName.get(element.asType()), "target", Modifier.FINAL, Modifier.PRIVATE)
                    .addField(webViewClassName, "webView", Modifier.FINAL, Modifier.PRIVATE)

            methods.forEach {
                val methodElement = it as ExecutableElement

                val methodSpec = MethodSpec.methodBuilder(it.simpleName.toString())
                        .addAnnotation(
                                AnnotationSpec.builder(ClassName.get("android.webkit", "JavascriptInterface"))
                                        .build())
                        .addModifiers(Modifier.PUBLIC)
                        .returns(TypeName.get(methodElement.returnType))

                if (methodElement.parameters.count() > 0) {
                    methodSpec
                            .addParameter(String::class.java, "argString")
                            .addException(ClassName.get("org.json", "JSONException"))

                    val jsonObject = ClassName.get("org.json", "JSONArray")
                    methodSpec.addStatement("\$T args = new \$T(argString)", jsonObject, jsonObject)
                }

                val arguments = mutableListOf<String>()
                var argIndex = 0

                methodElement.parameters.forEach {

                    // check if param needs conversion
                    when(it.asType().kind) {
                        TypeKind.BOOLEAN -> methodSpec.addStatement("\$T \$N = args.getBoolean($argIndex)", it.asType(), it.simpleName)
                        TypeKind.INT -> methodSpec.addStatement("\$T \$N = args.getInt($argIndex)", it.asType(), it.simpleName)
                        TypeKind.DOUBLE -> methodSpec.addStatement("\$T \$N = args.getDouble($argIndex)", it.asType(), it.simpleName)
                        TypeKind.FLOAT -> methodSpec.addStatement("\$T \$N = args.getDouble($argIndex)", it.asType(), it.simpleName)
                        TypeKind.LONG -> methodSpec.addStatement("\$T \$N = args.getLong($argIndex)", it.asType(), it.simpleName)
                        TypeKind.DECLARED -> {
                            // TODO:
                            val declaredType = it.asType() as DeclaredType

                            if (it.asType().toString().equals("java.lang.String")) {
                                methodSpec.addStatement("\$T \$N = args.getString($argIndex)", it.asType(), it.simpleName)
                            } else if (it.asType().toString().startsWith("kotlin.jvm.functions.Function")) {
                                methodSpec.addComment("Next line is a function!")
                                methodSpec.addStatement("final String callbackId$argIndex = args.getString($argIndex)")
//                                methodSpec.addStatement("\$T \$N = null", it.asType(), it.simpleName)

                                // ----


                                val invoke = MethodSpec.methodBuilder("invoke")
                                        .addAnnotation(Override::class.java)
                                        .addModifiers(Modifier.PUBLIC)
                                        // TODO: only Void is supported, emit an error if not void
                                        .returns(TypeName.get(declaredType.typeArguments.last()))


                                val argBlock = CodeBlock.builder()
                                        .add("\$T[] args = {\n", ClassName.get("com.salesforce.nimbus", "JSONSerializable"))
                                        .indent()
                                        .add("new \$T(callbackId$argIndex),\n", ClassName.get("com.salesforce.nimbus", "PrimitiveJSONSerializable"))

                                declaredType.typeArguments.dropLast(1).forEachIndexed { index, typeMirror ->
//                                    processingEnv.messager.printMessage(Diagnostic.Kind.WARNING, "type arg? ${typeMirror.kind}")
                                    if (typeMirror.kind == TypeKind.WILDCARD) {
                                        val wild = typeMirror as WildcardType
//                                        processingEnv.messager.printMessage(Diagnostic.Kind.WARNING, "wildcard? ${typeMirror.superBound}")
                                        invoke.addParameter(TypeName.get(typeMirror.superBound), "arg$index")

//                                        val parType = ParameterizedTypeName.get(wild.superBound)

//                                        processingEnv.messager.printMessage(Diagnostic.Kind.WARNING, "parType? ${parType}")

//                                        WildcardTypeName.get(wild)

                                    }

                                    invoke.addComment("Format arg $index here")
                                    argBlock.add("new \$T(arg$index),\n", ClassName.get("com.salesforce.nimbus", "PrimitiveJSONSerializable"))
                                }

                                argBlock.unindent().add("};\n")

                                invoke.addCode(argBlock.build())
                                invoke.addStatement("callJavascript(\$N, \$S, \$N, null)", "webView", "nimbus.callCallback2", "args")
                                        // TODO: actually send the callback across to webview
                                        .addStatement("return null")


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
//                                        .addSuperinterface(TypeName.get(it.asType()))
                                        .addMethod(invoke.build())
                                        .build()
                                methodSpec.addStatement("\$T \$N = \$L", it.asType(), it.simpleName, func)

                            } else {
                                // What should this do? Probs emit a compile error or something...
                                methodSpec.addStatement("\$T \$N = null", it.asType(), it.simpleName)

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


                val hasReturn = it.returnType.kind != TypeKind.VOID
                methodSpec.addCode("${if (hasReturn) "return " else "" }target.\$N(${arguments.joinToString(", ")});\n", it.simpleName.toString())

                type.addMethod(methodSpec.build())
            }

            JavaFile.builder(packageName, type.build())
                    .indent("    ")
                    .addStaticImport(ClassName.get("com.salesforce.nimbus", "ConnectionKt"), "callJavascript")
                    .build()
                    .writeTo(processingEnv.filer)

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
}
