//
// Copyright (c) 2019, Salesforce.com, inc.
// All rights reserved.
// SPDX-License-Identifier: BSD-3-Clause
// For full license text, see the LICENSE file in the repo root or https://opensource.org/licenses/BSD-3-Clause
//

package com.salesforce.nimbusdemoapp

import android.app.Activity
import android.content.Context
import android.os.Bundle
import android.util.Log
import android.webkit.WebView
import android.widget.Button
import android.widget.EditText
import android.widget.Toast
import androidx.annotation.MainThread
import androidx.appcompat.app.AppCompatActivity
import com.eclipsesource.v8.V8
import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.BoundPlugin
import com.salesforce.nimbus.DefaultEventPublisher
import com.salesforce.nimbus.Event
import com.salesforce.nimbus.EventPublisher
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import com.salesforce.nimbus.bridge.v8.V8Bridge
import com.salesforce.nimbus.bridge.v8.bridge
import com.salesforce.nimbus.bridge.webview.WebViewBridge
import com.salesforce.nimbus.bridge.webview.bridge
import com.salesforce.nimbus.core.plugins.DeviceInfoPlugin
import kotlinx.serialization.Serializable
import java.lang.RuntimeException
import java.util.concurrent.Executors

class MainActivity : AppCompatActivity() {

    @BoundPlugin
    private lateinit var deviceInfoPlugin: DeviceInfoPlugin
    private lateinit var webViewBridge: WebViewBridge
    private lateinit var v8Bridge: V8Bridge
    private lateinit var v8: V8

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_main)
        WebView.setWebContentsDebuggingEnabled(true)
        val webView = findViewById<WebView>(R.id.webview)

        // create the device info plugin
        deviceInfoPlugin = DeviceInfoPlugin(this)

        // create some other plugins
        val logPlugin = LogPlugin()
        val toastPlugin = ToastPlugin(this)
        val eventPlugin = EventPlugin()
        val exceptionPlugin = ExceptionPlugin()

        // create the web view bridge
        webViewBridge = webView.bridge {
            bind { deviceInfoPlugin.webViewBinder() }
            bind { logPlugin.webViewBinder() }
            bind { toastPlugin.webViewBinder() }
            bind { eventPlugin.webViewBinder() }
            bind { exceptionPlugin.webViewBinder() }
        }

        // load the demo url
        webView.loadUrl("http://10.0.2.2:3000")

        val executorService = Executors.newSingleThreadExecutor()
        // create a v8 runtime
        v8 = executorService.submit<V8> { V8.createV8Runtime() }.get()

        // create the v8 bridge
        v8Bridge = v8.bridge(executorService) {
            bind { deviceInfoPlugin.v8Binder() }
            bind { logPlugin.v8Binder() }
            bind { toastPlugin.v8Binder() }
            bind { eventPlugin.v8Binder() }
            bind { exceptionPlugin.v8Binder() }
        }

        // execute a script to get the device info plugin and then log to the console
        v8Bridge.executeScriptOnExecutor(
            """
                __nimbus.plugins.DeviceInfoPlugin.getDeviceInfo().then((deviceInfo) => {
                    let json = JSON.stringify(deviceInfo);
                    __nimbus.plugins.LogPlugin.debug('DemoApp', json);
                    __nimbus.plugins.ToastPlugin.toast('Device Info from V8: ' + json);
                });

                __nimbus.plugins.EventPlugin.addListener("logEvent", (event) => {
                    __nimbus.plugins.LogPlugin.debug("LogPlugin", "V8: " + JSON.stringify(event));
                });

                __nimbus.plugins.EventPlugin.addListener("toastEvent", (event) => {
                    __nimbus.plugins.ToastPlugin.toast("V8: " + event.message);
                });

                __nimbus.plugins.ExceptionPlugin.throwException(true).then((data) => {
                    __nimbus.plugins.LogPlugin.debug("ExceptionPlugin", "ExceptionPlugin.throwException() returned data:");
                    __nimbus.plugins.LogPlugin.debug("ExceptionPlugin", JSON.stringify(data));
                }).catch((error) => {
                    __nimbus.plugins.LogPlugin.debug("ExceptionPlugin", "ExceptionPlugin.throwException() returned error:");
                    __nimbus.plugins.LogPlugin.debug("ExceptionPlugin", JSON.stringify(error));
                });

                __nimbus.plugins.ExceptionPlugin.throwSerializableException(1).then((data) => {
                    __nimbus.plugins.LogPlugin.debug("ExceptionPlugin", "ExceptionPlugin.throwSerializableException() returned data:");
                    __nimbus.plugins.LogPlugin.debug("ExceptionPlugin", JSON.stringify(data));
                }).catch((error) => {
                    __nimbus.plugins.LogPlugin.debug("ExceptionPlugin", "ExceptionPlugin.throwSerializableException() returned error:");
                    __nimbus.plugins.LogPlugin.debug("ExceptionPlugin", JSON.stringify(error));
                });

                __nimbus.plugins.ExceptionPlugin.throwSerializableException().then((data) => {
                    __nimbus.plugins.LogPlugin.debug("ExceptionPlugin", "ExceptionPlugin.throwSerializableException() returned data:");
                    __nimbus.plugins.LogPlugin.debug("ExceptionPlugin", JSON.stringify(data));
                }).catch((error) => {
                    __nimbus.plugins.LogPlugin.debug("ExceptionPlugin", "ExceptionPlugin.throwSerializableException() returned error:");
                    __nimbus.plugins.LogPlugin.debug("ExceptionPlugin", JSON.stringify(error));
                });
            """.trimIndent()
        )

        val logMessage = findViewById<EditText>(R.id.log_message)
        findViewById<Button>(R.id.publish_log_event_button).setOnClickListener {
            eventPlugin.publishEvent(MessageEvents.LogEvent(logMessage.text.toString()))
        }

        val toastMessage = findViewById<EditText>(R.id.toast_message)
        findViewById<Button>(R.id.publish_toast_event_button).setOnClickListener {
            eventPlugin.publishEvent(MessageEvents.ToastEvent(toastMessage.text.toString()))
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        webViewBridge.detach()
        v8Bridge.detach()
    }
}

