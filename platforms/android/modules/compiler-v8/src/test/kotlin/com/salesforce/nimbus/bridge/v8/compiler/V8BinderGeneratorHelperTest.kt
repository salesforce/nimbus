package com.salesforce.nimbus.bridge.v8.compiler

import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.addClassProperties
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_K2V8
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_K2V8_CONFIGURATION
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_K2V8_TO_V8_ARRAY
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_NIMBUS_BRIDGE
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_NIMBUS_PLUGINS
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_REGISTER_JAVA_CALLBACK
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_REJECT_PROMISE
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_RESOLVE_PROMISE
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_V8Array
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_V8
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_V8Function
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_V8Object
import com.salesforce.nimbus.bridge.v8.compiler.V8BinderGeneratorHelper.CLASS_NAME_V8Releasable
import com.squareup.kotlinpoet.TypeSpec
import org.junit.Assert.assertEquals
import org.junit.Assert.assertTrue
import org.junit.Test

class V8BinderGeneratorHelperTest {

    @Test
    fun verifyClassNames() {
        assertEquals("com.eclipsesource.v8.V8", CLASS_NAME_V8.toString())
        assertEquals("com.eclipsesource.v8.V8Object", CLASS_NAME_V8Object.toString())
        assertEquals("com.eclipsesource.v8.V8Array", CLASS_NAME_V8Array.toString())
        assertEquals("com.eclipsesource.v8.V8Function", CLASS_NAME_V8Function.toString())
        assertEquals("com.eclipsesource.v8.Releasable", CLASS_NAME_V8Releasable.toString())

        assertEquals("com.salesforce.k2v8.K2V8", CLASS_NAME_K2V8.toString())
        assertEquals("com.salesforce.k2v8.Configuration", CLASS_NAME_K2V8_CONFIGURATION.toString())
        assertEquals("com.salesforce.k2v8.toV8Array", CLASS_NAME_K2V8_TO_V8_ARRAY.toString())

        assertEquals("com.salesforce.nimbus.NIMBUS_BRIDGE", CLASS_NAME_NIMBUS_BRIDGE.toString())
        assertEquals("com.salesforce.nimbus.NIMBUS_PLUGINS", CLASS_NAME_NIMBUS_PLUGINS.toString())

        assertEquals("com.salesforce.nimbus.bridge.v8.registerJavaCallback", CLASS_NAME_REGISTER_JAVA_CALLBACK.toString())

        assertEquals(
            "com.salesforce.nimbus.bridge.v8.resolvePromise",
            CLASS_NAME_RESOLVE_PROMISE.toString()
        )
        assertEquals(
            "com.salesforce.nimbus.bridge.v8.rejectPromise",
            CLASS_NAME_REJECT_PROMISE.toString()
        )
    }

    @Test
    fun addClassPropertiesTest() {
        val typeSpec = TypeSpec.classBuilder("DemoClass")
        addClassProperties(typeSpec)
        val outPut = typeSpec.build().toString()

        assertTrue(outPut.contains("""private var k2v8: com.salesforce.k2v8.K2V8? = null"""))
    }
}
