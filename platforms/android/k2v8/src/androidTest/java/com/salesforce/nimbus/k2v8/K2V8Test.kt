package com.salesforce.nimbus.k2v8

import androidx.test.ext.junit.runners.AndroidJUnit4
import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
import com.eclipsesource.v8.V8Object
import com.google.common.truth.Truth.assertThat
import kotlinx.serialization.Serializable
import kotlinx.serialization.builtins.MapSerializer
import kotlinx.serialization.builtins.serializer
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

/**
 * Unit tests for [K2V8].
 */
@RunWith(AndroidJUnit4::class)
class K2V8Test {

    enum class Enum {
        VALUE_1,
        VALUE_2,
        VALUE_3
    }

    @Serializable
    data class SupportedTypes(
        val byte: Byte,
        val nullByte: Byte?,
        val nonNullByte: Byte?,
        val short: Short,
        val nullShort: Short?,
        val nonNullShort: Short?,
        val char: Char,
        val nullChar: Char?,
        val nonNullChar: Char?,
        val int: Int,
        val nullInt: Int?,
        val nonNullInt: Int?,
        val long: Long,
        val nullLong: Long?,
        val nonNullLong: Long?,
        val double: Double,
        val nullDouble: Double?,
        val nonNullDouble: Double?,
        val float: Float,
        val nullFloat: Float?,
        val nonNullFloat: Float?,
        val string: String,
        val nullString: String?,
        val nonNullString: String?,
        val boolean: Boolean,
        val nullBoolean: Boolean?,
        val nonNullBoolean: Boolean?,
        val enum: Enum,
        val nullEnum: Enum?,
        val unit: Unit,
        val nestedObject: NestedObject,
        val nullNestedObject: NestedObject?,
        val nonNullNestedObject: NestedObject?,
        val doubleNestedObject: DoubleNestedObject,
        val byteList: List<Byte>,
        val shortList: List<Short>,
        val charList: List<Char>,
        val intList: List<Int>,
        val longList: List<Long>,
        val floatList: List<Float>,
        val doubleList: List<Double>,
        val stringList: List<String>,
        val booleanList: List<Boolean>,
        val enumList: List<Enum>,
        val nestedObjectList: List<NestedObject>,
        val stringMap: Map<String, String>,
        val enumMap: Map<Enum, String>
    )

    @Serializable
    data class NestedObject(
        val value: String
    )

    @Serializable
    data class DoubleNestedObject(
        val nestedObject: NestedObject
    )

    private lateinit var v8: V8
    private lateinit var k2V8: K2V8

    @Before
    fun setUp() {
        v8 = V8.createV8Runtime()
        k2V8 = K2V8(Configuration(v8))
    }

