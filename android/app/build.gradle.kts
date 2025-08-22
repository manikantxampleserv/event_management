import java.util.Properties

// Load keystore properties
def keystoreProperties = new Properties()
def keystorePropertiesFile = rootProject.file('key.properties')
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(new FileInputStream(keystorePropertiesFile))
}

plugins {
    id 'com.android.application'
    id 'kotlin-android'
    id 'dev.flutter.flutter-gradle'
}

android {
    namespace = "com.mkx.event_management"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.120"

    defaultConfig {
        applicationId "com.mkx.event_management"
        minSdk 23
        targetSdk flutter.targetSdkVersion
        versionCode flutter.versionCode
        versionName flutter.versionName
    }

    compileOptions {
        sourceCompatibility JavaVersion.VERSION_11
        targetCompatibility JavaVersion.VERSION_11
    }
    kotlinOptions {
        jvmTarget = "11"
    }

    signingConfigs {
        release {
            keyAlias keystoreProperties['keyAlias']
            keyPassword keystoreProperties['keyPassword']
            storeFile file(keystoreProperties['storeFile'])
            storePassword keystoreProperties['storePassword']
        }
    }

    buildTypes {
        release {
            // Use the signing config defined above
            signingConfig signingConfigs.release
            
            // Optional: Enable ProGuard or R8 if you want to shrink/obfuscate code
            minifyEnabled false
            shrinkResources false
            
            // Optional: Remove debug symbols to reduce APK size
            // ndk {
            //    debugSymbolLevel 'NONE'
            // }
            
            // Recommended: Enable these for production
            // proguardFiles getDefaultProguardFile('proguard-android.txt'), 'proguard-rules.pro'
        }
        debug {
            signingConfig signingConfigs.debug
        }
    }
}

flutter {
    source '../..'
}
