plugins {
    id("com.android.application") version "9.4.1"
}

android {
    namespace = "com.example.filtro400"
    compileSdk = 37

    defaultConfig {
        applicationId = "com.example.filtro400"
        minSdk = 29
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"
    }

    sourceSets["main"].apply {
        manifest.srcFile("AndroidManifest.xml")
        res.srcDirs("res")
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }
}

dependencies {
    implementation("androidx.appcompat:appcompat:1.7.1")
    testImplementation("junit:junit:4.13.2")
}
