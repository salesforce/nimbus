package com.salesforce.nimbus.bridge.tests.plugin

import com.salesforce.k2v8.V8ObjectDecoder
import com.salesforce.k2v8.V8ObjectEncoder
import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.DefaultEventPublisher
import com.salesforce.nimbus.Event
import com.salesforce.nimbus.EventPublisher
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import kotlinx.serialization.Decoder
import kotlinx.serialization.Encoder
import kotlinx.serialization.KSerializer
import kotlinx.serialization.PrimitiveDescriptor
import kotlinx.serialization.PrimitiveKind
import kotlinx.serialization.SerialDescriptor
import kotlinx.serialization.Serializable
import kotlinx.serialization.SerializationException
import kotlinx.serialization.Serializer
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonConfiguration
import kotlinx.serialization.json.JsonInput
import kotlinx.serialization.json.JsonOutput
import java.text.SimpleDateFormat
import java.util.Calendar
import java.util.Date
import java.util.TimeZone

@Serializable
data class TestStruct(
    val string: String = "String",
    val integer: Int = 1,
    val double: Double = 2.0
) {
    override fun toString(): String {
        return "$string, $integer, $double"
    }
}

@Serializable
data class DateWrapper(
    @Serializable(with = DateSerializer::class) val date: Date = Date()
)

@Serializer(forClass = Date::class)
object DateSerializer : KSerializer<Date> {
    override val descriptor: SerialDescriptor = PrimitiveDescriptor("java.util.Date", PrimitiveKind.STRING)

    private val dateFormat = SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSSZ")
        .apply { timeZone = TimeZone.getTimeZone("UTC") }

    override fun serialize(encoder: Encoder, value: Date) {
        when (encoder) {
            is V8ObjectEncoder, is JsonOutput -> encoder.encodeString(dateFormat.format(value))
            else -> throw SerializationException("Unknown encoder type")
        }
    }

    override fun deserialize(decoder: Decoder): Date {
        return when (decoder) {
            is V8ObjectDecoder, is JsonInput -> dateFormat.parse(decoder.decodeString())
            else -> throw SerializationException("Unknown decoder type")
        }
    }
}

@Serializable
class StructEvent(val theStruct: TestStruct) : Event {
    override val name: String = "structEvent"
}

@Serializable
class EncodableException1(val code: Int, override val message: String) : RuntimeException("$code: $message")

@Serializable
class EncodableException2(val code: Int, override val message: String) : RuntimeException("$code: $message")

@PluginOptions(name = "testPlugin")
class TestPlugin : Plugin, EventPublisher<StructEvent> by DefaultEventPublisher() {

    // region exception testing

    @BoundMethod
    fun promiseResolvesWithNonEncodableException() {
        throw Exception("This is the exception message")
    }

    @BoundMethod(EncodableException1::class, EncodableException2::class)
    fun promiseResolvesWithEncodableException(code: Int) {
        if (code == 1) {
            throw EncodableException1(1, "Encodable exception 1")
        } else if (code == 2) {
            throw EncodableException2(2, "Encodable exception 2")
        }
    }

    // endregion

    // region nullary parameters

    @BoundMethod
    fun nullaryResolvingToInt(): Int {
        return 5
    }

    @BoundMethod
    fun nullaryResolvingToDouble(): Double {
        return 10.0
    }

    @BoundMethod
    fun nullaryResolvingToString(): String {
        return "aString"
    }

    @BoundMethod
    fun nullaryResolvingToStruct(): TestStruct {
        return TestStruct()
    }

    @BoundMethod
    fun nullaryResolvingToDateWrapper(): DateWrapper {
        return DateWrapper(Calendar.getInstance().apply {
            set(2020, 5, 4, 12, 24, 48)
        }.time)
    }

    @BoundMethod
    fun nullaryResolvingToIntList(): List<Int> {
        return listOf(1, 2, 3)
    }

    @BoundMethod
    fun nullaryResolvingToDoubleList(): List<Double> {
        return listOf(4.0, 5.0, 6.0)
    }

    @BoundMethod
    fun nullaryResolvingToStringList(): List<String> {
        return listOf("1", "2", "3")
    }

    @BoundMethod
    fun nullaryResolvingToStructList(): List<TestStruct> {
        return listOf(
            TestStruct("1", 1, 1.0),
            TestStruct("2", 2, 2.0),
            TestStruct("3", 3, 3.0)
        )
    }

    @BoundMethod
    fun nullaryResolvingToIntArray(): Array<Int> {
        return arrayOf(1, 2, 3)
    }

    @BoundMethod
    fun nullaryResolvingToStringStringMap(): Map<String, String> {
        return mapOf("key1" to "value1", "key2" to "value2", "key3" to "value3")
    }

    @BoundMethod
    fun nullaryResolvingToStringIntMap(): Map<String, Int> {
        return mapOf("key1" to 1, "key2" to 2, "key3" to 3)
    }

    @BoundMethod
    fun nullaryResolvingToStringDoubleMap(): Map<String, Double> {
        return mapOf("key1" to 1.0, "key2" to 2.0, "key3" to 3.0)
    }

    @BoundMethod
    fun nullaryResolvingToStringStructMap(): Map<String, TestStruct> {
        return mapOf(
            "key1" to TestStruct("1", 1, 1.0),
            "key2" to TestStruct("2", 2, 2.0),
            "key3" to TestStruct("3", 3, 3.0)
        )
    }

    // endregion

    // region unary parameters

    @BoundMethod
    fun unaryIntResolvingToInt(param: Int): Int {
        return param + 1
    }

    @BoundMethod
    fun unaryDoubleResolvingToDouble(param: Double): Double {
        return param * 2
    }

    @BoundMethod
    fun unaryStringResolvingToInt(param: String): Int {
        return param.length
    }

