package com.salesforce.nimbus.bridge.webview.compiler

import com.salesforce.nimbus.compiler.BinderGenerator
import com.salesforce.nimbus.compiler.asKotlinTypeName
import com.salesforce.nimbus.compiler.asRawTypeName
import com.salesforce.nimbus.compiler.asTypeName
import com.salesforce.nimbus.compiler.getName
import com.salesforce.nimbus.compiler.isNullable
import com.salesforce.nimbus.compiler.nimbusPackage
import com.salesforce.nimbus.compiler.nullable
import com.salesforce.nimbus.compiler.toKotlinTypeName
import com.salesforce.nimbus.compiler.typeArguments
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

    private val jsonSerializationClassName = ClassName("kotlinx.serialization.json", "Json")
    private val jsonSerializationConfigurationClassName = ClassName("kotlinx.serialization.json", "JsonConfiguration")

    private val jsonObjectClassName = ClassName("org.json", "JSONObject")

    private val toJSONEncodableFunctionName = ClassName(nimbusPackage, "toJSONEncodable")
    private val kotlinJSONEncodableClassName = ClassName(nimbusPackage, "KotlinJSONEncodable")

    override fun createBinderExtensionFunction(pluginElement: Element, binderClassName: ClassName): FunSpec {
        return FunSpec.builder("webViewBinder")
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
                TypeKind.ARRAY -> processArrayParameter(parameter, kotlinParameter, funSpec)
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
                    returnType.isStringType() -> processStringReturnType(
                        functionElement,
                        argsString,
                        kotlinReturnType,
                        funSpec
                    )
                    returnType.isListType() -> processListReturnType(
                        functionElement,
                        returnType as DeclaredType,
                        argsString,
                        funSpec
                    )
                    returnType.isMapType() -> processMapReturnType(
                        functionElement,
                        returnType as DeclaredType,
                        argsString,
                        funSpec
                    )
                    returnType.isJSONEncodableType() -> processJSONEncodableReturnType(
                        functionElement,
                        argsString,
                        funSpec
                    )
                    returnType.isKotlinSerializableType() -> processKotlinSerializableReturnType(
                        functionElement,
                        argsString,
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
            TypeKind.ARRAY -> processArrayReturnType(
                functionElement,
                argsString,
                funSpec
            )
            else -> {
                funSpec.addStatement(
                    "return target.%N($argsString)",
                    functionElement.simpleName.toString()
                )
                funSpec.returns(functionElement.returnType.asKotlinTypeName(nullable = kotlinReturnType.isNullable()))
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

    private fun processArrayParameter(
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
            parameter.asType().typeArguments().first().toKotlinTypeName(parameterNullable),
            parameter.simpleName
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

        // Check if there are more than two parameters in callback. Only two parameters (result, error) are allowed.
        if (declaredType.typeArguments.size > 3) { // one type is for the return type (should be void)
            error(parameter, "Only two parameters are allowed in callbacks.")
            return
        }

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
                        kotlinJSONEncodableClassName,
                        functionParameterType.superBound.asRawTypeName()
                    )

                    wildcardParameterType.isArrayType() -> {
                        val arrayType = wildcardParameterType.typeArguments().first()
                        when {
                            arrayType.isKotlinSerializableType() -> {
                                argBlock.add(
                                    "%T(arg$index, %T(%T.serializer()))",
                                    kotlinJSONEncodableClassName,
                                    arraySerializerClassName,
                                    arrayType
                                )
                            }
                            else -> {
                                argBlock.add(
                                    "arg$index.%T()",
                                    toJSONEncodableFunctionName
                                )
                            }
                        }
                    }

                    wildcardParameterType.isListType() -> {
                        val listValueType = (wildcardParameterType as DeclaredType).typeArguments.first()
                        when {
                            listValueType.isKotlinSerializableType() -> {
                                argBlock.add(
                                    "%T(arg$index, %T(%T.serializer()))",
                                    kotlinJSONEncodableClassName,
                                    listSerializerClassName,
                                    listValueType.asKotlinTypeName()
                                )
                            }
                            else -> {
                                argBlock.add(
                                    "arg$index.%T()",
                                    toJSONEncodableFunctionName
                                )
                            }
                        }
                    }

                    wildcardParameterType.isMapType() -> {
                        val mapTypeArguments = (wildcardParameterType as DeclaredType).typeArguments
                        val mapKeyType = mapTypeArguments[0]
                        val mapValueType = mapTypeArguments[1]

                        // we only allow string key types
                        if (!mapKeyType.isStringType()) {
                            error(parameter, "$mapKeyType is an invalid map key type. Only String is supported.")
                            return
                        }

                        when {
                            mapValueType.isKotlinSerializableType() -> {
                                argBlock.add(
                                    "%T(arg$index, %T(%T.serializer(), %T.serializer()))",
                                    kotlinJSONEncodableClassName,
                                    mapSerializerClassName,
                                    String::class,
                                    mapValueType.asKotlinTypeName()
                                )
                            }
                            else -> {
                                argBlock.add(
                                    "arg$index.%T()",
                                    toJSONEncodableFunctionName
                                )
                            }
                        }
                    }
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
        val parameterNullable = kotlinParameter?.type?.arguments?.firstOrNull().isNullable()
        val listType = declaredType.typeArguments.first()
        if (listType.isKotlinSerializableType()) {
            funSpec.addParameter(
                parameter.simpleName.toString() + "String",
                String::class
            )
            funSpec.addStatement(
                "val %N = %T(%T.Stable).parse(%T(%T.serializer()), %NString)",
                parameter.simpleName,
                jsonSerializationClassName,
                jsonSerializationConfigurationClassName,
                listSerializerClassName,
                listType.asKotlinTypeName(),
                parameter.simpleName
            )
        } else {
            funSpec.addParameter(
                parameter.simpleName.toString() + "String",
                String::class
            )
            funSpec.addStatement(
                "val %N = %T<%T>(%NString)",
                parameter.simpleName,
                ClassName(nimbusPackage, "listFromJSON"),
                listType.asKotlinTypeName(nullable = parameterNullable),
                parameter.simpleName
            )
        }
    }

    private fun processMapParameter(
        declaredType: DeclaredType,
        parameter: VariableElement,
        kotlinParameter: KmValueParameter?,
        funSpec: FunSpec.Builder
    ) {
        val keyParameterType = declaredType.typeArguments[0]
        val valueParameterType = declaredType.typeArguments[1]

        // we only support string keys in maps
        if (!keyParameterType.isStringType()) {
            error(parameter, "$keyParameterType is an invalid map key type. Only String is supported.")
            return
        }

        if (valueParameterType.isKotlinSerializableType()) {
            funSpec.addParameter(
                parameter.simpleName.toString() + "String",
                String::class
            )
            funSpec.addStatement(
                "val %N = %T(%T.Stable).parse(%T(%T.serializer(), %T.serializer()), %NString)",
                parameter.simpleName,
                jsonSerializationClassName,
                jsonSerializationConfigurationClassName,
                mapSerializerClassName,
                String::class,
                valueParameterType.asKotlinTypeName(),
                parameter.simpleName
            )
        } else {
            val keyParameterNullable = kotlinParameter?.type?.arguments?.get(0).isNullable()
            val valueParameterNullable = kotlinParameter?.type?.arguments?.get(1).isNullable()
            funSpec.addParameter(
                parameter.simpleName.toString() + "String",
                String::class
            )
            funSpec.addStatement(
                "val %N = %T<%T, %T>(%NString)",
                parameter.simpleName,
                ClassName(nimbusPackage, "mapFromJSON"),
                keyParameterType.asKotlinTypeName(nullable = keyParameterNullable),
                valueParameterType.asKotlinTypeName(nullable = valueParameterNullable),
                parameter.simpleName
            )
        }
    }

    private fun processOtherDeclaredParameter(
        declaredType: DeclaredType,
        parameter: VariableElement,
        funSpec: FunSpec.Builder
    ) {
        when {
            declaredType.isJSONEncodableType() -> {
                val companion =
                    processingEnv.typeUtils.asElement(declaredType).enclosedElements.find { it.getName() == "Companion" }
                val hasDecode = companion?.enclosedElements?.any { it.getName() == "decode" }
                    ?: false

                // convert from json if there is a decode function
                if (hasDecode) {
                    funSpec.addParameter(
                        "${parameter.getName()}String",
                        String::class
                    )
                    funSpec.addStatement(
                        "val %N = %T.decode(%NString)",
                        parameter.simpleName,
                        parameter.asKotlinTypeName(),
                        parameter.simpleName
                    )
                } else {
                    error(
                        parameter,
                        "Class for parameter ${parameter.simpleName} must have a static decode() function."
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
                    jsonSerializationClassName,
                    jsonSerializationConfigurationClassName,
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
                jsonObjectClassName,
                functionElement.simpleName.toString()
            )
            returns(functionElement.returnType.asKotlinTypeName(nullable = kotlinReturnType.isNullable()))
        }
    }

    private fun processListReturnType(
        functionElement: ExecutableElement,
        returnType: DeclaredType,
        argsString: String,
        funSpec: FunSpec.Builder
    ) {
        val parameterType = returnType.typeArguments.first()
        when {
            parameterType.isKotlinSerializableType() -> {
                funSpec.apply {
                    addStatement(
                        "val json = %T(%T.Stable).stringify(%T(%T.%T()), target.%N($argsString))",
                        jsonSerializationClassName,
                        jsonSerializationConfigurationClassName,
                        listSerializerClassName,
                        parameterType.asKotlinTypeName(),
                        serializerFunctionName,
                        functionElement.getName()
                    )
                    addStatement("return json")
                    returns(String::class)
                }
            }
            else -> {
                funSpec.apply {
                    addCode(
                        CodeBlock.Builder().apply {
                            addStatement(
                                "val json = target.%N($argsString).%T().encode()",
                                functionElement.getName(),
                                toJSONEncodableFunctionName
                            )
                            addStatement("return json")
                            returns(String::class)
                        }.build()
                    )
                }
            }
        }
    }

    private fun processArrayReturnType(
        functionElement: ExecutableElement,
        argsString: String,
        funSpec: FunSpec.Builder
    ) {
        val arrayType = functionElement.returnType.typeArguments().first()
        when {
            arrayType.isKotlinSerializableType() -> {
                funSpec.apply {
                    addStatement(
                        "val json = %T(%T.Stable).stringify(%T(%T.%T()), target.%N($argsString))",
                        jsonSerializationClassName,
                        jsonSerializationConfigurationClassName,
                        arraySerializerClassName,
                        arrayType,
                        serializerFunctionName,
                        functionElement.getName()
                    )
                    addStatement("return json")
                    returns(String::class)
                }
            }
            else -> {
                funSpec.apply {
                    addCode(
                        CodeBlock.Builder().apply {
                            addStatement(
                                "val json = target.%N($argsString).%T().encode()",
                                functionElement.getName(),
                                toJSONEncodableFunctionName
                            )
                            addStatement("return json")
                            returns(String::class)
                        }.build()
                    )
                }
            }
        }
    }

    private fun processMapReturnType(
        functionElement: ExecutableElement,
        returnType: DeclaredType,
        argsString: String,
        funSpec: FunSpec.Builder
    ) {
        val keyParameterType = returnType.typeArguments[0]
        val valueParameterType = returnType.typeArguments[1]

        // we only allow string key types
        if (!keyParameterType.isStringType()) {
            error(functionElement, "$keyParameterType is an invalid map key type. Only String is supported.")
            return
        }

        when {
            valueParameterType.isKotlinSerializableType() -> {
                funSpec.apply {
                    addStatement(
                        "val json = %T(%T.Stable).stringify(%T(%T.%T(), %T.%T()), target.%N($argsString))",
                        jsonSerializationClassName,
                        jsonSerializationConfigurationClassName,
                        mapSerializerClassName,
                        keyParameterType.asKotlinTypeName(),
                        serializerFunctionName,
                        valueParameterType.asKotlinTypeName(),
                        serializerFunctionName,
                        functionElement.getName()
                    )
                    addStatement("return json")
                    returns(String::class)
                }
            }
            else -> {
                funSpec.apply {
                    addCode(
                        CodeBlock.Builder().apply {
                            addStatement(
                                "val json = target.%N($argsString).%T().encode()",
                                functionElement.getName(),
                                toJSONEncodableFunctionName
                            )
                            addStatement("return json")
                            returns(String::class)
                        }.build()
                    )
                }
            }
        }
    }

    private fun processJSONEncodableReturnType(
        functionElement: ExecutableElement,
        argsString: String,
        funSpec: FunSpec.Builder
    ) {
        funSpec.apply {
            addStatement(
                "val json = target.%N($argsString).encode()",
                functionElement.getName()
            )
            addStatement("return json")
            returns(String::class)
        }
    }

    private fun processKotlinSerializableReturnType(
        functionElement: ExecutableElement,
        argsString: String,
        funSpec: FunSpec.Builder
    ) {
        funSpec.apply {
            addStatement(
                "val json = %T(%T.Stable).stringify(%T.serializer(), target.%N($argsString))",
                jsonSerializationClassName,
                jsonSerializationConfigurationClassName,
                functionElement.returnType,
                functionElement.getName()
            )
            addStatement("return json")
            returns(String::class)
        }
    }

    private fun processOtherDeclaredReturnType(
        functionElement: ExecutableElement,
        argsString: String,
        kotlinReturnType: KmType?,
        funSpec: FunSpec.Builder
    ) {

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
