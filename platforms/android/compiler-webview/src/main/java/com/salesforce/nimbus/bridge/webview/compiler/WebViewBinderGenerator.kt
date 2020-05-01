package com.salesforce.nimbus.bridge.webview.compiler

import com.salesforce.nimbus.compiler.BinderGenerator
import com.salesforce.nimbus.compiler.asKotlinTypeName
import com.salesforce.nimbus.compiler.asRawTypeName
import com.salesforce.nimbus.compiler.getName
import com.salesforce.nimbus.compiler.isNullable
import com.salesforce.nimbus.compiler.nimbusPackage
import com.salesforce.nimbus.compiler.nullable
import com.salesforce.nimbus.compiler.toKotlinTypeName
import com.squareup.kotlinpoet.ClassName
import com.squareup.kotlinpoet.CodeBlock
import com.squareup.kotlinpoet.FunSpec
import com.squareup.kotlinpoet.LambdaTypeName
import com.squareup.kotlinpoet.ParameterizedTypeName
import com.squareup.kotlinpoet.ParameterizedTypeName.Companion.parameterizedBy
import com.squareup.kotlinpoet.asClassName
import com.squareup.kotlinpoet.asTypeName
import kotlinx.metadata.KmFunction
import kotlinx.metadata.KmType
import kotlinx.metadata.KmValueParameter
import javax.lang.model.element.Element
import javax.lang.model.element.ExecutableElement
import javax.lang.model.element.VariableElement
import javax.lang.model.type.DeclaredType
import javax.lang.model.type.TypeKind
import javax.lang.model.type.WildcardType

class WebViewBinderGenerator : BinderGenerator() {
    override val javascriptEngine = ClassName("android.webkit", "WebView")
    override val serializedOutputType = ClassName("kotlin", "String")

    override fun processFunctionElement(
        functionElement: ExecutableElement,
        serializableElements: Set<Element>,
        kotlinFunction: KmFunction?
    ): FunSpec {
        val functionName = functionElement.simpleName.toString()
        val functionReturnType = functionElement.returnType

        // try to find the fun from the kotlin class metadata to see if the
        // return type is nullable
        val kotlinReturnType = kotlinFunction?.returnType

        // create the binder function
        val funSpec = FunSpec.builder(functionName).apply {

            // add android @JavascriptInterface annotation to function
            addAnnotation(ClassName("android.webkit", "JavascriptInterface"))
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
                TypeKind.LONG -> processPrimitiveParameter(parameter, kotlinParameter, funSpec)
                // TODO support rest of primitive types
                TypeKind.DECLARED -> {
                    val declaredType = parameter.asType() as DeclaredType
                    when {
                        declaredType.isStringType() -> processStringParameter(parameter, kotlinParameter, funSpec)
                        declaredType.isFunctionType() -> {
                            val functionParameterReturnType = declaredType.typeArguments.last()
                            when {

                                // throw a compiler error if the callback does not return void
                                !functionParameterReturnType.isUnitType() -> error(
                                    functionElement,
                                    "Only a Unit (Void) return type in callbacks is supported."
                                )

                                // throw a compiler error if the function does not return void
                                !functionReturnType.isUnitType() -> error(
                                    functionElement,
                                    "Functions with a callback only support a Unit (Void) return type."
                                )
                                else -> processFunctionParameter(
                                    declaredType,
                                    parameter,
                                    kotlinParameter,
                                    funSpec
                                )
                            }
                        }
                        declaredType.isListType() -> processListParameter(
                            declaredType,
                            parameter,
                            kotlinParameter,
                            funSpec
                        )
                        declaredType.isMapType() -> processMapParameter(
                            declaredType,
                            parameter,
                            kotlinParameter,
                            funSpec
                        )
                        else -> processOtherDeclaredParameter(
                            declaredType,
                            parameter,
                            funSpec
                        )
                    }
                }

                // unsupported kind
                else -> error(
                    functionElement,
                    "${parameter.asKotlinTypeName()} is an unsupported parameter type."
                )
            }

            // add parameter to list of function args for later
            funArgs.add(parameter.getName())
        }

