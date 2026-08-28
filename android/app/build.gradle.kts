import java.util.Properties
import groovy.json.JsonSlurper

fun googleServicesApiKey(file: File): String {
    if (!file.exists()) return ""
    val root = JsonSlurper().parse(file) as? Map<*, *> ?: return ""
    val client = (root["client"] as? List<*>)?.firstOrNull() as? Map<*, *> ?: return ""
    val keys = client["api_key"] as? List<*> ?: return ""
    val key = keys.firstOrNull() as? Map<*, *> ?: return ""
    return key["current_key"] as? String ?: ""
}

plugins {
    id("com.android.application")
    id("com.google.gms.google-services")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.livesmart"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.livesmart"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        val localProperties = Properties()
        val localPropertiesFile = rootProject.file("local.properties")
        if (localPropertiesFile.exists()) {
            localPropertiesFile.inputStream().use(localProperties::load)
        }
        val configuredMapsKey = localProperties.getProperty("MAPS_API_KEY")
            ?: googleServicesApiKey(file("google-services.json"))
        manifestPlaceholders["MAPS_API_KEY"] = configuredMapsKey
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