@PluginOptions("LogPlugin")
class LogPlugin : Plugin {

    @BoundMethod
    fun debug(tag: String, message: String) {
        Log.d(tag, message)
    }
}

@PluginOptions("ToastPlugin")
class ToastPlugin(private val context: Activity) : Plugin {

    @BoundMethod
    fun toast(message: String) {
        context.runOnUiThread { Toast.makeText(context, message, Toast.LENGTH_LONG).show() }
    }
}

@Serializable
sealed class MessageEvents : Event {

    @Serializable
    data class LogEvent(val message: String) : MessageEvents() {
        override val name: String = "logEvent"
    }

    @Serializable
    data class ToastEvent(val message: String) : MessageEvents() {
        override val name: String = "toastEvent"
    }
}

@PluginOptions("EventPlugin")
class EventPlugin : Plugin, EventPublisher<MessageEvents> by DefaultEventPublisher()

@Serializable
class SerializableException1(val code: Int, override val message: String) : RuntimeException("$code, $message")

@Serializable
class SerializableException2(val code: Int, override val message: String) : RuntimeException("$code, $message")

@PluginOptions("ExceptionPlugin")
class ExceptionPlugin : Plugin {

    @BoundMethod
    fun throwException(throwException: Boolean): String {
        return if (throwException) {
            throw Exception("This is the exception")
        } else {
            "This is the return value"
        }
    }

    @BoundMethod(throwsExceptions = [SerializableException1::class, SerializableException2::class])
    fun throwSerializableException(value: Int): String {
        when (value) {
            1 -> throw SerializableException1(1, "SerializableException1")
            2 -> throw SerializableException2(2, "SerializableException2")
            else -> return "This is the return value"
        }
    }
}
