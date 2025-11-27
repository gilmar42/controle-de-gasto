plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.controle_gasto"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_1_8
        targetCompatibility = JavaVersion.VERSION_1_8
    }

    kotlinOptions {
        jvmTarget = "1.8"
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.example.controle_gasto"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = 34
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        multiDexEnabled = true
        vectorDrawables.useSupportLibrary = true
        resConfigs("pt", "en")
        ndk {
            abiFilters += listOf("armeabi-v7a", "arm64-v8a")
        }
    }

    buildTypes {
        release {
            // Disable shrinking/obfuscation for stability (re-enable after confirming bundle build)
            isMinifyEnabled = false
            // Explicitly disable resource shrinking to match minify setting
            isShrinkResources = false
            // Temporary signing with debug keystore; replace with release config when you add keystore
            signingConfig = signingConfigs.getByName("debug")
        }
    }

    buildFeatures {
        viewBinding = true
    }

    // ABI splits removed for App Bundle build (bundle already delivers optimized splits)

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // MultiDex support for apps exceeding 64K method references on older devices
    implementation("androidx.multidex:multidex:2.0.1")
    // Play Core for deferred components classes referenced by Flutter engine
    implementation("com.google.android.play:core:1.10.3")
}
