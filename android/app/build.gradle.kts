plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

import java.util.Properties

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

            val keystoreFile = file("keystore.jks")
            if (keystoreFile.exists()) {
                signingConfig = signingConfigs.create("release") {
                    storeFile = keystoreFile
                    storePassword = keystoreProperties["KEYSTORE_PASSWORD"] as String?
                    keyAlias = keystoreProperties["KEYSTORE_ENTRY_ALIAS"] as String?
                    keyPassword = keystoreProperties["KEYSTORE_ENTRY_PASSWORD"] as String?
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

// Load keystore properties
val keystorePropertiesFile = rootProject.file("keystore.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(keystorePropertiesFile.inputStream())
}

flutter {
    source = "../.."
}