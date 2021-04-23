//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.bridge.v8.compiler

import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.PluginOptions
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_K2V8
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_K2V8_CONFIGURATION
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_K2V8_TO_V8_ARRAY
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_KOTLIN_PROMISE
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_NIMBUS_BRIDGE
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_NIMBUS_PLUGINS
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_REGISTER_JAVA_CALLBACK
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_REJECT_PROMISE
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_RESOLVE_PROMISE
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_V8Function
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_V8Object
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_V8Releasable
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.addClassProperties
import com.salesforce.nimbus.compiler.*
import com.squareup.kotlinpoet.*
import kotlinx.metadata.KmFunction
import kotlinx.metadata.KmValueParameter
import javax.annotation.processing.ProcessingEnvironment
import javax.lang.model.element.Element
import javax.lang.model.element.ExecutableElement
import javax.lang.model.element.VariableElement
import javax.lang.model.type.ArrayType
import javax.lang.model.type.DeclaredType
import javax.lang.model.type.TypeKind
import javax.lang.model.type.WildcardType


class V8BinderGenerator : BinderGenerator() {
    override val javascriptEngine = V8BinderGeneratorHelper.CLASS_NAME_V8
    override val serializedOutputType = CLASS_NAME_V8Object

    override fun shouldGenerateBinder(
        environment: ProcessingEnvironment,
        pluginElement: Element
    ): Boolean {
        return pluginElement.annotation<PluginOptions>(processingEnv)!!.supportsV8
    }

    override fun processClassProperties(builder: TypeSpec.Builder) {
        // add k2v8 property so we can serialize to/from v8
        addClassProperties(builder)
    }

    override fun processUnbindFunction(builder: FunSpec.Builder) {
        builder.addStatement("offV8ExecutorService.shutdownNow()")
    }

    override fun processBindFunction(
        boundMethodElements: List<ExecutableElement>,
        builder: FunSpec.Builder
    ) {
        val codeBlock = CodeBlock.builder()
            .addStatement("val v8 = runtime.getJavascriptEngine()")
            .beginControlFlow("if (v8 != null) {")

            // create our K2V8 instance
            .addStatement(
                "this.k2v8 = %T(%T(v8))",
                CLASS_NAME_K2V8,
                CLASS_NAME_K2V8_CONFIGURATION
            )

            // grab the nimbus object
            .addStatement("val nimbus = v8.getObject(%T)", CLASS_NAME_NIMBUS_BRIDGE)

            // grab the plugins array
            .addStatement("val plugins = nimbus.getObject(%T)", CLASS_NAME_NIMBUS_PLUGINS)


            // create our plugin bridge and add our callback methods
            .beginControlFlow(
                "%T(v8).apply {",
                CLASS_NAME_V8Object
            )

            // register a v8 java callback for each bound method
            .apply {
                boundMethodElements.forEach { boundMethod ->
                    addStatement(
                        "%T(\"%N\", ::%N)",
                        CLASS_NAME_REGISTER_JAVA_CALLBACK,
                        boundMethod.getName(),
                        boundMethod.getName()
                    )
                }
            }
            .endControlFlow()

            // add the plugin to the nimbus plugins
            .beginControlFlow(".use")
            .addStatement("plugins.add(\"\$pluginName\", it)")
            .endControlFlow()

            // need to close the nimbus object
            .addStatement("nimbus.close()")

            // need to close the plugins object
            .addStatement("plugins.close()")

            .endControlFlow()

        // add code block to the bind function
        builder.addCode(codeBlock.build())
    }

