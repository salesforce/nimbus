package com.salesforce.nimbus;

import com.squareup.javapoet.*
import javax.annotation.processing.AbstractProcessor
import javax.annotation.processing.RoundEnvironment
import javax.lang.model.SourceVersion
import javax.lang.model.element.ExecutableElement
import javax.lang.model.element.Modifier
import javax.lang.model.element.TypeElement
import javax.lang.model.type.TypeKind
import javax.tools.Diagnostic

class NimbusProcessor: AbstractProcessor() {

    override fun process(annotations: MutableSet<out TypeElement>?, env: RoundEnvironment): Boolean {

        val bindings = env.getElementsAnnotatedWith(ExtensionMethod::class.java)
                .groupBy { it.enclosingElement }
        processingEnv.messager.printMessage(Diagnostic.Kind.WARNING, "method? ${bindings}")

        bindings.forEach { element, methods ->
            val packageName = processingEnv.elementUtils.getPackageOf(element).qualifiedName.toString()
            val typeName = element.simpleName.toString() + "Binder"

            // the binder needs to capture the bound target to pass through calls to it
            val type = TypeSpec.classBuilder(typeName)
                    .addModifiers(Modifier.PUBLIC)
                    .addMethod(MethodSpec.constructorBuilder()
                            .addParameter(TypeName.get(element.asType()), "target")
                            .addModifiers(Modifier.PUBLIC)
                            .addStatement("this.\$N = \$N", "target", "target")
                            .build())
                    .addField(TypeName.get(element.asType()), "target", Modifier.FINAL, Modifier.PRIVATE)

            methods.forEach {
                val methodElement = it as ExecutableElement

                val methodSpec = MethodSpec.methodBuilder(it.simpleName.toString())
                        .addAnnotation(
                                AnnotationSpec.builder(ClassName.get("android.webkit", "JavascriptInterface"))
                                        .build())
                        .addModifiers(Modifier.PUBLIC)
                        .returns(TypeName.get(methodElement.returnType))
                        .addException(ClassName.get("org.json", "JSONException"))

                methodSpec.addParameter(String::class.java, "argString")

                val jsonObject = ClassName.get("org.json", "JSONArray")
                methodSpec.addStatement("\$T args = new \$T(argString)", jsonObject, jsonObject)

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
                            if (it.asType().toString().equals("java.lang.String")) {
                                methodSpec.addStatement("\$T \$N = args.getString($argIndex)", it.asType(), it.simpleName)
                            } else {
                                methodSpec.addStatement("\$T \$N = null", it.asType(), it.simpleName)

                            }
                        }
                        else -> {
//                            methodSpec.addParameter(TypeName.get(it.asType()), it.simpleName.toString())
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