        // JSON Encode the return value if necessary
        val argsString = funArgs.joinToString(", ")
        val returnType = functionElement.returnType
        when (returnType.kind) {
            TypeKind.VOID -> processVoidReturnType(functionElement, argsString, kotlinReturnType, funSpec)
            TypeKind.DECLARED -> {
                when {
                    returnType.toString() in listOf("java.lang.String", "kotlin.String") -> processStringReturnType(
                        functionElement,
                        argsString,
                        kotlinReturnType,
                        funSpec
                    )
                    else -> processOtherDeclaredReturnType(
                        functionElement,
                        argsString,
                        kotlinReturnType,
                        funSpec
                    )
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

    private fun processPrimitiveParameter(
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        funSpec: FunSpec.Builder
    ) {
        funSpec.addParameter(
            parameter.getName(),
            parameter.asKotlinTypeName(nullable = kotlinParameter.isNullable())
        )
    }

    private fun processStringParameter(
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        funSpec: FunSpec.Builder
    ) {
        funSpec.addParameter(
            parameter.getName(),
            String::class.asClassName().copy(nullable = kotlinParameter.isNullable())
        )
    }

    private fun processFunctionParameter(
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
            .addStatement(
                "val args = arrayOf<%T>(",
                ClassName(
                    nimbusPackage,
                    "JSEncodable"
                ).parameterizedBy(serializedOutputType).nullable(true)
            )
            .indent()
            .add(
                "%T(%NId),\n",
                ClassName(
                    nimbusPackage,
                    "PrimitiveJSONEncodable"
                ),
                parameter.simpleName
            )

        // loop through each argument (except for last)
        // and add to the array created above
        declaredType.typeArguments.dropLast(1).forEachIndexed { index, functionParameterType ->

            // try to get the type from the kotlin class metadata
            // to determine if it is nullable
            val kotlinType = kotlinParameterType?.arguments?.get(index)
            val kotlinTypeNullable = kotlinType.isNullable()

            // function to wrap a value in a PrimitiveJSONEncodable if needed
            val wrapValueInPrimitiveJSONEncodable = {
                argBlock.add(
                    if (kotlinTypeNullable) {
                        "arg$index?.let { %T(arg$index) }"
                    } else {
                        "%T(arg$index)"
                    },
                    ClassName(
                        nimbusPackage,
                        "PrimitiveJSONEncodable"
                    )
                )
            }

            if (functionParameterType.kind == TypeKind.WILDCARD) {
                val wildcardParameterType = (functionParameterType as WildcardType).superBound
                // if it does not then we nee to wrap it in a PrimitiveJSONEncodable
                when {

                    // if the parameter implements JSONSerializable we are good
                    wildcardParameterType.isJSONEncodableType() -> argBlock.add("arg$index")

                    // if the parameter is serializable then wrap it in a KotlinJSONEncodable
                    wildcardParameterType.isKotlinSerializableType() -> argBlock.add(
                        if (kotlinTypeNullable) {
                            "arg$index?.let { %T(arg$index, %T.serializer()) }"
                        } else {
                            "%T(arg$index, %T.serializer())"
                        },
                        ClassName(
                            nimbusPackage,
                            "KotlinJSONEncodable"
                        ),
                        functionParameterType.superBound.asRawTypeName()
                    )
                    else -> wrapValueInPrimitiveJSONEncodable()
                }
            } else {
                wrapValueInPrimitiveJSONEncodable()
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
            CodeBlock.of(
                "runtime?.invoke(%S, %N, null)",
                "__nimbus.callCallback",
                "args"
            )
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
            .beginControlFlow(
                "val %N: %T = { ${declaredType.typeArguments.dropLast(
                    1
                ).mapIndexed { index, _ -> "arg$index" }.joinToString(
                    separator = ", "
                )} ->",
                parameter.simpleName,
                lambdaType
            )
            .add("%L", invoke.build())
            .endControlFlow()

        funSpec.addCode(lambda.build())
    }

    private fun processListParameter(
        declaredType: DeclaredType,
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        funSpec: FunSpec.Builder
    ) {
        // TODO handle @Serializable
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

    private fun processMapParameter(
        declaredType: DeclaredType,
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        funSpec: FunSpec.Builder
    ) {
        // TODO handle @Serializable
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

    private fun processOtherDeclaredParameter(
        declaredType: DeclaredType,
        parameter: VariableElement,
        funSpec: FunSpec.Builder
    ) {
        when {
            declaredType.isJSONEncodableType() -> {
                val companion = processingEnv.typeUtils.asElement(declaredType).enclosedElements.find { it.getName() == "Companion" }
                val hasFromJson = companion?.enclosedElements?.any { it.getName() == "fromJSON" } ?: false

                // convert from json if there is a fromJSON function
                if (hasFromJson) {
                    funSpec.addParameter(
                        "${parameter.getName()}String",
                        String::class
                    )
                    funSpec.addStatement(
                        "val %N = %T.fromJSON(%NString)",
                        parameter.simpleName,
                        parameter.asKotlinTypeName(),
                        parameter.simpleName
                    )
                } else {
                    error(
                        parameter,
                        "Class for parameter ${parameter.simpleName} must have a static fromJSON function."
                    )
                }
            }
            declaredType.isKotlinSerializableType() -> {
                funSpec.addParameter(
                    "${parameter.getName()}String",
                    String::class
                )
                funSpec.addStatement(
                    "val %N = %T(%T.Stable).parse(%T.serializer(), %NString)",
                    parameter.simpleName,
                    ClassName("kotlinx.serialization.json", "Json"),
                    ClassName("kotlinx.serialization.json", "JsonConfiguration"),
                    parameter.asKotlinTypeName(),
                    parameter.simpleName
                )
            }
        }
    }

    private fun processVoidReturnType(
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

    private fun processStringReturnType(
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

    private fun processOtherDeclaredReturnType(
        functionElement: ExecutableElement,
        argsString: String,
        kotlinReturnType: KmType?,
        funSpec: FunSpec.Builder
    ) {
        val functionReturnType = functionElement.returnType
        when {

            // if the parameter implements JSONSerializable we are good
            functionReturnType.isJSONEncodableType() -> {

                // stringify the return value
                funSpec.apply {
                    addStatement(
                        "val json = target.%N($argsString).encode()",
                        functionElement.getName()
                    )
                    addStatement("return json")
                    returns(String::class)
                }
            }
            functionReturnType.isKotlinSerializableType() -> {
                funSpec.apply {
                    addStatement(
                        "val json = %T(%T.Stable).stringify(%T.serializer(), target.%N($argsString))",
                        ClassName("kotlinx.serialization.json", "Json"),
                        ClassName("kotlinx.serialization.json", "JsonConfiguration"),
                        functionElement.returnType,
                        functionElement.getName()
                    )
                    addStatement("return json")
                    returns(String::class)
                }
            }
            else -> {

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
    }
}
