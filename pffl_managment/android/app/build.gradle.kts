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
            // Load keystore properties from local.properties or environment variables
            // For production, create a keystore using:
            // keytool -genkey -v -keystore pffl_key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias pffl
            val keystoreProperties = Properties()
            val keystorePropertiesFile = rootProject.file("local.properties")
            if (keystorePropertiesFile.exists()) {
                keystorePropertiesFile.inputStream().use { keystoreProperties.load(it) }
            }

            storeFile = file(keystoreProperties.getProperty("storeFile", "pffl_key.jks"))
            storePassword = keystoreProperties.getProperty("storePassword", "pffl_password")
            keyAlias = keystoreProperties.getProperty("keyAlias", "pffl")
            keyPassword = keystoreProperties.getProperty("keyPassword", "pffl_password")
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
