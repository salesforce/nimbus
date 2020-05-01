package com.salesforce.nimbus.k2v8

import com.eclipsesource.v8.V8Array
import com.eclipsesource.v8.V8Object
import kotlinx.serialization.CompositeDecoder
import kotlinx.serialization.Decoder
import kotlinx.serialization.DeserializationStrategy
import kotlinx.serialization.KSerializer
import kotlinx.serialization.SerialDescriptor
import kotlinx.serialization.StructureKind
import kotlinx.serialization.UpdateMode
import kotlinx.serialization.decode
import kotlinx.serialization.modules.SerialModule
import java.util.Stack
import kotlin.reflect.KClass

internal fun <T> K2V8.convertFromV8Object(
    value: V8Object,
    deserializer: DeserializationStrategy<T>
): T {
    val decoder = V8ObjectDecoder(this, value)
    return decoder.decode(deserializer)
}

class V8ObjectDecoder(
    private val k2V8: K2V8,
    private val value: V8Object,
    override val context: SerialModule = k2V8.context
) : Decoder, CompositeDecoder {

    override val updateMode: UpdateMode = UpdateMode.OVERWRITE

    private val nodes = Stack<InputNode>()
    private val currentNode: InputNode
        get() = nodes.peek()

    override fun beginStructure(
        descriptor: SerialDescriptor,
        vararg typeParams: KSerializer<*>
    ): CompositeDecoder {
        val key = if (nodes.isNotEmpty()) currentNode.deferredKey else null
        val node = when (descriptor.kind) {
            is StructureKind.CLASS -> {
                InputNode.ObjectInputNode(
                    descriptor,
                    if (key == null) value else currentNode.v8Object.getObject(key)
                )
            }
            is StructureKind.LIST -> {
                val v8Array = (if (key == null) value else currentNode.v8Object.get(key)) as V8Array
                InputNode.ListInputNode(v8Array)
            }
            StructureKind.MAP -> {
                val v8Object =
                    (if (key == null) value else currentNode.v8Object.get(key)) as V8Object
                InputNode.MapInputNode(v8Object)
            }
            is StructureKind.OBJECT -> InputNode.UndefinedInputNode(
                currentNode.v8Object.getObject(key)
            )
            else -> throw V8DecodingException("Unexpected kind encountered while trying to decode a V8Object: ${descriptor.kind}")
        }

        // push the node onto the stack
        nodes.push(node)

        // reset key
        currentNode.deferredKey = null

        return this
    }

    override fun decodeBoolean(): Boolean {
        return currentNode.decodeValue()
    }

    override fun decodeByte(): Byte {
        return currentNode.decodeValue()
    }

    override fun decodeChar(): Char {
        return currentNode.decodeValue()
    }

    override fun decodeDouble(): Double {
        return currentNode.decodeValue()
    }

    override fun decodeEnum(enumDescriptor: SerialDescriptor): Int {
        val name = currentNode.decodeValue<String>()
        val value = enumDescriptor.getElementIndex(name)
        return if (value == CompositeDecoder.UNKNOWN_NAME) {
            throw V8DecodingException("Enum of type ${enumDescriptor.serialName} has unknown value $name")
        } else {
            value
        }
    }

    override fun decodeFloat(): Float {
        return currentNode.decodeValue()
    }

    override fun decodeInt(): Int {
        return currentNode.decodeValue()
    }

    override fun decodeLong(): Long {
        return currentNode.decodeValue()
    }

    override fun decodeNotNullMark(): Boolean {
        return currentNode.decodeNotNullMark()
    }

    override fun decodeNull(): Nothing? {
        return null
    }

    override fun decodeShort(): Short {
        return currentNode.decodeValue()
    }

    override fun decodeString(): String {
        return currentNode.decodeValue()
    }

    override fun decodeUnit() {
        // nothing to do
    }

    override fun decodeBooleanElement(descriptor: SerialDescriptor, index: Int): Boolean {
        return currentNode.decodeNamedValue(descriptor.getElementName(index))
    }

    override fun decodeByteElement(descriptor: SerialDescriptor, index: Int): Byte {
        return currentNode.decodeNamedValue(descriptor.getElementName(index))
    }

    override fun decodeCharElement(descriptor: SerialDescriptor, index: Int): Char {
        return currentNode.decodeNamedValue(descriptor.getElementName(index))
    }

    override fun decodeDoubleElement(descriptor: SerialDescriptor, index: Int): Double {
        return currentNode.decodeNamedValue(descriptor.getElementName(index))
    }

    override fun decodeElementIndex(descriptor: SerialDescriptor): Int {
        while (currentNode.position < currentNode.totalElements) {
            return currentNode.decodeElementIndex(descriptor)
        }
        return CompositeDecoder.READ_DONE
    }

    override fun decodeFloatElement(descriptor: SerialDescriptor, index: Int): Float {
        return currentNode.decodeNamedValue(descriptor.getElementName(index))
    }

    override fun decodeIntElement(descriptor: SerialDescriptor, index: Int): Int {
        return currentNode.decodeNamedValue(descriptor.getElementName(index))
    }

    override fun decodeLongElement(descriptor: SerialDescriptor, index: Int): Long {
        return currentNode.decodeNamedValue(descriptor.getElementName(index))
    }

    override fun decodeShortElement(descriptor: SerialDescriptor, index: Int): Short {
        return currentNode.decodeNamedValue(descriptor.getElementName(index))
    }

    override fun decodeStringElement(descriptor: SerialDescriptor, index: Int): String {
        return currentNode.decodeNamedValue(descriptor.getElementName(index))
    }

    override fun decodeUnitElement(descriptor: SerialDescriptor, index: Int) {
        // nothing to do
    }

    override fun <T : Any> decodeNullableSerializableElement(
        descriptor: SerialDescriptor,
        index: Int,
        deserializer: DeserializationStrategy<T?>
    ): T? {
        return decodeNullableSerializableValue(deserializer)
    }

    override fun <T> decodeSerializableElement(
        descriptor: SerialDescriptor,
        index: Int,
        deserializer: DeserializationStrategy<T>
    ): T {
        return decodeSerializableValue(deserializer)
    }

    override fun endStructure(descriptor: SerialDescriptor) {

        // pop the current node off the stack
        nodes.pop()
    }

    override fun <T : Any> updateNullableSerializableElement(
        descriptor: SerialDescriptor,
        index: Int,
        deserializer: DeserializationStrategy<T?>,
        old: T?
    ): T? {
        return updateNullableSerializableValue(deserializer, old)
    }

    override fun <T> updateSerializableElement(
        descriptor: SerialDescriptor,
        index: Int,
        deserializer: DeserializationStrategy<T>,
        old: T
    ): T {
        return updateSerializableValue(deserializer, old)
    }

    private sealed class InputNode(
        val totalElements: Int,
        val v8Object: V8Object
    ) {

        var position: Int = 0
        var deferredKey: String? = null

        open fun <T : Any> handleValue(kClass: KClass<T>): T? = null

        fun decodeNotNullMark(): Boolean {
            return deferredKey?.let { key -> v8Object.get(key) } != null
        }

        inline fun <reified T : Any> decodeValue(): T {
            return handleValue(T::class) ?: deferredKey?.let { key -> decodeNamedValue<T>(key) }
            ?: throw invalidValueTypeDecodingException(T::class)
        }

        open fun decodeElementIndex(descriptor: SerialDescriptor): Int {
            deferredKey = descriptor.getElementName(position++)
            return if (deferredKey in v8Object) {
                position - 1 // index
            } else {
                CompositeDecoder.UNKNOWN_NAME
            }
        }

        inline fun <reified T> decodeNamedValue(name: String): T {
            @Suppress("IMPLICIT_CAST_TO_ANY")
            return when (T::class) {
                Byte::class -> v8Object.getInteger(name).toByte()
                Short::class -> v8Object.getInteger(name).toShort()
                Char::class -> v8Object.getInteger(name).toChar()
                Int::class -> v8Object.getInteger(name)
                Long::class -> v8Object.getDouble(name).toLong()
                Float::class -> v8Object.getDouble(name).toFloat()
                Double::class -> v8Object.getDouble(name)
                String::class -> v8Object.getString(name)
                Boolean::class -> v8Object.getBoolean(name)
                Enum::class -> v8Object.getString(name)
                else -> throw invalidValueTypeDecodingException(T::class)
            } as T
        }

        class ObjectInputNode(descriptor: SerialDescriptor, obj: V8Object) :
            InputNode(descriptor.elementsCount, obj)

        class UndefinedInputNode(obj: V8Object) : InputNode(0, obj)

        class ListInputNode(v8Array: V8Array) :
            InputNode(v8Array.keys.size, v8Array)

        class MapInputNode(
            obj: V8Object
        ) : InputNode(obj.keys.size * 2, obj) {

            override fun decodeElementIndex(descriptor: SerialDescriptor): Int {
                position++
                return position - 1 // index
            }

            @Suppress("UNCHECKED_CAST")
            override fun <T : Any> handleValue(kClass: KClass<T>): T? {
                val pos = position - 1
                val key = deferredKey

                // if divisible by two this is the key
                return when {
                    pos.rem(2) == 0 -> {
                        v8Object.keys[pos / 2].also { deferredKey = it } as T
                    }
                    key != null -> {
                        when (kClass) {
                            Byte::class -> v8Object.getInteger(key).toByte()
                            Short::class -> v8Object.getInteger(key).toShort()
                            Char::class -> v8Object.getInteger(key).toChar()
                            Int::class -> v8Object.getInteger(key)
                            Long::class -> v8Object.getDouble(key).toLong()
                            Float::class -> v8Object.getDouble(key).toFloat()
                            Double::class -> v8Object.getDouble(key)
                            String::class -> v8Object.getString(key)
                            Boolean::class -> v8Object.getBoolean(key)
                            Enum::class -> v8Object.getString(key)
                            else -> throw invalidValueTypeDecodingException(kClass)
                        } as T
                    }
                    else -> throw V8DecodingException(
                        "Unexpected state, key is null while " +
                            "decoding value of class type ${kClass.simpleName}"
                    )
                }
            }
        }
    }
}
