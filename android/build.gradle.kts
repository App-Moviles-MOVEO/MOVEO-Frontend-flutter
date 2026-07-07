// Configura los repositorios de dependencias para TODOS los módulos del proyecto (raíz y submódulos)
allprojects {
    repositories {
        google()
        mavenCentral()
    }
}
// Cambia la ruta del directorio de compilación ("build") del proyecto raíz.
// Por defecto se crea dentro de /android/build, pero aquí se mueve dos niveles arriba (../../build),
// quedando en la raíz general del proyecto Flutter. Esto previene errores de rutas demasiado largas en Windows.
val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}
// Registra la tarea "clean" (limpieza) usando el tipo estándar 'Delete' de Gradle
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
