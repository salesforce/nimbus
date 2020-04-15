package com.salesforce.nimbus.k2v8

import com.eclipsesource.v8.V8Array
import com.eclipsesource.v8.V8Object
import kotlinx.serialization.CompositeEncoder
import kotlinx.serialization.Encoder
import kotlinx.serialization.KSerializer
import kotlinx.serialization.SerialDescriptor
import kotlinx.serialization.SerializationStrategy
import kotlinx.serialization.StructureKind
import kotlinx.serialization.encode
import kotlinx.serialization.modules.SerialModule
import java.util.Stack

internal fun <T> K2V8.convertToV8Object(value: T, serializer: SerializationStrategy<T>): V8Object {
    lateinit var result: V8Object
    val encoder = V8ObjectEncoder(this) { result = it }
    encoder.encode(serializer, value)
    return result
}

class V8ObjectEncoder(
    private val k2V8: K2V8,
    override val context: SerialModule = k2V8.context,
    private val consumer: (V8Object) -> Unit
) : Encoder, CompositeEncoder {

    private val v8 = k2V8.configuration.runtime
    private var rootNode: OutputNode? = null
    private val nodes = Stack<OutputNode>()
    private val currentNode: OutputNode
        get() = nodes.peek()

    override fun beginStructure(
        descriptor: SerialDescriptor,
        vararg typeSerializers: KSerializer<*>
    ): CompositeEncoder {
        val key = if (nodes.isNotEmpty()) currentNode.deferredKey else null
        val node = when (descriptor.kind) {
            StructureKind.CLASS -> OutputNode.ObjectOutputNode(
                V8Object(v8)
            )
            StructureKind.LIST, StructureKind.MAP -> if (descriptor.kind == StructureKind.LIST) {
                OutputNode.ListOutputNode(
                    V8Array(v8)
                )
            } else {
                OutputNode.MapOutputNode(
                    V8Array(v8)
                )
            }
            StructureKind.OBJECT -> OutputNode.UndefinedOutputNode()
            else -> throw V8EncodingException("Unexpected kind encountered while trying to encode to V8Object: ${descriptor.kind}")
        }

        // if this is the root node set it
        if (rootNode == null) {
            rootNode = node
        } else if (key != null) {

            // if we have a deferred key then add this object to the current node
            node.v8Object?.let { currentNode.v8Object?.add(key, it) }
                ?: currentNode.v8Object?.addUndefined(key)
        }

        // push the node onto the stack
        nodes.push(node)

        // reset key
        currentNode.deferredKey = null

        return this
    }

    override fun encodeBoolean(value: Boolean) {
        currentNode.encodeValue(value)
    }

    override fun encodeByte(value: Byte) {
        currentNode.encodeValue(value)
    }

    override fun encodeChar(value: Char) {
        currentNode.encodeValue(value)
    }

    override fun encodeDouble(value: Double) {
        currentNode.encodeValue(value)
    }

    override fun encodeEnum(enumDescriptor: SerialDescriptor, index: Int) {
        currentNode.encodeValue(enumDescriptor.getElementName(index))
    }

    override fun encodeFloat(value: Float) {
        currentNode.encodeValue(value)
    }

    override fun encodeInt(value: Int) {
        currentNode.encodeValue(value)
    }

    override fun encodeLong(value: Long) {
        currentNode.encodeValue(value)
    }

    override fun encodeNull() {
        currentNode.encodeNull()
    }

    override fun encodeShort(value: Short) {
        currentNode.encodeValue(value)
    }

    override fun encodeString(value: String) {
        currentNode.encodeValue(value)
    }

    override fun encodeUnit() {
        currentNode.encodeUnit()
    }

    override fun encodeBooleanElement(descriptor: SerialDescriptor, index: Int, value: Boolean) {
        currentNode.encodeNamedValue(descriptor.getElementName(index), value)
    }

    override fun encodeByteElement(descriptor: SerialDescriptor, index: Int, value: Byte) {
        currentNode.encodeNamedValue(descriptor.getElementName(index), value)
    }

    override fun encodeCharElement(descriptor: SerialDescriptor, index: Int, value: Char) {
        currentNode.encodeNamedValue(descriptor.getElementName(index), value)
    }

    override fun encodeDoubleElement(descriptor: SerialDescriptor, index: Int, value: Double) {
        currentNode.encodeNamedValue(descriptor.getElementName(index), value)
    }

    override fun encodeFloatElement(descriptor: SerialDescriptor, index: Int, value: Float) {
        currentNode.encodeNamedValue(descriptor.getElementName(index), value)
    }

    override fun encodeIntElement(descriptor: SerialDescriptor, index: Int, value: Int) {
        currentNode.encodeNamedValue(descriptor.getElementName(index), value)
    }

    override fun encodeLongElement(descriptor: SerialDescriptor, index: Int, value: Long) {
        currentNode.encodeNamedValue(descriptor.getElementName(index), value)
    }

    override fun encodeShortElement(descriptor: SerialDescriptor, index: Int, value: Short) {
        currentNode.encodeNamedValue(descriptor.getElementName(index), value)
    }

    override fun encodeStringElement(descriptor: SerialDescriptor, index: Int, value: String) {
        currentNode.encodeNamedValue(descriptor.getElementName(index), value)
    }

    override fun encodeUnitElement(descriptor: SerialDescriptor, index: Int) {
        currentNode.encodeUnit()
    }

    override fun <T : Any> encodeNullableSerializableElement(
        descriptor: SerialDescriptor,
        index: Int,
        serializer: SerializationStrategy<T>,
        value: T?
    ) {
        currentNode.deferredKey = descriptor.getElementName(index)
        encodeNullableSerializableValue(serializer, value)
    }

    override fun <T> encodeSerializableElement(
        descriptor: SerialDescriptor,
        index: Int,
        serializer: SerializationStrategy<T>,
        value: T
    ) {
        currentNode.deferredKey = descriptor.getElementName(index)
        encodeSerializableValue(serializer, value)
    }

    override fun endStructure(descriptor: SerialDescriptor) {

        // pop the current node off the stack
        nodes.pop()

        // if the stack is empty we are done encoding
        if (nodes.empty()) {

            // notify consumer
            rootNode?.v8Object?.apply(consumer)
        }
    }

    private sealed class OutputNode(val v8Object: V8Object? = null) {

        var deferredKey: String? = null

        open fun <T : Any> encodeValue(value: T) {
            /* leave for subclasses to override */
        }

        fun encodeNull() {
            deferredKey?.let { key -> encodeNamedValue(key, null) }
        }

        fun encodeUnit() {
            deferredKey?.let { key -> encodeNamedValue(key, Unit) }
        }

        fun <T : Any> encodeNamedValue(name: String, value: T?) {
            when (val convertedValue = convertValue(value)) {
                null -> v8Object?.addNull(name)
                is Unit -> v8Object?.addUndefined(name)
                is Int -> v8Object?.add(name, convertedValue)
                is Double -> v8Object?.add(name, convertedValue)
                is String -> v8Object?.add(name, convertedValue)
                is Boolean -> v8Object?.add(name, convertedValue)
                else -> throw invalidValueTypeEncodingException(value!!::class)
            }
        }

        protected fun convertValue(value: Any?): Any? {
            return when (value) {
                is Byte -> value.toInt()
                is Short -> value.toInt()
                is Char -> value.toInt()
                is Long -> value.toDouble()
                is Float -> value.toDouble()
                else -> value
            }
        }

        class ObjectOutputNode(v8Object: V8Object) : OutputNode(v8Object) {
            override fun <T : Any> encodeValue(value: T) {
                deferredKey?.let { key -> encodeNamedValue(key, value) }
            }
        }

        class UndefinedOutputNode : OutputNode()

        class ListOutputNode(val v8Array: V8Array) : OutputNode(v8Array) {
            override fun <T : Any> encodeValue(value: T) {
                v8Array.push(convertValue(value))
            }
        }

        class MapOutputNode(v8Array: V8Array) : OutputNode(v8Array) {

            enum class State {
                KEY,
                VALUE
            }

            private var state: State = State.KEY
            private var key: String = ""

            override fun <T : Any> encodeValue(value: T) {
                when (state) {
                    State.KEY -> {
                        key =
                            value as? String ?: throw invalidKeyTypeEncodingException(value::class)
                        state = State.VALUE
                    }
                    State.VALUE -> {
                        encodeNamedValue(key, value)
                        state = State.KEY
                    }
                }
            }
        }
    }
}
