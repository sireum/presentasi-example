# Sireum Presentasi Generator Example

This repository holds an example Proyek for Sireum Presentasi Generator
(Presentasi for short).

Presentasi takes a presentation specification (e.g., 
[bin/presentasi.cmd](bin/presentasi.cmd)) 
and generates a JavaFX application that "presents" it by first automatically 
synthesizing text to speech and computing slide, audio, or video timeline
based on the specified relative timing information.

The specification language is in the form of a Slash (Slang universal shell)
script to build objects defined by the 
[Presentation](https://github.com/sireum/runtime/blob/master/library/shared/src/main/scala/org/sireum/presentasi/Presentation.scala)
Slang types.

The automatic presentation can be recorded for distribution.
Moreover, the presentation can also be 
distributed in a self-contained jar by using Proyek assemble task.

Pre-built jars for the Presentasi example in this repo are available:

* https://github.com/sireum/presentasi-example/releases/download/demo/presentasi-example-azure-ryan.jar
* https://github.com/sireum/presentasi-example/releases/download/demo/presentasi-example-mary-tts.jar

## Generating Presentation

```
sireum presentasi gen <path>
```

where `<path>` is the local path of this repo.

## Running Presentation

```
sireum proyek run <path> Presentasi [ #<slide-num> | <time-millis> ]
```

where `<slide-num>` and `<time-millis>` are optional non-negative integers to skip to.

## Assembling Presentation .jar

```
sireum proyek assemble --main Presentasi <path> 
```

## Running Presentation .jar

To run the jar file (use Java shipped with Sireum or Java runtime with JavaFX):

* macOS/Linux:

  ```
  java -jar <path>/out/presentasi-example/assemble/presentasi-example.jar [ #<slide-num> | <time-millis> ]
  ```

* Windows:

  ```
  java -jar <path>\out\presentasi-example\assemble\presentasi-example.jar [ #<slide-num> | <time-millis> ]
  ```
  
If the application is somehow stuck when loading resources in your machine, e.g.,:

```
Loading jar:file:/.../presentasi-example-azure-ryan.jar!/image/Slang.001.png ... done
Loading jar:file:/.../presentasi-example-azure-ryan.jar!/audio/B55EB8-Hello__Today_I_.mp3 ... done
Loading jar:file:/.../presentasi-example-azure-ryan.jar!/audio/F81371-Let_me_first_gi.mp3 ... done
Loading jar:file:/.../presentasi-example-azure-ryan.jar!/image/Slang.002.png ... done
Loading jar:file:/.../presentasi-example-azure-ryan.jar!/audio/5F75B1-Recent_years_ha.mp3 ... done
Loading jar:file:/.../presentasi-example-azure-ryan.jar!/video/demo-1.mp4 ...
```

You can first uncompress the jar file and then run it, e.g.:

```
unzip -d presentasi-example presentasi-example-azure-ryan.jar
java -cp presentasi-example Presentasi
```



