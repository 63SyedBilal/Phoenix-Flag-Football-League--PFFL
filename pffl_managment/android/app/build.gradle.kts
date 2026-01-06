import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.pffl_managment"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // Production Application ID for PFFL Management App
        applicationId = "com.pffl.managment"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            // Priority:
            // 1. Environment variables (set in CI or local shell)
            // 2. local.properties file
            // 3. Defaults
            val keystoreProperties = Properties()
            val keystorePropertiesFile = rootProject.file("local.properties")
            if (keystorePropertiesFile.exists()) {
                keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
            }

            val envStoreFile = System.getenv("KEYSTORE_FILE_PATH") ?: keystoreProperties.getProperty("storeFile")
            val envStorePassword = System.getenv("KEYSTORE_PASSWORD") ?: keystoreProperties.getProperty("storePassword")
            val envKeyAlias = System.getenv("KEY_ALIAS") ?: keystoreProperties.getProperty("keyAlias")
            val envKeyPassword = System.getenv("KEY_PASSWORD") ?: keystoreProperties.getProperty("keyPassword")

            storeFile = if (envStoreFile != null) file(envStoreFile) else file("pffl_key.jks")
            storePassword = envStorePassword ?: "pffl_password"
            keyAlias = envKeyAlias ?: "pffl"
            keyPassword = envKeyPassword ?: "pffl_password"
        }
    }

    buildTypes {
        release {
            // Enable ProGuard for code obfuscation
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")

            // Use release signing config
            signingConfig = signingConfigs.getByName("release")
        }
    }
}

dependencies {
    // Enable core library desugaring for packages that require Java 8+ features
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
