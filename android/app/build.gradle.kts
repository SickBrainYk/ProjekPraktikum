plugins {
    id("com.android.application")
    id("org.jetbrains.kotlin.android")
    // Flutter plugin harus di-load setelah Android & Kotlin plugin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.cobaaplikasi1"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.example.cobaaplikasi1"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    // ✅ Perbaikan utama untuk notifikasi (Java 17 + desugaring)
    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        isCoreLibraryDesugaringEnabled = true // Kotlin DSL pakai 'is...'
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    buildTypes {
        release {
            // Untuk sementara gunakan debug key agar tidak error signing
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // Kotlin standard library (versi otomatis dari plugin Kotlin)
    implementation(kotlin("stdlib"))

    // ✅ Library desugaring wajib untuk flutter_local_notifications
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
