plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.namma_wallet"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_21
        targetCompatibility = JavaVersion.VERSION_21
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
        }
    }

    defaultConfig {
        applicationId = "com.example.namma_wallet"
        minSdk = 26
        targetSdk = 36
        versionCode = flutter.versionCode
        versionName = flutter.versionName

        resValue("string", "app_name", "Namma Wallet")
    }

    applicationVariants.all {
        outputs.all {
            this as com.android.build.gradle.internal.api.ApkVariantOutputImpl

            outputFileName = "namma-wallet-$versionName.apk"
        }
    }

    buildTypes {
        configureEach {
            isShrinkResources = false
            isMinifyEnabled = false

            signingConfig = signingConfigs["debug"]
        }

        release {
            isShrinkResources = true
            isMinifyEnabled = true

            val keystoreFile = file("keystore.jks")
            if (keystoreFile.exists()) {
                signingConfig = signingConfigs.create("release") {
                    storeFile = keystoreFile
                    storePassword = System.getenv("KEYSTORE_PASSWORD")
                    keyAlias = System.getenv("KEYSTORE_ENTRY_ALIAS")
                    keyPassword = System.getenv("KEYSTORE_ENTRY_PASSWORD")
                }

                resValue("string", "app_name", "Namma Wallet")
            } else {
                resValue("string", "app_name", "Namma Wallet (Development)")
                signingConfig = signingConfigs["debug"]
            }
        }

        debug {
            resValue("string", "app_name", "Namma Wallet (Debug)")
        }

        named("profile") {
            initWith(getByName("debug"))
            resValue("string", "app_name", "Namma Wallet (Profile)")
        }
    }

    buildFeatures {
        viewBinding = true
    }
}

flutter {
    source = "../.."
}