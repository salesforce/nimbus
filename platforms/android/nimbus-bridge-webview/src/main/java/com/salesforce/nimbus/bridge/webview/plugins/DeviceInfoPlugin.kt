package com.salesforce.nimbus.bridge.webview.plugins

import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import android.webkit.WebView
import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.Runtime
import com.salesforce.nimbus.JSONSerializable
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import org.json.JSONObject

@PluginOptions(name = "DeviceInfoPlugin")
class DeviceInfoPlugin(context: Context) : Plugin {

    class DeviceInfo(val appVersion: String) :
        JSONSerializable {
        val platform: String = "Android"
        val platformVersion: String = android.os.Build.VERSION.RELEASE
        val manufacturer: String = android.os.Build.MANUFACTURER
        val model: String = android.os.Build.MODEL

        override fun stringify(): String {
            val jsonObject = JSONObject()
            jsonObject.put("platform", platform)
            jsonObject.put("platformVersion", platformVersion)
            jsonObject.put("manufacturer", manufacturer)
            jsonObject.put("model", model)
            jsonObject.put("appVersion", appVersion)
            return jsonObject.toString()
        }
    }

    private val cachedDeviceInfo: DeviceInfo

    init {
        var appVersion = "unknown"
        try {
            val appContext = context.applicationContext
            val packageManager = appContext.packageManager
            val packageName = appContext.packageName
            appVersion = packageManager.getPackageInfo(packageName, 0).versionName
        } catch (e: PackageManager.NameNotFoundException) {
        }
        cachedDeviceInfo = DeviceInfo(appVersion)
    }

    @BoundMethod
    fun getDeviceInfo(): DeviceInfo {
        return cachedDeviceInfo
    }

    override fun <JavascriptEngine> customize(runtime: Runtime<JavascriptEngine>) {

        // example for how to do customizations on a specific JavascriptEngine (WebView, v8)
        when (runtime.getJavascriptEngine()) {
            is WebView -> {
                Log.d("DeviceInfoPlugin", "Customizing WebView...")
            }
        }
    }

    override fun <JavascriptEngine> cleanup(runtime: Runtime<JavascriptEngine>) {

        // example for how to do cleanup on a specific JavascriptEngine (WebView, v8)
        when (runtime.getJavascriptEngine()) {
            is WebView -> {
                Log.d("DeviceInfoPlugin", "Cleaning up WebView...")
            }
        }
    }
}
