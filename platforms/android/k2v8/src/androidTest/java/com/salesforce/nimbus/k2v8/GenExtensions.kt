package com.salesforce.nimbus.k2v8

import io.kotlintest.properties.Gen
import java.util.Random

private val RANDOM = Random()
private fun Random.nextPrintableChar(): Char {
    val low = 32
    val high = 127
    return (nextInt(high - low) + low).toChar()
}

fun Gen.Companion.byte() = object : Gen<Byte> {
    val literals = listOf(Byte.MIN_VALUE, Byte.MAX_VALUE, 0)
    override fun constants(): Iterable<Byte> = literals
    override fun random(): Sequence<Byte> = generateSequence { RANDOM.nextInt().toByte() }
}

fun Gen.Companion.short() = object : Gen<Short> {
    val literals = listOf(Short.MIN_VALUE, Short.MAX_VALUE, 0)
    override fun constants(): Iterable<Short> = literals
    override fun random(): Sequence<Short> = generateSequence { RANDOM.nextInt().toShort() }
}

fun Gen.Companion.char() = object : Gen<Char> {
    val literals = listOf(Char.MIN_VALUE, Char.MAX_VALUE, 0.toChar())
    override fun constants(): Iterable<Char> = literals
    override fun random(): Sequence<Char> = generateSequence { RANDOM.nextPrintableChar() }
}