    @BoundMethod
    fun unaryStructResolvingToJsonString(param: TestStruct): String {
        return Json(JsonConfiguration.Stable).stringify(TestStruct.serializer(), param)
    }

    @BoundMethod
    fun unaryDateWrapperResolvingToJsonString(param: DateWrapper): String {
        return Json(JsonConfiguration.Stable).stringify(DateWrapper.serializer(),
            param.copy(date = Calendar.getInstance().apply {
                time = param.date
                add(Calendar.DAY_OF_YEAR, 1)
            }.time))
    }

    @BoundMethod
    fun unaryStringListResolvingToString(param: List<String>): String {
        return param.joinToString(separator = ", ")
    }

    @BoundMethod
    fun unaryIntListResolvingToString(param: List<Int>): String {
        return param.joinToString(separator = ", ")
    }

    @BoundMethod
    fun unaryDoubleListResolvingToString(param: List<Double>): String {
        return param.joinToString(separator = ", ")
    }

    @BoundMethod
    fun unaryStructListResolvingToString(param: List<TestStruct>): String {
        return param.joinToString(separator = ", ")
    }

    @BoundMethod
    fun unaryIntArrayResolvingToString(param: Array<Int>): String {
        return param.joinToString(separator = ", ")
    }

    @BoundMethod
    fun unaryStringStringMapResolvingToString(param: Map<String, String>): String {
        return param.map { "${it.key}, ${it.value}" }.joinToString(separator = ", ")
    }

    @BoundMethod
    fun unaryStringStructMapResolvingToString(param: Map<String, TestStruct>): String {
        return param.map { "${it.key}, ${it.value}" }.joinToString(separator = ", ")
    }

    // endregion

    // endregion

    // region callbacks

    @BoundMethod
    fun nullaryResolvingToStringCallback(callback: (String) -> Unit) {
        callback("param0")
    }

    @BoundMethod
    fun nullaryResolvingToIntCallback(callback: (Int) -> Unit) {
        callback(1)
    }

    @BoundMethod
    fun nullaryResolvingToLongCallback(callback: (Long) -> Unit) {
        callback(2L)
    }

    @BoundMethod
    fun nullaryResolvingToDoubleCallback(callback: (Double) -> Unit) {
        callback(3.0)
    }

    @BoundMethod
    fun nullaryResolvingToStructCallback(callback: (TestStruct) -> Unit) {
        callback(TestStruct())
    }

    @BoundMethod
    fun nullaryResolvingToDateWrapperCallback(callback: (DateWrapper) -> Unit) {
        callback(
            DateWrapper(Calendar.getInstance().apply {
                set(2020, 5, 4, 0, 0, 0)
            }.time)
        )
    }

    @BoundMethod
    fun nullaryResolvingToStringListCallback(callback: (List<String>) -> Unit) {
        callback(listOf("1", "2", "3"))
    }

    @BoundMethod
    fun nullaryResolvingToIntListCallback(callback: (List<Int>) -> Unit) {
        callback(listOf(1, 2, 3))
    }

    @BoundMethod
    fun nullaryResolvingToDoubleListCallback(callback: (List<Double>) -> Unit) {
        callback(listOf(1.0, 2.0, 3.0))
    }

    @BoundMethod
    fun nullaryResolvingToStructListCallback(callback: (List<TestStruct>) -> Unit) {
        callback(
            listOf(
                TestStruct("1", 1, 1.0),
                TestStruct("2", 2, 2.0),
                TestStruct("3", 3, 3.0)
            )
        )
    }

    @BoundMethod
    fun nullaryResolvingToIntArrayCallback(callback: (Array<Int>) -> Unit) {
        callback(arrayOf(1, 2, 3))
    }

    @BoundMethod
    fun nullaryResolvingToStringStringMapCallback(callback: (Map<String, String>) -> Unit) {
        callback(
            mapOf(
                "key1" to "value1",
                "key2" to "value2",
                "key3" to "value3"
            )
        )
    }

    @BoundMethod
    fun nullaryResolvingToStringIntMapCallback(callback: (Map<String, Int>) -> Unit) {
        callback(
            mapOf(
                "1" to 1,
                "2" to 2,
                "3" to 3
            )
        )
    }

    @BoundMethod
    fun nullaryResolvingToStringDoubleMapCallback(callback: (Map<String, Double>) -> Unit) {
        callback(
            mapOf(
                "1.0" to 1.0,
                "2.0" to 2.0,
                "3.0" to 3.0
            )
        )
    }

    @BoundMethod
    fun nullaryResolvingToStringStructMapCallback(callback: (Map<String, TestStruct>) -> Unit) {
        callback(
            mapOf(
                "1" to TestStruct("1", 1, 1.0),
                "2" to TestStruct("2", 2, 2.0),
                "3" to TestStruct("3", 3, 3.0)
            )
        )
    }

    @BoundMethod
    fun nullaryResolvingToStringIntCallback(callback: (String, Int) -> Unit) {
        callback("param0", 1)
    }

    @BoundMethod
    fun nullaryResolvingToIntStructCallback(callback: (Int, TestStruct) -> Unit) {
        callback(2, TestStruct())
    }

    @BoundMethod
    fun unaryIntResolvingToIntCallback(param: Int, callback: (Int) -> Unit) {
        callback(param + 1)
    }

    @BoundMethod
    fun binaryIntDoubleResolvingToIntDoubleCallback(param0: Int, param1: Double, callback: (Int, Double) -> Unit) {
        callback(param0 + 1, param1 * 2)
    }

    @BoundMethod
    fun binaryIntResolvingIntCallbackReturnsInt(param0: Int, callback: (Int) -> Unit): Int {
        callback(param0 - 1)
        return param0 - 2
    }
}
