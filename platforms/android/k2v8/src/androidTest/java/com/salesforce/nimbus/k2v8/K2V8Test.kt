package com.salesforce.nimbus.k2v8

import androidx.test.ext.junit.runners.AndroidJUnit4
import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
import com.eclipsesource.v8.V8Object
import io.kotlintest.properties.Gen
import io.kotlintest.properties.forAll
import kotlinx.serialization.Serializable
import kotlinx.serialization.builtins.ListSerializer
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

    @Serializable
    @Suppress("unused")
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
    fun supportedTypesToV8() = v8.scope {
        forAll(
            100,
            Gen.list(Gen.char()).filter { it.isNotEmpty() },
            Gen.list(Gen.long()).filter { it.isNotEmpty() },
            Gen.list(Gen.string()).filter { it.isNotEmpty() },
            Gen.list(Gen.enum<Enum>()).filter { it.isNotEmpty() },
            Gen.map(Gen.string(), Gen.string().filter { it.isNotEmpty() })
        ) { chars, longs, strings, enums, stringMap ->
            val supportedTypes = getSupportedTypes(chars, longs, strings, enums, stringMap)
            with(k2V8.toV8(SupportedTypes.serializer(), supportedTypes)) {
                getInteger("byte").toByte() == supportedTypes.byte &&
                    get("nullByte") == supportedTypes.nullByte &&
                    getInteger("nonNullByte").toByte() == supportedTypes.nonNullByte &&
                    getInteger("short").toShort() == supportedTypes.short &&
                    get("nullShort") == supportedTypes.nullShort &&
                    getInteger("nonNullShort").toShort() == supportedTypes.nonNullShort &&
                    getInteger("char").toChar() == supportedTypes.char &&
                    get("nullChar") == supportedTypes.nullChar &&
                    getInteger("nonNullChar").toChar() == supportedTypes.nonNullChar &&
                    getInteger("int") == supportedTypes.int &&
                    get("nullInt") == supportedTypes.nullInt &&
                    getInteger("nonNullInt") == supportedTypes.nonNullInt &&
                    getDouble("long") == supportedTypes.long.toDouble() &&
                    get("nullLong") == supportedTypes.nullLong &&
                    getDouble("nonNullLong") == supportedTypes.nonNullLong!!.toDouble() &&
                    getDouble("double") == supportedTypes.double &&
                    get("nullDouble") == supportedTypes.nullDouble &&
                    getDouble("nonNullDouble") == supportedTypes.nonNullDouble &&
                    getDouble("float").toFloat() == supportedTypes.float &&
                    get("nullFloat") == supportedTypes.nullFloat &&
                    getDouble("nonNullFloat").toFloat() == supportedTypes.nonNullFloat &&
                    getString("string") == supportedTypes.string &&
                    get("nullString") == supportedTypes.nullString &&
                    getString("nonNullString") == supportedTypes.nonNullString &&
                    getBoolean("boolean") == supportedTypes.boolean &&
                    get("nullBoolean") == supportedTypes.nullBoolean &&
                    getBoolean("nonNullBoolean") == supportedTypes.nonNullBoolean &&
                    getString("enum") == supportedTypes.enum.name &&
                    get("nullEnum") == supportedTypes.nullEnum &&
                    getObject("unit").isUndefined &&
                    getObject("nestedObject").getString("value") == supportedTypes.nestedObject.value &&
                    getObject("nullNestedObject") == null &&
                    getObject("nonNullNestedObject").getString("value") == supportedTypes.nonNullNestedObject!!.value &&
                    getObject("doubleNestedObject").getObject("nestedObject")
                        .getString("value") == supportedTypes.doubleNestedObject.nestedObject.value &&
                    with(getObject("byteList") as V8Array) {
                        supportedTypes.byteList.valueAtIndex { getInteger(it).toByte() }
                    } &&
                    with(getObject("shortList") as V8Array) {
                        supportedTypes.shortList.valueAtIndex { getInteger(it).toShort() }
                    } &&
                    with(getObject("charList") as V8Array) {
                        supportedTypes.charList.valueAtIndex { getInteger(it).toChar() }
                    } &&
                    with(getObject("intList") as V8Array) {
                        supportedTypes.intList.valueAtIndex { getInteger(it) }
                    } &&
                    with(getObject("longList") as V8Array) {
                        supportedTypes.longList.valueAtIndex({ it.toDouble() }) { getDouble(it) }
                    } &&
                    with(getObject("floatList") as V8Array) {
                        supportedTypes.floatList.valueAtIndex { getDouble(it).toFloat() }
                    } &&
                    with(getObject("doubleList") as V8Array) {
                        supportedTypes.doubleList.valueAtIndex { getDouble(it) }
                    } &&
                    with(getObject("stringList") as V8Array) {
                        supportedTypes.stringList.valueAtIndex { getString(it) }
                    } &&
                    with(getObject("booleanList") as V8Array) {
                        supportedTypes.booleanList.valueAtIndex { getBoolean(it) }
                    } &&
                    with(getObject("enumList") as V8Array) {
                        supportedTypes.enumList.valueAtIndex({ it.name }) { getString(it) }
                    } &&
                    with(getObject("nestedObjectList") as V8Array) {
                        supportedTypes.nestedObjectList.valueAtIndex({ it.value }) {
                            getObject(it).getString("value")
                        }
                    } &&
                    with(getObject("stringMap") as V8Array) {
                        supportedTypes.stringMap.valueForKey { getString(it) }
                    } &&
                    with(getObject("enumMap") as V8Array) {
                        supportedTypes.enumMap.valueForKey({ it.name }) { getString(it) }
                    }
            }
        }
    }

    @Test
    fun supportedTypesFromV8() = v8.scope {
        forAll(
            100,
            Gen.list(Gen.char()).filter { it.isNotEmpty() },
            Gen.list(Gen.long()).filter { it.isNotEmpty() },
            Gen.list(Gen.string()).filter { it.isNotEmpty() },
            Gen.list(Gen.enum<Enum>()).filter { it.isNotEmpty() },
            Gen.map(Gen.string(), Gen.string().filter { it.isNotEmpty() })
        ) { chars, longs, strings, enums, stringMap ->
            val supportedTypes = getSupportedTypes(chars, longs, strings, enums, stringMap)
            val nestedV8Object = V8Object(v8).apply {
                add("value", supportedTypes.nestedObject.value)
            }
            val nonNullNestedV8Object = V8Object(v8).apply {
                add("value", supportedTypes.nonNullNestedObject!!.value)
            }
            val doubleNestedVObject = V8Object(v8).apply {
                add(
                    "nestedObject",
                    V8Object(v8).add("value", supportedTypes.doubleNestedObject.nestedObject.value)
                )
            }
            val byteV8Array = supportedTypes.byteList.map { it.toInt() }.toV8Array(v8)
            val shortV8Array = supportedTypes.shortList.map { it.toInt() }.toV8Array(v8)
            val charV8Array = supportedTypes.charList.map { it.toInt() }.toV8Array(v8)
            val intV8Array = supportedTypes.intList.toV8Array(v8)
            val longV8Array = supportedTypes.longList.map { it.toDouble() }.toV8Array(v8)
            val floatV8Array = supportedTypes.floatList.map { it.toDouble() }.toV8Array(v8)
            val doubleV8Array = supportedTypes.doubleList.toV8Array(v8)
            val stringV8Array = supportedTypes.stringList.toV8Array(v8)
            val booleanV8Array = supportedTypes.booleanList.toV8Array(v8)
            val enumV8Array = supportedTypes.enumList.map { it.name }.toV8Array(v8)
            val nestedObjectV8Array = V8Array(v8).apply {
                supportedTypes.nestedObjectList.forEach {
                    push(V8Object(v8).also { obj -> obj.add("value", it.value) })
                }
            }
            val stringStringV8Array = supportedTypes.stringMap.toV8Array(v8)
            val enumStringV8Array = V8Array(v8).apply {
                supportedTypes.enumMap.entries.forEach { (key, value) -> add(key.name, value) }
            }
            val value = V8Object(v8).apply {
                add("byte", supportedTypes.byte.toInt())
                addNull("nullByte")
                add("nonNullByte", supportedTypes.nonNullByte!!.toInt())
                add("short", supportedTypes.short.toInt())
                addNull("nullShort")
                add("nonNullShort", supportedTypes.nonNullShort!!.toInt())
                add("char", supportedTypes.char.toInt())
                addNull("nullChar")
                add("nonNullChar", supportedTypes.nonNullChar!!.toInt())
                add("int", supportedTypes.int)
                addNull("nullInt")
                add("nonNullInt", supportedTypes.nonNullInt!!)
                add("long", supportedTypes.long.toDouble())
                addNull("nullLong")
                add("nonNullLong", supportedTypes.nonNullLong!!.toDouble())
                add("double", supportedTypes.double)
                addNull("nullDouble")
                add("nonNullDouble", supportedTypes.nonNullDouble!!)
                add("float", supportedTypes.float.toDouble())
                addNull("nullFloat")
                add("nonNullFloat", supportedTypes.nonNullFloat!!.toDouble())
                add("string", supportedTypes.string)
                addNull("nullString")
                add("nonNullString", supportedTypes.nonNullString)
                add("boolean", supportedTypes.boolean)
                addNull("nullBoolean")
                add("nonNullBoolean", supportedTypes.nonNullBoolean!!)
                add("enum", supportedTypes.enum.name)
                addNull("nullEnum")
                addUndefined("unit")
                add("nestedObject", nestedV8Object)
                addNull("nullNestedObject")
                add("nonNullNestedObject", nonNullNestedV8Object)
                add("doubleNestedObject", doubleNestedVObject)
                add("byteList", byteV8Array)
                add("shortList", shortV8Array)
                add("charList", charV8Array)
                add("intList", intV8Array)
                add("longList", longV8Array)
                add("doubleList", doubleV8Array)
                add("floatList", floatV8Array)
                add("stringList", stringV8Array)
                add("booleanList", booleanV8Array)
                add("enumList", enumV8Array)
                add("nestedObjectList", nestedObjectV8Array)
                add("stringMap", stringStringV8Array)
                add("enumMap", enumStringV8Array)
            }
            with(k2V8.fromV8(SupportedTypes.serializer(), value)) {
                byte == supportedTypes.byte &&
                    nullByte == supportedTypes.nullByte &&
                    nonNullByte == supportedTypes.nonNullByte &&
                    short == supportedTypes.short &&
                    nullShort == supportedTypes.nullShort &&
                    nonNullShort == supportedTypes.nonNullShort &&
                    char == supportedTypes.char &&
                    nullChar == supportedTypes.nullChar &&
                    nonNullChar == supportedTypes.nonNullChar &&
                    int == supportedTypes.int &&
                    nullInt == supportedTypes.nullInt &&
                    nonNullInt == supportedTypes.nonNullInt &&
                    long.toDouble() == supportedTypes.long.toDouble() &&
                    nullLong == supportedTypes.nullLong &&
                    nonNullLong!!.toDouble() == supportedTypes.nonNullLong!!.toDouble() &&
                    double == supportedTypes.double &&
                    nullDouble == supportedTypes.nullDouble &&
                    nonNullDouble == supportedTypes.nonNullDouble &&
                    float == supportedTypes.float &&
                    nullFloat == supportedTypes.nullFloat &&
                    nonNullFloat == supportedTypes.nonNullFloat &&
                    string == supportedTypes.string &&
                    nullString == supportedTypes.nullString &&
                    nonNullString == supportedTypes.nonNullString &&
                    boolean == supportedTypes.boolean &&
                    nullBoolean == supportedTypes.nullBoolean &&
                    nonNullBoolean == supportedTypes.nonNullBoolean &&
                    enum == supportedTypes.enum &&
                    nullEnum == supportedTypes.nullEnum &&
                    unit == supportedTypes.unit &&
                    nestedObject.value == supportedTypes.nestedObject.value &&
                    nullNestedObject == null &&
                    nonNullNestedObject!!.value == supportedTypes.nonNullNestedObject!!.value &&
                    byteList == supportedTypes.byteList &&
                    shortList == supportedTypes.shortList &&
                    charList == supportedTypes.charList &&
                    intList == supportedTypes.intList &&
                    longList.map { it.toDouble() } == supportedTypes.longList.map { it.toDouble() } &&
                    floatList == supportedTypes.floatList &&
                    doubleList == supportedTypes.doubleList &&
                    stringList == supportedTypes.stringList &&
                    booleanList == supportedTypes.booleanList &&
                    enumList == supportedTypes.enumList &&
                    nestedObjectList == supportedTypes.nestedObjectList &&
                    stringMap == supportedTypes.stringMap &&
                    enumMap == supportedTypes.enumMap
            }
        }
    }

    // region list tests

    @Test
    fun byteListToV8() = v8.scope {
        forAll(100, Gen.list(Gen.byte())) { list ->
            with(k2V8.toV8(ListSerializer(Byte.serializer()), list) as V8Array) {
                list.valueAtIndex({ it.toInt() }) { getInteger(it) }
            }
        }
    }

    @Test
    fun byteListFromV8() = v8.scope {
        forAll(100, Gen.list(Gen.byte())) { list ->
            val array = list.map { it.toInt() }.toV8Array(v8)
            with(k2V8.fromV8(ListSerializer(Byte.serializer()), array)) {
                list.valueAtIndex { get(it) }
            }
        }
    }

    @Test
    fun shortListToV8() = v8.scope {
        forAll(100, Gen.list(Gen.short())) { list ->
            with(k2V8.toV8(ListSerializer(Short.serializer()), list) as V8Array) {
                list.valueAtIndex({ it.toInt() }) { getInteger(it) }
            }
        }
    }

    @Test
    fun shortListFromV8() = v8.scope {
        forAll(100, Gen.list(Gen.short())) { list ->
            val array = list.map { it.toInt() }.toV8Array(v8)
            with(k2V8.fromV8(ListSerializer(Short.serializer()), array)) {
                list.valueAtIndex { get(it) }
            }
        }
    }

    @Test
    fun charListToV8() = v8.scope {
        forAll(100, Gen.list(Gen.char())) { list ->
            with(k2V8.toV8(ListSerializer(Char.serializer()), list) as V8Array) {
                list.valueAtIndex({ it.toInt() }) { getInteger(it) }
            }
        }
    }

    @Test
    fun charListFromV8() = v8.scope {
        forAll(100, Gen.list(Gen.char())) { list ->
            val array = list.map { it.toInt() }.toV8Array(v8)
            with(k2V8.fromV8(ListSerializer(Char.serializer()), array)) {
                list.valueAtIndex { get(it) }
            }
        }
    }

    @Test
    fun intListToV8() = v8.scope {
        forAll(100, Gen.list(Gen.int())) { list ->
            with(k2V8.toV8(ListSerializer(Int.serializer()), list) as V8Array) {
                list.valueAtIndex { getInteger(it) }
            }
        }
    }

    @Test
    fun intListFromV8() = v8.scope {
        forAll(100, Gen.list(Gen.int())) { list ->
            val array = list.toV8Array(v8)
            with(k2V8.fromV8(ListSerializer(Int.serializer()), array)) {
                list.valueAtIndex { get(it) }
            }
        }
    }

    @Test
    fun longListToV8() = v8.scope {
        forAll(100, Gen.list(Gen.long())) { list ->
            with(k2V8.toV8(ListSerializer(Long.serializer()), list) as V8Array) {
                list.valueAtIndex({ it.toDouble() }) { getDouble(it) }
            }
        }
    }

    @Test
    fun longListFromV8() = v8.scope {
        forAll(100, Gen.list(Gen.long())) { list ->
            val array = list.map { it.toDouble() }.toV8Array(v8)
            with(k2V8.fromV8(ListSerializer(Long.serializer()), array)) {
                list.valueAtIndex({ it.toDouble() }) { get(it).toDouble() }
            }
        }
    }

    @Test
    fun floatListToV8() = v8.scope {
        forAll(100, Gen.list(Gen.float().filter { !it.isNaN() })) { list ->
            with(k2V8.toV8(ListSerializer(Float.serializer()), list) as V8Array) {
                list.valueAtIndex({ it.toDouble() }) { getDouble(it) }
            }
        }
    }

    @Test
    fun floatListFromV8() = v8.scope {
        forAll(100, Gen.list(Gen.float().filter { !it.isNaN() })) { list ->
            val array = list.toV8Array(v8)
            with(k2V8.fromV8(ListSerializer(Float.serializer()), array)) {
                list.valueAtIndex { get(it) }
            }
        }
    }

    @Test
    fun doubleListToV8() = v8.scope {
        forAll(100, Gen.list(Gen.double().filter { !it.isNaN() })) { list ->
            with(k2V8.toV8(ListSerializer(Double.serializer()), list) as V8Array) {
                list.valueAtIndex { getDouble(it) }
            }
        }
    }

    @Test
    fun doubleListFromV8() = v8.scope {
        forAll(100, Gen.list(Gen.double().filter { !it.isNaN() })) { list ->
            val array = list.toV8Array(v8)
            with(k2V8.fromV8(ListSerializer(Double.serializer()), array)) {
                list.valueAtIndex { get(it) }
            }
        }
    }

    @Test
    fun stringListToV8() = v8.scope {
        forAll(100, Gen.list(Gen.string())) { list ->
            with(k2V8.toV8(ListSerializer(String.serializer()), list) as V8Array) {
                list.valueAtIndex { getString(it) }
            }
        }
    }

    @Test
    fun stringListFromV8() = v8.scope {
        forAll(100, Gen.list(Gen.string())) { list ->
            val array = list.toV8Array(v8)
            with(k2V8.fromV8(ListSerializer(String.serializer()), array)) {
                list.valueAtIndex { get(it) }
            }
        }
    }

    @Test
    fun booleanListToV8() = v8.scope {
        forAll(100, Gen.list(Gen.bool())) { list ->
            with(k2V8.toV8(ListSerializer(Boolean.serializer()), list) as V8Array) {
                list.valueAtIndex { getBoolean(it) }
            }
        }
    }

    @Test
    fun booleanListFromV8() = v8.scope {
        forAll(100, Gen.list(Gen.bool())) { list ->
            val array = list.toV8Array(v8)
            with(k2V8.fromV8(ListSerializer(Boolean.serializer()), array)) {
                list.valueAtIndex { get(it) }
            }
        }
    }

    @Test
    fun enumListToV8() = v8.scope {
        forAll(100, Gen.list(Gen.enum<Enum>())) { list ->
            with(k2V8.toV8(ListSerializer(Enum.serializer()), list) as V8Array) {
                list.valueAtIndex({ it.name }) { getString(it) }
            }
        }
    }

    @Test
    fun enumListFromV8() = v8.scope {
        forAll(100, Gen.list(Gen.enum<Enum>())) { list ->
            val array = list.map { it.toString() }.toV8Array(v8)
            with(k2V8.fromV8(ListSerializer(Enum.serializer()), array)) {
                list.valueAtIndex { get(it) }
            }
        }
    }

    @Test
    fun objectListToV8() = v8.scope {
        forAll(100, Gen.list(Gen.string())) { strings ->
            val list = strings.map { NestedObject(it) }
            with(k2V8.toV8(ListSerializer(NestedObject.serializer()), list) as V8Array) {
                list.valueAtIndex({ it.value }) { getObject(it).getString("value") }
            }
        }
    }

    @Test
    fun objectListFromV8() = v8.scope {
        forAll(100, Gen.list(Gen.string())) { list ->
            val array = list
                .map { value ->
                    V8Object(v8).also {
                        it.add("value", value)
                    }
                }
                .toV8Array(v8)
            with(k2V8.fromV8(ListSerializer(NestedObject.serializer()), array)) {
                list.valueAtIndex { get(it).value }
            }
        }
    }

    // endregion

    // region map tests

    @Test
    fun stringKeyedMapToV8() = v8.scope {
        forAll(100, Gen.map(Gen.string(), Gen.string())) { map ->
            with(
                k2V8.toV8(
                    MapSerializer(String.serializer(), String.serializer()),
                    map
                ) as V8Array
            ) {
                map.valueForKey { getString(it) }
            }
        }
    }

    @Test
    fun stringKeyedMapFromV8() {
        forAll(100, Gen.map(Gen.string(), Gen.string())) { map ->
            val array = map.toV8Array(v8)
            with(k2V8.fromV8(MapSerializer(String.serializer(), String.serializer()), array)) {
                map.valueForKey { get(it) }
            }
        }
    }

    @Test
    fun enumKeyedMapToV8() {
        forAll(100, Gen.map(Gen.enum<Enum>(), Gen.string())) { map ->
            with(
                k2V8.toV8(
                    MapSerializer(Enum.serializer(), String.serializer()),
                    map
                ) as V8Array
            ) {
                map.valueForKey({ it.name }) { getString(it) }
            }
        }
    }

    @Test
    fun enumKeyedMapFromV8() {
        forAll(100, Gen.map(Gen.enum<Enum>(), Gen.string())) { map ->
            val array = V8Array(v8).apply {
                map.entries.onEach { (key, value) -> add(key.name, value) }
            }
            with(k2V8.fromV8(MapSerializer(Enum.serializer(), String.serializer()), array)) {
                map.valueForKey { get(it) }
            }
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

    // endregion

    // region helpers

    private fun getSupportedTypes(
        chars: List<Char>,
        longs: List<Long>,
        strings: List<String>,
        enums: List<Enum>,
        stringMap: Map<String, String>
    ) =
        SupportedTypes(
            byte = chars.random().toByte(),
            nullByte = null,
            nonNullByte = chars.random().toByte(),
            short = chars.random().toShort(),
            nullShort = null,
            nonNullShort = chars.random().toShort(),
            char = chars.random(),
            nullChar = null,
            nonNullChar = chars.random(),
            int = longs.random().toInt(),
            nullInt = null,
            nonNullInt = longs.random().toInt(),
            long = longs.random(),
            nullLong = null,
            nonNullLong = longs.random(),
            float = longs.random().toFloat(),
            nullFloat = null,
            nonNullFloat = longs.random().toFloat(),
            double = longs.random().toDouble(),
            nullDouble = null,
            nonNullDouble = longs.random().toDouble(),
            string = strings.random(),
            nullString = null,
            nonNullString = strings.random(),
            boolean = true,
            nullBoolean = null,
            nonNullBoolean = true,
            enum = enums.random(),
            nullEnum = null,
            unit = Unit,
            nestedObject = NestedObject(strings.random()),
            nullNestedObject = null,
            nonNullNestedObject = NestedObject(strings.random()),
            doubleNestedObject = DoubleNestedObject(NestedObject(strings.random())),
            byteList = chars.map { it.toByte() },
            shortList = chars.map { it.toShort() },
            charList = chars,
            intList = longs.map { it.toInt() },
            longList = longs,
            floatList = longs.map { it.toFloat() },
            doubleList = longs.map { it.toDouble() },
            stringList = strings,
            booleanList = listOf(true, false, true),
            enumList = enums,
            nestedObjectList = strings.map { NestedObject(it) },
            stringMap = stringMap,
            enumMap = mapOf(
                enums.random() to strings.random(),
                enums.random() to strings.random(),
                enums.random() to strings.random()
            )
        )

    // endregion
}
