package com.salesforce.nimbus.bridge.v8.compiler

import com.salesforce.nimbus.compiler.asTypeName
import com.salesforce.nimbus.compiler.nimbusPackage
import com.salesforce.nimbus.compiler.salesforceNamespace
import com.squareup.kotlinpoet.*
import javax.lang.model.element.Element


object V8BinderGeneratorHelper {

    // Package names
    const val PACKAGE_NAME_V8 = "com.eclipsesource.v8"
    const val PACKAGE_NAME_NIMBUS_BRIDGE_V8 = "$nimbusPackage.bridge.v8"
    const val PACKAGE_NAME_K2V8 = "$salesforceNamespace.k2v8"

    // Class names
    val CLASS_NAME_V8 = ClassName(PACKAGE_NAME_V8, "V8")
    val CLASS_NAME_V8Object = ClassName(PACKAGE_NAME_V8, "V8Object")
    val CLASS_NAME_V8Array = ClassName(PACKAGE_NAME_V8, "V8Array")
    val CLASS_NAME_V8Function = ClassName(PACKAGE_NAME_V8, "V8Function")
    val CLASS_NAME_V8Releasable = ClassName(PACKAGE_NAME_V8, "Releasable")

    val CLASS_NAME_K2V8 = ClassName(PACKAGE_NAME_K2V8, "K2V8")
    val CLASS_NAME_K2V8_CONFIGURATION = ClassName(PACKAGE_NAME_K2V8, "Configuration")
    val CLASS_NAME_K2V8_TO_V8_ARRAY= ClassName(V8BinderGeneratorHelper.PACKAGE_NAME_K2V8, "toV8Array")

    val CLASS_NAME_NIMBUS_BRIDGE = ClassName(nimbusPackage, "NIMBUS_BRIDGE")
    val CLASS_NAME_NIMBUS_PLUGINS = ClassName(nimbusPackage, "NIMBUS_PLUGINS")

    val CLASS_NAME_RESOLVE_PROMISE = ClassName(PACKAGE_NAME_NIMBUS_BRIDGE_V8, "resolvePromise")
    val CLASS_NAME_REJECT_PROMISE = ClassName(PACKAGE_NAME_NIMBUS_BRIDGE_V8, "rejectPromise")
    val CLASS_NAME_REGISTER_JAVA_CALLBACK = ClassName(PACKAGE_NAME_NIMBUS_BRIDGE_V8, "registerJavaCallback")

    fun addClassProperties(builder: TypeSpec.Builder) {
        builder.addProperties(
            listOf(
                PropertySpec.builder(
                    "k2v8",
                    CLASS_NAME_K2V8.copy(nullable = true),
                    KModifier.PRIVATE
                )
                    .mutable()
                    .initializer("null")
                    .build()
            )
        )
    }
}
