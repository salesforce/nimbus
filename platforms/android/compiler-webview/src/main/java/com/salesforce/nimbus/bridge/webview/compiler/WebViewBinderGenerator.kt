package com.salesforce.nimbus.bridge.webview.compiler

import com.salesforce.nimbus.compiler.BinderGenerator
import com.squareup.kotlinpoet.ClassName

class WebViewBinderGenerator : BinderGenerator() {
    override val javascriptEngine = ClassName("android.webkit", "WebView")
    override val serializedOutputType = ClassName("kotlin", "String")
    override val functionAnnotationClassName = ClassName("android.webkit", "JavascriptInterface")
}
