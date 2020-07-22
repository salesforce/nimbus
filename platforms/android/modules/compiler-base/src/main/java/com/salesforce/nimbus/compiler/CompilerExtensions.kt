//
// Copyright (c) 2020, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbus.compiler

import com.squareup.kotlinpoet.BOOLEAN
import com.squareup.kotlinpoet.BYTE
import com.squareup.kotlinpoet.CHAR
import com.squareup.kotlinpoet.ClassName
import com.squareup.kotlinpoet.DOUBLE
import com.squareup.kotlinpoet.FLOAT
import com.squareup.kotlinpoet.INT
import com.squareup.kotlinpoet.LIST
import com.squareup.kotlinpoet.LONG
import com.squareup.kotlinpoet.LambdaTypeName
import com.squareup.kotlinpoet.MAP
import com.squareup.kotlinpoet.ParameterizedTypeName
import com.squareup.kotlinpoet.ParameterizedTypeName.Companion.parameterizedBy
import com.squareup.kotlinpoet.SHORT
import com.squareup.kotlinpoet.STRING
import com.squareup.kotlinpoet.TypeName
import com.squareup.kotlinpoet.UNIT
import com.squareup.kotlinpoet.WildcardTypeName
import com.squareup.kotlinpoet.asTypeName
import kotlinx.metadata.Flag
import kotlinx.metadata.KmType
import kotlinx.metadata.KmTypeProjection
import kotlinx.metadata.KmValueParameter
import javax.annotation.processing.ProcessingEnvironment
import javax.lang.model.element.Element
import javax.lang.model.element.ElementKind
import javax.lang.model.type.TypeMirror

/**
 * Converts a Java [TypeName] to a Kotlin [TypeName]
 */
fun TypeName.toKotlinTypeName(nullable: Boolean = false): TypeName {
    return when (this) {
        is ClassName -> when (packageName) {
            "java.lang" -> when (simpleName) {
                "String" -> STRING
                "Void" -> UNIT
                "Boolean" -> BOOLEAN
                "Byte" -> BYTE
                "Character" -> CHAR
                "Short" -> SHORT
                "Integer" -> INT
                "Long" -> LONG
                "Float" -> FLOAT
                "Double" -> DOUBLE
                else -> this
            }
            "java.util" -> when (simpleName) {
                "List" -> LIST
                "Map" -> MAP
                else -> this
            }
            else -> this
        }
        is ParameterizedTypeName -> (rawType.toKotlinTypeName(nullable) as ClassName).parameterizedBy(typeArguments.map { it.toKotlinTypeName() })
        is LambdaTypeName -> LambdaTypeName.get(
            receiver?.toKotlinTypeName(),
            parameters.map { it.toBuilder(type = it.type.toKotlinTypeName()).build() },
            returnType.toKotlinTypeName()
        )
        is WildcardTypeName -> {
            if (inTypes.isNotEmpty()) WildcardTypeName.consumerOf(inTypes[0].toKotlinTypeName())
            else WildcardTypeName.producerOf(outTypes[0].toKotlinTypeName())
        }
        else -> this
    }.copy(nullable = nullable) // make the type nullable
}

/**
 * Converts a Java [TypeMirror] to a Kotlin [TypeName]
 */
fun TypeMirror.asKotlinTypeName(nullable: Boolean = false) = asTypeName().toKotlinTypeName(nullable = nullable)

/**
 * Converts a Java [TypeMirror] to a raw Kotlin [TypeName]
 */
fun TypeMirror.asRawTypeName(nullable: Boolean = false): TypeName {
    val typeName = asTypeName().toKotlinTypeName(nullable)
    return if (typeName is ParameterizedTypeName) {
        typeName.rawType.toKotlinTypeName(nullable)
    } else {
        typeName
    }
}

/**
 * Converts a Java [TypeName] from the [Element] to a Kotlin [TypeName]
 */
fun Element.asKotlinTypeName(nullable: Boolean = false) = asType().asKotlinTypeName(nullable = nullable)

/**
 * Converts an [Element] to a [TypeName]
 */
fun Element.asTypeName() = asType().asTypeName()

/**
 * Converts an [Element] to a raw [TypeName]
 */
fun Element.asRawTypeName(): TypeName {
    val typeName = asType().asTypeName()
    return if (typeName is ParameterizedTypeName) {
        typeName.rawType.toKotlinTypeName()
    } else {
        typeName.toKotlinTypeName()
    }
}

/**
 * Gets the string version of the [Element.getSimpleName]
 */
fun Element.getName() = simpleName.toString()

/**
 * Checks the flags on a [KmType] to determine if the type is nullable
 */
fun KmType?.isNullable(): Boolean = this?.let { Flag.Type.IS_NULLABLE(flags) } ?: false

/**
 * Checks the flags on the [KmType] of the [KmValueParameter] to determine if the type is nullable
 */
fun KmValueParameter?.isNullable(): Boolean = this?.type.isNullable()

/**
 * Checks the flags on the [KmType] of the [KmTypeProjection] to determine if the type is nullable
 */
fun KmTypeProjection?.isNullable(): Boolean = this?.type.isNullable()

/**
 * Convenience function to toggle the nullability of a [TypeName]
 */
fun TypeName.nullable(nullable: Boolean) = copy(nullable = nullable)

/**
 * Convenience function to get the type arguments for a [TypeMirror]
 */
fun TypeMirror.typeArguments(): List<TypeName> = asKotlinTypeName().typeArguments()

/**
 * Convenience function to get the type arguments for a [TypeName].
 */
fun TypeName.typeArguments(): List<TypeName> {
    return if (this is ParameterizedTypeName) {
        typeArguments
    } else {
        emptyList()
    }
}

/**
 * Convenience function to retrieve an [Annotation] from an [Element] by either getting it directly
 * from the [Element] if it is a [ElementKind.CLASS] or getting it from the [ProcessingEnvironment].
 */
inline fun <reified T : Annotation> Element.annotation(env: ProcessingEnvironment): T? = if (kind == ElementKind.CLASS) {
    getAnnotation(T::class.java)
} else {
    env.elementUtils.getTypeElement(asType().toString()).getAnnotation(T::class.java)
}

/**
 * Convenience function to retrieve the class name of an [Element] by either getting it directly
 * from the [Element] if it is a [ElementKind.CLASS] or getting it from the [ProcessingEnvironment].
 */
fun Element.className(env: ProcessingEnvironment) = if (kind == ElementKind.CLASS) {
    getName()
} else {
    env.elementUtils.getTypeElement(asType().toString()).getName()
}

/**
 * Convenience function to retrieve the [ElementKind.METHOD] [Element]s from an [Element] by either
 * getting it directly from the [Element] if it is a [ElementKind.CLASS] or getting it from the
 * [ProcessingEnvironment].
 */
fun Element.methodElements(env: ProcessingEnvironment): List<Element> {
    val elements = if (kind == ElementKind.CLASS) {
        enclosedElements
    } else {
        env.elementUtils.getTypeElement(asType().toString()).enclosedElements
    }
    return elements.filter { it.kind == ElementKind.METHOD }
}
