allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
    
    // Configure JVM target for all subprojects to ensure consistency
    // afterEvaluate {
    //     if (project.hasProperty("android")) {
    //         extensions.configure<com.android.build.gradle.BaseExtension> {
    //             compileOptions {
    //                 sourceCompatibility = JavaVersion.VERSION_21
    //                 targetCompatibility = JavaVersion.VERSION_21
    //             }
    //         }
    //     }
        
    //     tasks.withType<org.jetbrains.kotlin.gradle.tasks.KotlinCompile> {
    //         compilerOptions {
    //             jvmTarget.set(org.jetbrains.kotlin.gradle.dsl.JvmTarget.JVM_21)
    //         }
    //     }
    // }
}
subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}