    @Test
    fun testToV8() = v8.scope {
        val value = SupportedTypes(
            byte = Byte.MIN_VALUE,
            nullByte = null,
            nonNullByte = Byte.MAX_VALUE,
            short = Short.MIN_VALUE,
            nullShort = null,
            nonNullShort = Short.MAX_VALUE,
            char = Char.MIN_VALUE,
            nullChar = null,
            nonNullChar = Char.MAX_VALUE,
            int = Int.MIN_VALUE,
            nullInt = null,
            nonNullInt = Int.MAX_VALUE,
            long = Long.MIN_VALUE,
            nullLong = null,
            nonNullLong = Long.MAX_VALUE,
            double = Double.MIN_VALUE,
            nullDouble = null,
            nonNullDouble = Double.MAX_VALUE,
            float = Float.MIN_VALUE,
            nullFloat = null,
            nonNullFloat = Float.MAX_VALUE,
            string = "5.0",
            nullString = null,
            nonNullString = "nonNull",
            boolean = true,
            nullBoolean = null,
            nonNullBoolean = true,
            enum = Enum.VALUE_1,
            nullEnum = null,
            unit = Unit,
            nestedObject = NestedObject(
                "value"
            ),
            nullNestedObject = null,
            nonNullNestedObject = NestedObject(
                "value2"
            ),
            doubleNestedObject = DoubleNestedObject(
                NestedObject("value3")
            ),
            byteList = listOf(1.toByte(), 2.toByte(), 3.toByte()),
            shortList = listOf(1.toShort(), 2.toShort(), 3.toShort()),
            charList = listOf(1.toChar(), 2.toChar(), 3.toChar()),
            intList = listOf(1, 2, 3),
            longList = listOf(1L, 2L, 3L),
            floatList = listOf(1f, 2f, 3f),
            doubleList = listOf(1.0, 2.0, 3.0),
            stringList = listOf("1", "2", "3"),
            booleanList = listOf(true, false, true),
            enumList = listOf(
                Enum.VALUE_1,
                Enum.VALUE_2,
                Enum.VALUE_3
            ),
            nestedObjectList = listOf(
                NestedObject(
                    "value1"
                ),
                NestedObject("value2"),
                NestedObject("value3")
            ),
            stringMap = mapOf("key1" to "value1", "key2" to "value2", "key3" to "value3"),
            enumMap = mapOf(
                Enum.VALUE_1 to "value1",
                Enum.VALUE_2 to "value2",
                Enum.VALUE_3 to "value3"
            )
        )
        k2V8.toV8(SupportedTypes.serializer(), value).let { encoded ->

            // test primitive values

            // test byte
            assertThat(encoded.getInteger("byte")).isEqualTo(Byte.MIN_VALUE)
            assertThat(encoded.get("nullByte")).isNull()
            assertThat(encoded.getInteger("nonNullByte")).isEqualTo(Byte.MAX_VALUE)

            // test short
            assertThat(encoded.getInteger("short")).isEqualTo(Short.MIN_VALUE)
            assertThat(encoded.get("nullShort")).isNull()
            assertThat(encoded.getInteger("nonNullShort")).isEqualTo(Short.MAX_VALUE)

            // test char
            assertThat(encoded.getInteger("char")).isEqualTo(Char.MIN_VALUE)
            assertThat(encoded.get("nullChar")).isNull()
            assertThat(encoded.getInteger("nonNullChar")).isEqualTo(Char.MAX_VALUE)

            // test int
            assertThat(encoded.getInteger("int")).isEqualTo(Int.MIN_VALUE)
            assertThat(encoded.get("nullInt")).isNull()
            assertThat(encoded.getInteger("nonNullInt")).isEqualTo(Int.MAX_VALUE)

            // test long
            assertThat(encoded.getDouble("long")).isEqualTo(Long.MIN_VALUE.toDouble())
            assertThat(encoded.get("nullLong")).isNull()
            assertThat(encoded.getDouble("nonNullLong")).isEqualTo(Long.MAX_VALUE.toDouble())

            // test double
            assertThat(encoded.getDouble("double")).isEqualTo(Double.MIN_VALUE)
            assertThat(encoded.get("nullDouble")).isNull()
            assertThat(encoded.getDouble("nonNullDouble")).isEqualTo(Double.MAX_VALUE)

            // test float
            assertThat(encoded.getDouble("float")).isEqualTo(Float.MIN_VALUE.toDouble())
            assertThat(encoded.get("nullFloat")).isNull()
            assertThat(encoded.getDouble("nonNullFloat")).isEqualTo(Float.MAX_VALUE.toDouble())

            // test string
            assertThat(encoded.getString("string")).isEqualTo("5.0")
            assertThat(encoded.get("nullString")).isNull()
            assertThat(encoded.get("nonNullString")).isEqualTo("nonNull")

            // test boolean
            assertThat(encoded.getBoolean("boolean")).isTrue()
            assertThat(encoded.get("nullBoolean")).isNull()
            assertThat(encoded.getBoolean("nonNullBoolean")).isTrue()

            // test enum
            assertThat(encoded.getString("enum")).isEqualTo("VALUE_1")
            assertThat(encoded.get("nullEnum")).isNull()

            // test unit
            assertThat(encoded.getObject("unit").isUndefined).isTrue()

            // test nested serializable object
            encoded.getObject("nestedObject").let { obj ->
                assertThat(obj.getString("value")).isEqualTo("value")
            }

            // test null nested serializable object
            assertThat(encoded.getObject("nullNestedObject")).isNull()

            // test non-null nullable serializable object
            encoded.getObject("nonNullNestedObject").let { obj ->
                assertThat(obj.getString("value")).isEqualTo("value2")
            }

            // test double nested serializable object
            encoded.getObject("doubleNestedObject").let { obj ->
                obj.getObject("nestedObject").let { obj2 ->
                    assertThat(obj2.getString("value")).isEqualTo("value3")
                }
            }

            // test byte list
            encoded.getObject("byteList").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    assertThat(getInteger(0)).isEqualTo(1)
                    assertThat(getInteger(1)).isEqualTo(2)
                    assertThat(getInteger(2)).isEqualTo(3)
                }
            }

