import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.nammaflutter.nammawallet"
    compileSdk = 36
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlin {
        compilerOptions {
            jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
        }
    }

    defaultConfig {
        applicationId = "com.nammaflutter.nammawallet"
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

            val keystoreFile = file("namma-wallet.keystore")
            val keystorePropertiesFile = rootProject.file("keystore.properties")
            val keystoreProperties = Properties()
            var hasAllKeys = false
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(keystorePropertiesFile.inputStream())
                hasAllKeys = listOf(
                    "KEYSTORE_PASSWORD",
                    "KEYSTORE_ENTRY_ALIAS",
                    "KEYSTORE_ENTRY_PASSWORD"
                ).all { keystoreProperties.containsKey(it) }
            }

            if (keystoreFile.exists() && hasAllKeys) {
                signingConfig = signingConfigs.create("release") {
                    storeFile = keystoreFile
                    storePassword = keystoreProperties["KEYSTORE_PASSWORD"]!!.toString()
                    keyAlias = keystoreProperties["KEYSTORE_ENTRY_ALIAS"]!!.toString()
                    keyPassword = keystoreProperties["KEYSTORE_ENTRY_PASSWORD"]!!.toString()
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