import java.util.Properties

plugins {
    id("com.android.application")
    id("dev.flutter.flutter-gradle-plugin")
}

abstract class CargoLockedVersion : ValueSource<String, CargoLockedVersion.Parameters> {
    interface Parameters : ValueSourceParameters {
        val lockFile: RegularFileProperty
        val crateName: Property<String>
    }

    override fun obtain(): String {
        val crateName = parameters.crateName.get()
        val lines = parameters.lockFile.get().asFile.readLines()
        val crateLine = lines.indexOfFirst { it.trim() == "name = \"$crateName\"" }
        return lines.drop(crateLine + 1)
            .firstOrNull { crateLine >= 0 && it.trimStart().startsWith("version = ") }
            ?.substringAfter('"')
            ?.substringBefore('"')
            ?: error("$crateName is not locked in ${parameters.lockFile.get().asFile}")
    }
}

val certificateVerifierComponentVersion = providers.of(CargoLockedVersion::class.java) {
    parameters.lockFile.set(layout.projectDirectory.file("../../native/Cargo.lock"))
    parameters.crateName.set("rustls-platform-verifier-android")
}

val uploadKeystorePropertiesFile = rootProject.file("key.properties")
val uploadKeystoreProperties = Properties().apply {
    if (uploadKeystorePropertiesFile.exists()) {
        uploadKeystorePropertiesFile.inputStream().use { load(it) }
    }
}
val releaseSignedWithUploadKey = uploadKeystorePropertiesFile.exists()

android {
    namespace = "com.pseudolearn.app"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    defaultConfig {
        applicationId = "com.pseudolearn.app"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("upload") {
            if (releaseSignedWithUploadKey) {
                keyAlias = uploadKeystoreProperties.getProperty("keyAlias")
                keyPassword = uploadKeystoreProperties.getProperty("keyPassword")
                storeFile = file(uploadKeystoreProperties.getProperty("storeFile"))
                storePassword = uploadKeystoreProperties.getProperty("storePassword")
            }
        }
    }

    lint {
        checkReleaseBuilds = false
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName(if (releaseSignedWithUploadKey) "upload" else "debug")
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

repositories {
    maven {
        url = uri("https://github.com/rustls/rustls-platform-verifier/raw/maven-archive/android-release-support/maven/")
        content { includeGroup("org.rustls") }
    }
}

configurations.configureEach {
    resolutionStrategy.eachDependency {
        if (requested.group == "org.rustls" && requested.name == "rustls-platform-verifier") {
            useVersion(certificateVerifierComponentVersion.get())
            because("the Kotlin component must match the rustls-platform-verifier-android crate locked by the bridge")
        }
    }
}

dependencies {
    implementation("org.rustls:rustls-platform-verifier")
}

kotlin {
    compilerOptions {
        jvmTarget = org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17
    }
}

flutter {
    source = "../.."
}
