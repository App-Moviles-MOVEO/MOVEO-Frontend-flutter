// El bloque pluginManagement configura cómo y de dónde Gradle descarga los plugins del proyecto
pluginManagement {
// Define una variable para almacenar la ruta absoluta del SDK de Flutter instalado en la máquina
    val flutterSdkPath =
        run {
// Instancia un lector de archivos de propiedades estándar de Java
            val properties = java.util.Properties()
// Abre el archivo 'local.properties' (autogenerado por Flutter) de forma segura.
// El '.use' asegura que el archivo se cierre correctamente en memoria tras leerlo.
            file("local.properties").inputStream().use { properties.load(it) }
            val flutterSdkPath = properties.getProperty("flutter.sdk")
            require(flutterSdkPath != null) { "flutter.sdk not set in local.properties" }
            flutterSdkPath
        }
// Incluye el script de Gradle interno de las herramientas de Flutter (flutter_tools).
// Esto permite que el proyecto entienda comandos y tareas específicas de Flutter al compilar para Android.
    includeBuild("$flutterSdkPath/packages/flutter_tools/gradle")

    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.11.1" apply false
    id("org.jetbrains.kotlin.android") version "2.2.20" apply false
}

include(":app")
