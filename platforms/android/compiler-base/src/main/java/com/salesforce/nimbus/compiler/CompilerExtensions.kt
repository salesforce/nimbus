package com.salesforce.nimbus.compiler

import com.squareup.kotlinpoet.BOOLEAN
import com.squareup.kotlinpoet.BYTE
import com.squareup.kotlinpoet.CHAR
import com.squareup.kotlinpoet.ClassName
import com.squareup.kotlinpoet.DOUBLE
import com.squareup.kotlinpoet.FLOAT
import com.squareup.kotlinpoet.INT
import com.squareup.kotlinpoet.LONG
import com.squareup.kotlinpoet.LambdaTypeName
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
import javax.lang.model.element.Element
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
            else -> this
        }
        is ParameterizedTypeName -> rawType.parameterizedBy(typeArguments.map { it.toKotlinTypeName() })
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
 * Converts a Java [TypeName] from the [Element] to a Kotlin [TypeName]
 */
fun Element.asKotlinType(nullable: Boolean = false) = asType().asKotlinTypeName(nullable = nullable)

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
 * Convenience function to toggle the nullability of a [ClassName]
 */
fun ClassName.nullable(nullable: Boolean) = copy(nullable = nullable)
