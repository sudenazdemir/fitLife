plugins {
    id("com.android.application")
    kotlin("android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // 🔥 Firebase plugin (Doğru yer)
}

android {
    namespace = "com.fitlife.app"

    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    defaultConfig {
        applicationId = "com.fitlife.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11

        // 👇 EŞİTTİR İŞARETİ VE 'is' ÖNEKİ ÖNEMLİ
    isCoreLibraryDesugaringEnabled = true
    }
    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    // 🔥 Firebase BOM — DOĞRU YER
    implementation(platform("com.google.firebase:firebase-bom:34.6.0"))

    // 🔥 Analytics (isteğe bağlı)
    implementation("com.google.firebase:firebase-analytics")

    // 🔥 Auth (gerekli)
    implementation("com.google.firebase:firebase-auth")

   // 👇 PARANTEZ VE ÇİFT TIRNAK ÖNEMLİ
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}
