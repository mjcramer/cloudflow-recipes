import sbt._
import sbt.Keys._

lazy val root =  (project in file("."))
  .enablePlugins(CloudflowAkkaStreamsApplicationPlugin)
  .settings(
    libraryDependencies ++= Seq(
      "com.lightbend.akka"     %% "akka-stream-alpakka-file"  % "1.1.2",
      "com.typesafe.akka"      %% "akka-http-spray-json"      % "10.1.11",
      "ch.qos.logback"         %  "logback-classic"           % "1.2.3",
      "com.typesafe.akka"      %% "akka-http-testkit"         % "10.1.11" % "test"
    ),
    name := "my-sensor-project",
    organization := "com.example",
    scalaVersion := "2.12.10",
    crossScalaVersions := Vector(scalaVersion.value),
    scalacOptions ++= Seq(
      "-encoding", "UTF-8",
      "-target:jvm-1.8",
      "-Xlog-reflective-calls",
      "-Xlint",
      "-Ywarn-unused",
      "-Ywarn-unused-import",
      "-deprecation",
      "-feature",
      "-language:_",
      "-unchecked"
    ),
    runLocalConfigFile := Some("src/main/resources/local.conf"),

    scalacOptions in (Compile, console) --= Seq("-Ywarn-unused", "-Ywarn-unused-import"),
    scalacOptions in (Test, console) := (scalacOptions in (Compile, console)).value
  )

ThisBuild / cloudflowDockerRegistry := Some("us.gcr.io")
ThisBuild / cloudflowDockerRepository := Some("cloudflow-1023b")


lazy val cloudflowDockerImagePath = taskKey[Unit]("Output path of docker image")
cloudflowDockerImagePath := {
   IO.write(new File("./cloudflow-docker-image-path"),
     cloudflowDockerRegistry.value.getOrElse("") +
     "/" +
     cloudflowDockerRepository.value.getOrElse("") +
     "/" +
     cloudflowDockerImageName.value.map(_.asTaggedName).getOrElse("")
    )
}