    override fun createBinderExtensionFunction(
        pluginElement: Element,
        classModifiers: Set<KModifier>,
        binderClassName: ClassName
    ): FunSpec {
        return FunSpec.builder("v8Binder")
            .receiver(pluginElement.asTypeName())
            .addModifiers(classModifiers)
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

        // Setting Default Function modifier to Private for V8Binder
        val funModifier = kotlinFunction?.let(::processFunctionModifierTypes) ?: KModifier.PRIVATE

        val funSpec = FunSpec.builder(functionName)
            .addModifiers(funModifier)
            .addParameter(
                parameters,
                V8BinderGeneratorHelper.CLASS_NAME_V8Array
            )
        val funBody = CodeBlock.builder()
            .addStatement(
                "val v8 = runtime?.getJavascriptEngine() as %T",
                V8BinderGeneratorHelper.CLASS_NAME_V8
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
                        declaredType.isStringType() -> processStringParameter(
                            parameter,
                            parameterIndex
                        )
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
                                else -> processFunctionParameter(
                                    declaredType,
                                    parameter,
                                    kotlinParameter,
                                    parameterIndex
                                )
                            }
                        }
                        declaredType.isListType() -> processListParameter(
                            declaredType,
                            parameter,
                            kotlinParameter,
                            parameterIndex
                        )
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
                            } else processMapParameter(
                                declaredType,
                                parameter,
                                kotlinParameter,
                                parameterIndex
                            )
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
            .addStatement("val promise = %T.newPromise(v8)", CLASS_NAME_KOTLIN_PROMISE)
            .beginControlFlow("offV8ExecutorService.submit")
            .addStatement(
                "val result = target.%N($argsString)",
                functionElement.getName()
            )
            .beginControlFlow("runtime!!.getExecutorService().submit {")
            // process the result (may need to serialize)
            .add(processResult(functionElement))
            .addStatement("")
            .endControlFlow()
            .endControlFlow()
            .addStatement("promise.getJsPromise()")

        // close out the try {} catch and reject the promise if we encounter an exception
        funBody.nextControlFlow("catch (throwable: Throwable)")

        val exceptions = functionElement.getAnnotation(BoundMethod::class.java)
            ?.getExceptions() ?: emptyList()

        // if we have any exceptions we will check if they are serializable
        if (exceptions.isNotEmpty()) {
            funBody.apply {
                addStatement("when (throwable) {")
                indent()
                exceptions.filter { it.isKotlinSerializableType() }.forEach { exception ->
                    addStatement(
                        "is %T -> v8.%T(k2v8!!.toV8(%T.%T(), throwable))",
                        exception,
                        CLASS_NAME_REJECT_PROMISE,
                        exception,
                        serializerFunctionName
                    )
                }
                addStatement(
                    "else -> v8.%T(throwable.message ?: \"Error\")",
                    CLASS_NAME_REJECT_PROMISE
                )
                unindent()
                addStatement("}")
            }
        } else {
            funBody.addStatement(
                "v8.%T(throwable.message ?: \"Error\")", // TODO what default error message?
                CLASS_NAME_REJECT_PROMISE
            )
        }
        funBody.endControlFlow()

        // add our function body and return a V8Object
        funSpec
            .addCode(funBody.build())
            .returns(CLASS_NAME_V8Object)

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
                CLASS_NAME_V8Function
            )

        // try to get the parameter type from the kotlin class
        // metadata to determine if it is nullable
        val kotlinParameterType = kotlinParameter?.type


        // create the callback function body
        val argBlock = CodeBlock.builder()
            .beginControlFlow("runtime!!.getExecutorService().submit {")
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
                        val wildcardParameterType =
                            (functionParameterType as WildcardType).superBound
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
                """params.%T(v8).use { callback$parameterIndex.call(v8, it) }""",
                CLASS_NAME_K2V8_TO_V8_ARRAY)
            .addStatement("params.forEach { (it as? %T)?.close() }", CLASS_NAME_V8Releasable)
            .endControlFlow()

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
                "val ${parameter.getName()}: %T = { ${
                    declaredType.typeArguments.dropLast(
                        1
                    ).mapIndexed { index, _ -> "p$index" }.joinToString(
                        separator = ", "
                    )
                } ->",
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
                    returnType.isStringType() -> CodeBlock.of("v8.%T(result)", CLASS_NAME_RESOLVE_PROMISE)
                    returnType.isKotlinSerializableType() -> CodeBlock.of(
                        "k2v8!!.toV8(%T.%T(), result).use { promise.resolve(it) }",
                        returnType,
                        serializerFunctionName)
                    returnType.isListType() -> {
                        val parameterType = returnType.typeArguments.first().asKotlinTypeName()
                        CodeBlock.of(
                            "k2v8!!.toV8(%T(%T.%T()), result).use { promise.resolve(it) }",
                            listSerializerClassName,
                            parameterType,
                            serializerFunctionName
                        )
                    }
                    returnType.isMapType() -> {
                        val keyParameterType = returnType.typeArguments[0].asKotlinTypeName()
                        val valueParameterType = returnType.typeArguments[1].asKotlinTypeName()
                        CodeBlock.of(
                            "k2v8!!.toV8(%T(%T.%T(), %T.%T()), result).use { promise.resolve(it) }",
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
                    "k2v8!!.toV8(%T(%T.%T()), result).use { promise.resolve(it) }",
                    arraySerializerClassName,
                    arrayType,
                    serializerFunctionName
                )
            }
            // if a primitive type just return the result
            else -> CodeBlock.of("promise.resolve(result)")
        }
    }
}
