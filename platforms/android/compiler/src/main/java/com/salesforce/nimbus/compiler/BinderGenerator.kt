package com.salesforce.nimbus.compiler

import com.squareup.kotlinpoet.ClassName
import com.squareup.kotlinpoet.FunSpec
import com.squareup.kotlinpoet.TypeSpec
import kotlinx.metadata.KmFunction
import javax.annotation.processing.Messager
import javax.lang.model.element.Element
import javax.lang.model.element.ExecutableElement
import javax.lang.model.util.Types

/**
 * Interface for a class which generates a Binder class for a Plugin.
 */
interface BinderGenerator {
    val javascriptEngineClassName: ClassName
    val encodedType: ClassName
    val bridgeClassName: ClassName
    var messager: Messager?

    fun processClassProperties(builder: TypeSpec.Builder) {
        /* do nothing by default */
    }

    fun processBindFunction(
        boundMethodElements: List<ExecutableElement>,
        builder: FunSpec.Builder
    ) {
        /* do nothing by default */
    }

    fun processUnbindFunction(builder: FunSpec.Builder) {
        /* do nothing by default */
    }

    fun processFunctionElement(
        types: Types,
        functionElement: ExecutableElement,
        serializableElements: Set<Element>,
        kotlinFunction: KmFunction?
    ): FunSpec
}
