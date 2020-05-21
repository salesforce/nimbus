import org.json.simple.JSONObject
import org.json.simple.JSONValue
import java.io.File

object ProjectVersions {
    const val androidSdk = 29
    const val minSdk = 21
    const val thisLibrary = "2.0"

    fun parseVersion(): String{
        val versionFile = File("../../../lerna.json").readText()
        val parsed = JSONValue.parse(versionFile) as JSONObject
        return parsed.getOrDefault("version", thisLibrary) as String
    }
}


val isDevVersion = ProjectVersions.thisLibrary.contains("-dev-")
