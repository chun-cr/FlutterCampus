buildscript {
    repositories {
        // 阿里云镜像（优先，解决国内访问问题）
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/gradle-plugin") } // 新增：专门的gradle插件仓库
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        // 必须保留的核心仓库（kotlin-dsl插件的默认仓库）
        gradlePluginPortal()
        google()
        mavenCentral()
    }
}
allprojects {
    repositories {
        maven { url = uri("https://maven.aliyun.com/repository/google") }
        maven { url = uri("https://maven.aliyun.com/repository/jcenter") }
        maven { url = uri("https://maven.aliyun.com/repository/public") }
        // 新增：kotlin-dsl插件需要这个仓库
        gradlePluginPortal()
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
