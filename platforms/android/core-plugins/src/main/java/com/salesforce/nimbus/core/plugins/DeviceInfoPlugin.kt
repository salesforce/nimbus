package com.salesforce.nimbus.core.plugins

import android.content.Context
import android.os.Build
import com.salesforce.nimbus.BoundMethod
import com.salesforce.nimbus.Plugin
import com.salesforce.nimbus.PluginOptions
import kotlinx.serialization.Serializable

@PluginOptions(name = "DeviceInfoPlugin")
class DeviceInfoPlugin(context: Context) : Plugin {

    @Serializable
    data class DeviceInfo(
        val appVersion: String,
        val platform: String = "Android",
        val platformVersion: String = Build.VERSION.RELEASE,
        val manufacturer: String = Build.MANUFACTURER,
        val model: String = Build.MODEL
    )

    private val deviceInfo: DeviceInfo = DeviceInfo(
        context.packageManager.getPackageInfo(context.packageName, 0).versionName ?: "unknown"
    )

    @BoundMethod
    fun getDeviceInfo(): DeviceInfo {
        return deviceInfo
    }
}
