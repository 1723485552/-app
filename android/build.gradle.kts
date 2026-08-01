allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

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

// Workaround for file_picker 11.0.2 + AGP 9 (Flutter 3.44):
// Under AGP 9 the plugin intentionally skips applying the Kotlin Gradle plugin,
// relying on Flutter's built-in Kotlin which currently fails to compile its
// Kotlin sources (FilePickerPlugin.kt) -> "cannot find symbol FilePickerPlugin".
// Force-apply the Kotlin plugin to :file_picker during its configuration so it
// builds. This lives in the repo (not the pub cache) and survives moving to a
// new machine. The kotlin-android plugin defers its Android integration via
// withId, so applying it before/after com.android.library is order-safe.
subprojects {
    if (name == "file_picker" && !plugins.hasPlugin("org.jetbrains.kotlin.android")) {
        apply(plugin = "org.jetbrains.kotlin.android")
        // file_picker's own build.gradle skips its kotlinOptions{jvmTarget=17}
        // block under AGP 9, so Kotlin defaults to JVM 21 while Java compiles to
        // 17. Pin the Kotlin JVM target to 17 (lazily, once the Java plugin is
        // present) to avoid the "Inconsistent JVM Target Compatibility" error.
        tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile>().configureEach {
            compilerOptions {
                jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_17)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
