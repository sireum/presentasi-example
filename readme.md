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
[Presentation](https://github.com/sireum/runtime/blob/master/library/shared/src/main/scala/org/sireum/presentasi/Presentation.scala) Slang types (e.g., [bin/.presentasi.cmd](bin/.presentasi.cmd)); or,

2. Markdown with YAML frontmatter specifying the Presentasi Slang type attributes, and a sequence of heading (`#`) with an image/video, an optional inline code for specifying Presentasi entry Slang type attributes (e.g., [example.md](https://raw.githubusercontent.com/sireum/presentasi-example/refs/heads/master/example.md)).

The automatic presentation can be recorded for distribution.
Moreover, the presentation can also be distributed in a self-contained jar by using Proyek assemble task.

Pre-built `.jar`s for the Presentasi example in this repo are available:

* https://github.com/sireum/presentasi-example/releases/download/demo/presentasi-example-aws-amy.jar
* https://github.com/sireum/presentasi-example/releases/download/demo/presentasi-example-azure-ryan.jar
* https://github.com/sireum/presentasi-example/releases/download/demo/presentasi-example-mary-tts-dfki-spike-hsmm.jar

Automatically generated (subtitled) `.mp4`s for the Presentasi example are also available (use [VLC](https://www.videolan.org/vlc/) if your media player cannot play the `.mp4`s):

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

## Presentasi Markdown Syntax

Presentasi specifications can be written in Markdown with YAML frontmatter.
Files named `readme.md` are excluded.
See [example.md](https://raw.githubusercontent.com/sireum/presentasi-example/refs/heads/master/example.md) for a working example.

### YAML Frontmatter

```yaml
---
name: Presentasi
delay: 800
textDelay: 0
vseekDelay: 0
textVolume: 1.0
trailing: 0
granularity: 0
audio:
  - claps: jvm/src/main/resources/audio/Clapping-sound-effect.mp3
cc:
  - sireumW: Sireum
subst:
  - sireumW: Seereeum
substAzure:
  - sireumW: Seereeum
substAwsAmy:
  - sireumW: Seereum
---
```

| Key | Type | Description | Default |
|---|---|---|---|
| `name` | String | Java identifier used as the generated class name | `Presentasi` |
| `delay` | Integer | Default pause (ms) between speech segments | `0` |
| `textDelay` | Integer | Text delay (ms) | `0` |
| `vseekDelay` | Integer | Video seek delay (ms) | `0` |
| `textVolume` | Float | Volume for synthesized speech (0.0–1.0+) | `1.0` |
| `trailing` | Integer | Trailing time (ms) after the last entry | `0` |
| `granularity` | Integer | Timeline granularity (ms) | `0` |
| `audio` | List | Named audio file references (`key: path`) | |
| `cc` | List | Closed caption / subtitle display text (`key: displayText`) | |
| `subst` | List | TTS pronunciation substitutions (`key: spokenText`) | |
| `subst<Service>` | List | Service-specific TTS substitution overrides | |

#### Audio References

Audio files are declared in the `audio` section and referenced in speech text
using `$key$` syntax:

```yaml
audio:
  - claps: jvm/src/main/resources/audio/Clapping-sound-effect.mp3
```

Then in speech text: `[1.0; $claps$]` plays the audio at volume 1.0.

#### Closed Captions and TTS Substitutions

The `cc` and `subst` sections work together with `$term$` syntax in speech text.

- **`cc`**: Defines the subtitle display text for a term.
  TTS engines mispronounce code identifiers, so `cc` preserves
  the original identifier in subtitles.

- **`subst`**: Defines the speakable pronunciation sent to TTS.
  This is what the TTS engine actually reads aloud.

```yaml
cc:
  - tempSensor: TempSensor
subst:
  - tempSensor: Temp Sensor
```

When `$tempSensor$` appears in speech text, the TTS engine receives
"Temp Sensor" while the subtitle displays "TempSensor".

#### Service-Specific Substitutions

Different TTS engines may need different pronunciations.
Service-specific `subst` sections override the base `subst` when the
TTS service arguments match the section suffix.

```yaml
subst:
  - sireumW: Seereeum
substAzure:
  - sireumW: Seereeum
substAwsAmy:
  - sireumW: Seereum
```

The suffix is matched against the TTS service arguments prefix (e.g.,
`Azure` for Azure, `AwsAmy` for AWS with the Amy voice).

### Slides

Each slide is defined by a heading, an optional inline code block for
properties, an image, and bullet points for speech text:

```markdown
# Slide Title

`delay = 0`

![](jvm/src/main/resources/image/Slide.001.png)

* First speech paragraph.

* Second speech paragraph.
```

#### Slide Properties

Properties are specified in an inline code block (backtick-delimited)
as comma-separated `key = value` pairs:

| Property | Type | Description |
|---|---|---|
| `delay` | Integer | Delay (ms) before speech starts; negative values are relative to the previous slide's end |

If no inline code block is present, `delay` defaults to `0`.

### Videos

Videos are detected by the `.mp4` file extension.
They support the same structure as slides but with additional properties:

```markdown
# Demo Video

`delay = 0, volume = 1.0, rate = 1.0, start = 0.0, end = 0.0`

![Demo](jvm/src/main/resources/video/demo.mp4)

* Optional speech during the video.
```

#### Video Properties

| Property | Type | Description | Default |
|---|---|---|---|
| `delay` | Integer | Delay (ms) before the video starts | `0` |
| `volume` | Float | Video audio volume (0.0–1.0+) | `1.0` |
| `rate` | Float | Playback rate | `1.0` |
| `start` | Float | Start position (ms) within the video | `0.0` |
| `end` | Float | End position (ms); `0.0` means play to the end | `0.0` |
| `useVideoDuration` | Boolean | Use video duration for timeline (`T`/`true` or `F`/`false`) | `F` |

If speech text is provided with a video, TTS audio plays over the video.
If no speech text is provided, only the video's own audio plays.

### Speech Text Syntax

Speech text is written as bullet points (`*`) under a slide or video.
Each bullet point starts a new speech segment.

#### Delay Override

A bracket prefix overrides the default delay for a speech segment:

- **`[2000]`** — Positive value: absolute pause (ms) before this segment
- **`[-1000]`** — Negative value: relative delay (continuation from previous slide)

```markdown
* [2000]
  Hello! This starts after a 2-second pause.

* This uses the default delay.

* [-1000]
  This continues 1 second before the previous segment ends.
```

#### Term Substitution

Use `$term$` to reference `cc`/`subst` entries:

```markdown
* The $tempSensor$ component reads the current temperature.
```

The TTS engine speaks the `subst` value while subtitles show the `cc` value.

#### Audio Playback

Reference a named audio file declared in the `audio` frontmatter section:

```markdown
* [1.0; $claps$]
```

The format is `[volume; $audioKey$]` where `volume` is a float.

### HTML Comments

HTML comments (`<!-- -->`) are ignored and can be used to comment out
slides or notes:

```markdown
<!-- This slide is skipped
# Unused Slide

![](image/unused.png)

* This won't be spoken.
-->
```
