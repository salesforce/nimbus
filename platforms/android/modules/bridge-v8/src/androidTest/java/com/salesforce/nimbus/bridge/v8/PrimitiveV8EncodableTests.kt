package com.salesforce.nimbus.bridge.v8

import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
import com.salesforce.k2v8.scope
import io.kotest.core.spec.style.StringSpec
import io.kotest.matchers.booleans.shouldBeTrue
import io.kotest.matchers.shouldBe
import io.kotest.property.checkAll
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class PrimitiveV8EncodableTests : StringSpec({

    lateinit var v8: V8

    beforeTest {
        v8 = V8.createV8Runtime()
    }

    afterTest() {
        v8.close()
    }

    "Double toV8Encodable" {
        v8.scope {
            checkAll<Double> { a ->
                // Comparing NaN requires a different way
                // https://stackoverflow.com/questions/37884133/comparing-nan-in-kotlin
                if (a == Double.POSITIVE_INFINITY || a == Double.NEGATIVE_INFINITY || a.equals(Double.NaN as Number)) {
                    var sameExceptionMessage = false
                    try {
                        a.toV8Encodable(v8)
                    } catch (e: Exception) {
                        sameExceptionMessage = e.message.equals("Double value should be finite.")
                    }
                    sameExceptionMessage.shouldBeTrue()
                } else {
                    val array = a.toV8Encodable(v8).encode() as V8Array
                    val value = array.getDouble(0)
                    a.shouldBe(value)
                }
            }
        }
    }

    "Int toV8Encodable" {
        v8.scope {
            checkAll<Int> { a ->
                val array = a.toV8Encodable(v8).encode() as V8Array
                val value = array.getInteger(0)
                a.shouldBe(value)
            }
        }
    }

    "Boolean toV8Encodable" {
        v8.scope {
            checkAll<Boolean> { a ->
                val array = a.toV8Encodable(v8).encode() as V8Array
                val value = array.getBoolean(0)
                a.shouldBe(value)
            }
        }
    }

    "Long toV8Encodable" {
        v8.scope {
            checkAll<Long> { a ->
                val array = a.toV8Encodable(v8).encode() as V8Array
                val value = array.getDouble(0)

                // v8 doesn't support long so must convert to double for comparison
                a.toDouble().shouldBe(value)
            }
        }
    }

    "String toV8Encodable" {
        v8.scope {
            checkAll<String> { a ->
                val array = a.toV8Encodable(v8).encode() as V8Array
                val value = array.getString(0)
                a.shouldBe(value)
            }
        }
    }
})