            // test short list
            encoded.getObject("shortList").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    assertThat(getInteger(0)).isEqualTo(1)
                    assertThat(getInteger(1)).isEqualTo(2)
                    assertThat(getInteger(2)).isEqualTo(3)
                }
            }

            // test char list
            encoded.getObject("charList").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    assertThat(getInteger(0)).isEqualTo(1)
                    assertThat(getInteger(1)).isEqualTo(2)
                    assertThat(getInteger(2)).isEqualTo(3)
                }
            }

            // test int list
            encoded.getObject("intList").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    assertThat(getInteger(0)).isEqualTo(1)
                    assertThat(getInteger(1)).isEqualTo(2)
                    assertThat(getInteger(2)).isEqualTo(3)
                }
            }

            // test long list
            encoded.getObject("longList").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    assertThat(getInteger(0)).isEqualTo(1)
                    assertThat(getInteger(1)).isEqualTo(2)
                    assertThat(getInteger(2)).isEqualTo(3)
                }
            }

            // test float list
            encoded.getObject("floatList").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    assertThat(getDouble(0)).isEqualTo(1.0)
                    assertThat(getDouble(1)).isEqualTo(2.0)
                    assertThat(getDouble(2)).isEqualTo(3.0)
                }
            }

            // test double list
            encoded.getObject("doubleList").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    assertThat(getDouble(0)).isEqualTo(1.0)
                    assertThat(getDouble(1)).isEqualTo(2.0)
                    assertThat(getDouble(2)).isEqualTo(3.0)
                }
            }

            // test string list
            encoded.getObject("stringList").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    assertThat(getString(0)).isEqualTo("1")
                    assertThat(getString(1)).isEqualTo("2")
                    assertThat(getString(2)).isEqualTo("3")
                }
            }

            // test boolean list
            encoded.getObject("booleanList").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    assertThat(getBoolean(0)).isTrue()
                    assertThat(getBoolean(1)).isFalse()
                    assertThat(getBoolean(2)).isTrue()
                }
            }

            // test enum list
            encoded.getObject("enumList").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    assertThat(getString(0)).isEqualTo("VALUE_1")
                    assertThat(getString(1)).isEqualTo("VALUE_2")
                    assertThat(getString(2)).isEqualTo("VALUE_3")
                }
            }

            // test nested object list
            encoded.getObject("nestedObjectList").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    getObject(0).let { obj ->
                        assertThat(obj.getString("value")).isEqualTo("value1")
                    }
                    getObject(1).let { obj ->
                        assertThat(obj.getString("value")).isEqualTo("value2")
                    }
                    getObject(2).let { obj ->
                        assertThat(obj.getString("value")).isEqualTo("value3")
                    }
                }
            }

            // test string map
            encoded.getObject("stringMap").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    assertThat(getString("key1")).isEqualTo("value1")
                    assertThat(getString("key2")).isEqualTo("value2")
                    assertThat(getString("key3")).isEqualTo("value3")
                }
            }

            // test enum map
            encoded.getObject("enumMap").let { array ->
                assertThat(array).isInstanceOf(V8Array::class.java)
                with(array as V8Array) {
                    assertThat(getString("VALUE_1")).isEqualTo("value1")
                    assertThat(getString("VALUE_2")).isEqualTo("value2")
                    assertThat(getString("VALUE_3")).isEqualTo("value3")
                }
            }
        }
    }

    @Test
    fun testFromV8() = v8.scope {
        val nestedObject = V8Object(v8).apply {
            add("value", "value")
        }
        val nonNullNestedObject = V8Object(v8).apply {
            add("value", "value2")
        }
        val doubleNestedObject = V8Object(v8).apply {
            add("nestedObject", V8Object(v8).add("value", "value3"))
        }
        val byteList = V8Array(v8).apply {
            push(1.toByte())
            push(2.toByte())
            push(3.toByte())
        }
        val shortList = V8Array(v8).apply {
            push(1.toShort())
            push(2.toShort())
            push(3.toShort())
        }
        val charList = V8Array(v8).apply {
            push(1)
            push(2)
            push(3)
        }
        val intList = V8Array(v8).apply {
            push(1)
            push(2)
            push(3)
        }
        val longList = V8Array(v8).apply {
            push(1L)
            push(2L)
            push(3L)
        }
        val floatList = V8Array(v8).apply {
            push(1f)
            push(2f)
            push(3f)
        }
        val doubleList = V8Array(v8).apply {
            push(1.0)
            push(2.0)
            push(3.0)
        }
        val stringList = V8Array(v8).apply {
            push("1")
            push("2")
            push("3")
        }
        val booleanList = V8Array(v8).apply {
            push(true)
            push(false)
            push(true)
        }
        val enumList = V8Array(v8).apply {
            push(Enum.VALUE_1.name)
            push(Enum.VALUE_2.name)
            push(Enum.VALUE_3.name)
        }
        val object1 = V8Object(v8).also { obj ->
            obj.add("value", "value1")
        }
        val object2 = V8Object(v8).also { obj ->
            obj.add("value", "value2")
        }
        val object3 = V8Object(v8).also { obj ->
            obj.add("value", "value3")
        }
        val nestedObjectList = V8Array(v8).apply {
            push(object1)
            push(object2)
            push(object3)
        }
        val stringMap = V8Array(v8).apply {
            add("key1", "value1")
            add("key2", "value2")
            add("key3", "value3")
        }
        val enumMap = V8Array(v8).apply {
            add("VALUE_1", "value1")
            add("VALUE_2", "value2")
            add("VALUE_3", "value3")
        }
        val value = V8Object(v8).apply {
            add("byte", Byte.MIN_VALUE.toInt())
            addNull("nullByte")
            add("nonNullByte", Byte.MAX_VALUE.toInt())
            add("short", Short.MIN_VALUE.toInt())
            addNull("nullShort")
            add("nonNullShort", Short.MAX_VALUE.toInt())
            add("char", Char.MIN_VALUE.toInt())
            addNull("nullChar")
            add("nonNullChar", Char.MAX_VALUE.toInt())
            add("int", Int.MIN_VALUE)
            addNull("nullInt")
            add("nonNullInt", Int.MAX_VALUE)
            add("long", Long.MIN_VALUE.toDouble())
            addNull("nullLong")
            add("nonNullLong", Long.MAX_VALUE.toDouble())
            add("double", Double.MIN_VALUE)
            addNull("nullDouble")
            add("nonNullDouble", Double.MAX_VALUE)
            add("float", Float.MIN_VALUE.toDouble())
            addNull("nullFloat")
            add("nonNullFloat", Float.MAX_VALUE.toDouble())
            add("string", "5.0")
            addNull("nullString")
            add("nonNullString", "nonNull")
            add("boolean", true)
            addNull("nullBoolean")
            add("nonNullBoolean", true)
            add("enum", Enum.VALUE_2.name)
            addNull("nullEnum")
            addUndefined("unit")
            add("nestedObject", nestedObject)
            addNull("nullNestedObject")
            add("nonNullNestedObject", nonNullNestedObject)
            add("doubleNestedObject", doubleNestedObject)
            add("byteList", byteList)
            add("shortList", shortList)
            add("charList", charList)
            add("intList", intList)
            add("longList", longList)
            add("doubleList", doubleList)
            add("floatList", floatList)
            add("stringList", stringList)
            add("booleanList", booleanList)
            add("enumList", enumList)
            add("nestedObjectList", nestedObjectList)
            add("stringMap", stringMap)
            add("enumMap", enumMap)
        }
        k2V8.fromV8(SupportedTypes.serializer(), value).let { decoded ->
            assertThat(decoded.byte).isEqualTo(Byte.MIN_VALUE)
            assertThat(decoded.nullByte).isNull()
            assertThat(decoded.nonNullByte).isEqualTo(Byte.MAX_VALUE)
            assertThat(decoded.short).isEqualTo(Short.MIN_VALUE)
            assertThat(decoded.nullShort).isNull()
            assertThat(decoded.nonNullShort).isEqualTo(Short.MAX_VALUE)
            assertThat(decoded.int).isEqualTo(Int.MIN_VALUE)
            assertThat(decoded.nullInt).isNull()
            assertThat(decoded.nonNullInt).isEqualTo(Int.MAX_VALUE)
            assertThat(decoded.long).isEqualTo(Long.MIN_VALUE)
            assertThat(decoded.nullLong).isNull()
            assertThat(decoded.nonNullLong).isEqualTo(Long.MAX_VALUE)
            assertThat(decoded.double).isEqualTo(Double.MIN_VALUE)
            assertThat(decoded.nullDouble).isNull()
            assertThat(decoded.nonNullDouble).isEqualTo(Double.MAX_VALUE)
            assertThat(decoded.float).isEqualTo(Float.MIN_VALUE)
            assertThat(decoded.nullFloat).isNull()
            assertThat(decoded.nonNullFloat).isEqualTo(Float.MAX_VALUE)
            assertThat(decoded.string).isEqualTo("5.0")
            assertThat(decoded.nullString).isNull()
            assertThat(decoded.nonNullString).isEqualTo("nonNull")
            assertThat(decoded.boolean).isTrue()
            assertThat(decoded.nullBoolean).isNull()
            assertThat(decoded.nonNullBoolean).isTrue()
            assertThat(decoded.enum).isEqualTo(Enum.VALUE_2)
            assertThat(decoded.nullEnum).isNull()
            assertThat(decoded.unit).isEqualTo(Unit)
            assertThat(decoded.nestedObject.value).isEqualTo("value")
            assertThat(decoded.nullNestedObject).isNull()
            assertThat(decoded.nonNullNestedObject?.value).isEqualTo("value2")
            assertThat(decoded.doubleNestedObject.nestedObject.value).isEqualTo("value3")
            assertThat(decoded.byteList).isEqualTo(listOf<Byte>(1, 2, 3))
            assertThat(decoded.shortList).isEqualTo(listOf<Short>(1, 2, 3))
            assertThat(decoded.charList).isEqualTo(listOf(1.toChar(), 2.toChar(), 3.toChar()))
            assertThat(decoded.intList).isEqualTo(listOf(1, 2, 3))
            assertThat(decoded.longList).isEqualTo(listOf(1L, 2L, 3L))
            assertThat(decoded.floatList).isEqualTo(listOf(1f, 2f, 3f))
            assertThat(decoded.doubleList).isEqualTo(listOf(1.0, 2.0, 3.0))
            assertThat(decoded.stringList).isEqualTo(listOf("1", "2", "3"))
            assertThat(decoded.booleanList).isEqualTo(listOf(true, false, true))
            assertThat(decoded.enumList).isEqualTo(listOf(
                Enum.VALUE_1,
                Enum.VALUE_2,
                Enum.VALUE_3
            ))
            assertThat(decoded.nestedObjectList).isEqualTo(
                listOf(
                    NestedObject("value1"),
                    NestedObject("value2"),
                    NestedObject("value3")
                )
            )
            assertThat(decoded.stringMap).isEqualTo(mapOf("key1" to "value1", "key2" to "value2", "key3" to "value3"))
            assertThat(decoded.enumMap).isEqualTo(mapOf(Enum.VALUE_1 to "value1", Enum.VALUE_2 to "value2", Enum.VALUE_3 to "value3"))
        }
    }

    @Test(expected = V8EncodingException::class)
    fun intKeyedMapToV8ThrowsException() {
        val intMap = mapOf(1 to "1", 2 to "2", 3 to "3")
        k2V8.toV8(MapSerializer(Int.serializer(), String.serializer()), intMap)
    }

    @Test(expected = V8EncodingException::class)
    fun longKeyedMapToV8ThrowsException() {
        val longMap = mapOf(1L to "1", 2L to "2", 3L to "3")
        k2V8.toV8(MapSerializer(Long.serializer(), String.serializer()), longMap)
    }

    @Test(expected = V8EncodingException::class)
    fun doubleKeyedMapToV8ThrowsException() {
        val doubleMap = mapOf(1.0 to "1", 2.0 to "2", 3.0 to "3")
        k2V8.toV8(MapSerializer(Double.serializer(), String.serializer()), doubleMap)
    }

    @Test(expected = V8EncodingException::class)
    fun floatKeyedMapToV8ThrowsException() {
        val floatMap = mapOf(1f to "1", 2f to "2", 3f to "3")
        k2V8.toV8(MapSerializer(Float.serializer(), String.serializer()), floatMap)
    }
}
