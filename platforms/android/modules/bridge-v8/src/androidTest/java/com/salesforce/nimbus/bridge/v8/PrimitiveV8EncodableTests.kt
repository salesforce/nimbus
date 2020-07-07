package com.salesforce.nimbus.bridge.v8

import androidx.test.ext.junit.runners.AndroidJUnit4
import com.eclipsesource.v8.V8
import com.eclipsesource.v8.V8Array
import com.salesforce.k2v8.scope
import io.kotest.core.config.AbstractProjectConfig
import io.kotest.core.extensions.Extension
import io.kotest.core.spec.style.StringSpec
import io.kotest.property.forAll
import org.junit.runner.RunWith
import io.kotest.core.test.TestContext
import io.kotest.experimental.robolectric.RobolectricExtension
import io.kotest.experimental.robolectric.RobolectricTest

class MyProjectLevelConfig : AbstractProjectConfig() {
    override fun extensions(): List<Extension> = super.extensions() + RobolectricExtension()
}

@RobolectricTest
//@RunWith(AndroidJUnit4::class)
class PrimitiveV8EncodableTests : StringSpec ({

    lateinit var v8: V8

    beforeTest {
        v8 = V8.createV8Runtime()
    }

    afterTest {
        v8.close()
    }

    "double to V8" {
            forAll<Double> { a ->
                // Comparing NaN requires a different way
                v8.scope {
                    // https://stackoverflow.com/questions/37884133/comparing-nan-in-kotlin
                    if (a == Double.POSITIVE_INFINITY || a == Double.NEGATIVE_INFINITY || a.equals(Double.NaN as Number)) {
                        var sameExceptionMessage = false
                        try {
                            a.toV8Encodable(v8)
                        } catch (e: Exception) {
                            sameExceptionMessage = e.message.equals("Double value should be finite.")
                        }
                        sameExceptionMessage
                    } else {
                        val array = a.toV8Encodable(v8).encode() as V8Array
                        val value = array.getDouble(0)
                        a == value
                    }
                }
            }

//        @Test
//        fun testIntToV8() = v8.scope {
//            forAll(Gen.int()) { a ->
//                val array = a.toV8Encodable(v8).encode() as V8Array
//                val value = array.getInteger(0)
//                a == value
//            }
//        }
//
//        @Test
//        fun testBooleanToV8() = v8.scope {
//            forAll(Gen.bool()) { a ->
//                val array = a.toV8Encodable(v8).encode() as V8Array
//                val value = array.getBoolean(0)
//                a == value
//            }
//        }
//
//        @Test
//        fun testLongToV8() = v8.scope {
//            forAll(Gen.long()) { a ->
//                val array = a.toV8Encodable(v8).encode() as V8Array
//                val value = array.getDouble(0)
//
//                // v8 doesn't support long so must convert to double for comparison
//                a.toDouble() == value
//            }
//        }
//
//        @Test
//        fun testStringToV8() = v8.scope {
//            forAll(Gen.string()) { a ->
//                val array = a.toV8Encodable(v8).encode() as V8Array
//                val value = array.getString(0)
//                a == value
//            }
//        }
    }
})
