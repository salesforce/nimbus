package com.salesforce.nimbus

@Retention(AnnotationRetention.RUNTIME)
@Target(AnnotationTarget.CLASS)
annotation class PluginOptions(
    val name: String,

    /**
     * Whether or not this plugin supports binding to a WebView. If true, a binder will be generated
     * for the WebView. Defaults to true.
     */
    val supportsWebView: Boolean = true,

    /**
     * Whether or not this plugin supports binding to V8. If true, a binder will be generated
     * for V8. Defaults to true.
     */
    val supportsV8: Boolean = true
)
