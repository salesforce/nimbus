package com.salesforce.nimbus.extensions

import android.content.Context
import android.content.pm.PackageManager
import com.salesforce.nimbus.Extension
import com.salesforce.nimbus.ExtensionMethod
import com.salesforce.nimbus.JSONSerializable
import com.salesforce.nimbus.NimbusExtension
import org.json.JSONObject

@Extension(name = "DeviceExtension")
class DeviceExtension(context: Context) : NimbusExtension {

    class DeviceInfo(val appVersion: String) : JSONSerializable {
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

    val cachedDeviceInfo: DeviceInfo

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

    @ExtensionMethod
    fun getDeviceInfo(): DeviceInfo {
        return cachedDeviceInfo
    }
}
