# Sireum Presentasi Generator Example

This repository holds an example Proyek for Sireum Presentasi Generator
(Presentasi for short).

Presentasi takes a presentation specification (e.g., 
[bin/presentasi.cmd](bin/presentasi.cmd)) 
and generates a JavaFX application that "presents" it by first automatically 
synthesizing text to speech and computing slide, audio, or video timeline
based on the specified relative timing information.

The specification language is in the form of either:

1. Slash (Slang universal shell) script to build objects defined by the 
[Presentation](https://github.com/sireum/runtime/blob/master/library/shared/src/main/scala/org/sireum/presentasi/Presentation.scala) Slang types (e.g., [bin/.presentasi.cmd](bin/.presentasi.cmd)).

2. Markdown with YAML frontmatter specifying the Presentasi Slang type attributes, and a sequence of heading (`#`) with an image/video, an optional inline code for specifying Presentasi entry Slang type attributes (e.g., [example.md](https://raw.githubusercontent.com/sireum/presentasi-example/refs/heads/master/example.md)).

The automatic presentation can be recorded for distribution.
Moreover, the presentation can also be distributed in a self-contained jar by using Proyek assemble task.

Pre-built `.jar`s for the Presentasi example in this repo are available:

* https://github.com/sireum/presentasi-example/releases/download/demo/presentasi-example-aws-amy.jar
* https://github.com/sireum/presentasi-example/releases/download/demo/presentasi-example-azure-ryan.jar
* https://github.com/sireum/presentasi-example/releases/download/demo/presentasi-example-mary-tts-dfki-spike-hsmm.jar

Automatically generated (subtitled) `.mp4`s for the Presentasi example are also available (use [VLC](https://www.videolan.org/vlc/)):

* https://github.com/sireum/presentasi-example/releases/download/demo/presentasi-example-aws-amy.mp4
* https://github.com/sireum/presentasi-example/releases/download/demo/presentasi-example-azure-ryan.mp4
* https://github.com/sireum/presentasi-example/releases/download/demo/presentasi-example-mary-tts-dfki-spike-hsmm.mp4

The commands used to generate the `.mp4`s inside a local copy of this repo directory in macOS were (requires [ffmpeg](https://ffmpeg.org/) with `x265` and `aac` support, and AWS and Azure setup described below):

```sh
rm -fR out/presentasi && sireum presentasi gen -s aws . && sireum proyek run . Presentasi -r && bin/post-record.cmd . && mv out/presentasi/Presentasi/Presentasi-srt.mp4 presentasi-example-aws-amy.mp4
rm -fR out/presentasi && sireum presentasi gen -s azure . && sireum proyek run . Presentasi -r && bin/post-record.cmd . && mv out/presentasi/Presentasi/Presentasi-srt.mp4 presentasi-example-azure-ryan.mp4
rm -fR out/presentasi && sireum presentasi gen . && sireum proyek run . Presentasi -r && bin/post-record.cmd . && mv out/presentasi/Presentasi/Presentasi-srt.mp4 presentasi-example-mary-tts-dfki-spike-hsmm.mp4
```

Also, a transcription of the presentations is available as `readme.md` with `.webp` and animated `.gif` images (for videos) at:

[slides/readme.md](slides/readme.md)

Slides generation optionally use [cwebp](https://developers.google.com/speed/webp/docs/cwebp), e.g.:

```sh
sireum presentasi gen --slides . && mv out/presentasi/Presentasi/Slides slides
```

## Generating Presentation

```
sireum presentasi gen <path>
```

where `<path>` is the local path of this repo.

### Using Azure

Define the `AZURE_KEY` environment variable using one of your Azure account text2speech service keys.

```
sireum presentasi gen -s azure <path>
```

### Using AWS

You need to install [AWS CLI](https://aws.amazon.com/cli) and configure it (`aws configure`).

```
sireum presentasi gen -s aws <path>
```

## Running Presentation

```
sireum proyek run <path> Presentasi ( -r | "#<slide-num>" | <time-millis> | <w>x<h> )*
```

where `<slide-num>` and `<time-millis>` are optional non-negative integers to skip to; `<w>` and `<h>` are the optional 
width and height pixel numbers to scale the presentation window to; and `-r` enables screen and audio recording (requires [sox](https://sourceforge.net/projects/sox/)).

## Assembling Presentation .jar

```
sireum proyek assemble --main Presentasi <path> 
```

## Running Presentation .jar

To run the jar file (use Java shipped with Sireum or Java runtime with JavaFX):

* **macOS:**

  ```
  $SIREUM_HOME/bin/mac/java/bin/java -jar <path>/out/presentasi-example/assemble/presentasi-example.jar ( "#<slide-num>" | <time-millis> | <w>x<h> )*
  ```

* **Linux:**

  ```
  $SIREUM_HOME/bin/linux/java/bin/java -jar <path>/out/presentasi-example/assemble/presentasi-example.jar ( "#<slide-num>" | <time-millis> | <w>x<h> )*
  ```

* **Windows:**

  ```
  %SIREUM_HOME%\bin\win\java\bin\java.exe -jar <path>\out\presentasi-example\assemble\presentasi-example.jar ( [ "#<slide-num>" | <time-millis> ] | <w>x<h> )*
  ```

### Known Issues

* If the application is somehow stuck when loading resources in your machine, e.g.,:

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
  $SIREUM_HOME/bin/linux/java/bin/java -cp presentasi-example Presentasi
  ```

* If you are using Linux, the application might throw an exception due to some ffmpeg libav shared library issues.
