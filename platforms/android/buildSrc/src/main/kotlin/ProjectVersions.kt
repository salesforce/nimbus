import org.json.simple.JSONObject
import org.json.simple.JSONValue
import java.io.File

object ProjectVersions {
    const val androidSdk = 29
    const val minSdk = 21
    // TODO: Switch back to lazy parsedVersion when publishing is using kotlin plugin
    const val packageVersion = "0.0.16-alpha"
//    val packageVersion: String by lazy {
//        parseVersion()
//    }

    private fun parseVersion(): String{
        val versionFile = File("../../lerna.json").readText()
        println(versionFile)
        val parsed = JSONValue.parse(versionFile) as JSONObject
        return parsed.getOrDefault("version", packageVersion) as String
    }
}
