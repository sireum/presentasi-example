::/*#! 2> /dev/null                                   #
@ 2>/dev/null # 2>nul & echo off & goto BOF           #
if [ -z "${SIREUM_HOME}" ]; then                      #
  echo "Please set SIREUM_HOME env var"               #
  exit -1                                             #
fi                                                    #
exec "${SIREUM_HOME}/bin/sireum" slang run "$0" "$@"  #
:BOF
setlocal
if not defined SIREUM_HOME (
  echo Please set SIREUM_HOME env var
  exit /B -1
)
"%SIREUM_HOME%\bin\sireum.bat" slang run %0 %*
exit /B %errorlevel%
::!#*/
// #Sireum
import org.sireum._

if (Os.cliArgs.size != 1) {
  println("Usage: <dir>")
  Os.exit(0)
}

def ffmpegSilentCommand(output: Os.Path, durationInMs: Z): Unit = {
  Os.proc(ISZ("ffmpeg", "-f", "lavfi", "-fflags", "+genpts", "-i", "anullsrc=channel_layout=mono:sample_rate=8000", "-t", s"${durationInMs}ms", "-c:a", "pcm_s16le", "-ar", "44100", "-ac", "2", "-y", output.string)).runCheck()
}

def ffmpegConvertAudio(input: Os.Path, output: Os.Path): Unit = {
  Os.proc(ISZ[String]("ffmpeg", "-i", input.string, "-c:a", "pcm_s16le", "-ar", "44100", "-ac", "2", output.string)).runCheck()
}

def ffmpegExtractVideoAudio(input: Os.Path, output: Os.Path, start: F64, end: F64): Unit = {
  val t: ISZ[String] = if (end > 0d) ISZ[String]("-t", s"${end - start}ms") else ISZ[String]()
  Os.proc(ISZ[String]("ffmpeg", "-ss", s"${start}ms") ++ t ++ ISZ[String]("-i", input.string, "-c:a", "pcm_s16le", "-ar", "44100", "-ac", "2", output.string)).runCheck()
}

def ffmpegConcat(filelist: Os.Path, output: Os.Path): Unit = {
  Os.proc(ISZ("ffmpeg", "-y", "-f", "concat", "-safe", "0", "-i", filelist.string,
    "-c:a", "copy", output.string)).runCheck()
}

def generateMp4Subtitle(d: Os.Path): Unit = {
  for (presentasiDir <- (d / "out" / "presentasi").list if presentasiDir.isDir) {
    var avi = Option.none[Os.Path]()
    var csv = Option.none[Os.Path]()
    for (p <- presentasiDir.list) {
      p.ext match {
        case string"avi" if ops.StringOps(p.name).startsWith("ScreenRecording") => avi = Some(p)
        case string"csv" => csv = Some(p)
        case _ =>
      }
    }
    if (avi.isEmpty || csv.isEmpty) {
      println(s"Could not find .mov and .csv files in $presentasiDir")
      return
    }
    var name = csv.get.name
    name = ops.StringOps(name).substring(0, name.size - 4)
    val wav = csv.get.up / s"$name.wav"
    println(s"Using ${avi.get}")
    println()
    println(s"Using ${csv.get}")
    println()

    println(s"Generating $wav ...")
    var prevSoundEnd: Z = 0
    val tempDir = presentasiDir / "temp"
    tempDir.removeAll()
    tempDir.mkdirAll()
    var sounds = ISZ[Os.Path]()
    var numOfSilence = 0
    for (line <- csv.get.readLines) {
      val ISZ(soundBeginS, soundEndS, uri, videoStartS, videoEndS) = ops.StringOps(line).split((c: C) => c == ',')
      if (!ops.StringOps(uri).startsWith("file:/")) {
        println(s"Cannot currently process $uri")
        println("Please record using sireum presentasi run instead of from an assembled jar")
        return
      }
      val media = Os.Path.fromUri(uri)
      val soundBegin = Z(soundBeginS).get
      val soundEnd = Z(soundEndS).get
      if (prevSoundEnd < soundBegin) {
        val silence = tempDir / s"silence-$numOfSilence.wav"
        numOfSilence = numOfSilence + 1
        sounds = sounds :+ silence
        ffmpegSilentCommand(silence, soundBegin - prevSoundEnd)
      }
      if (media.ext == "mp4") {
        val videoStart = F64(videoStartS).get
        val videoEnd = F64(videoEndS).get
        val sound = tempDir / s"video-${sounds.size}.wav"
        sounds = sounds :+ sound
        ffmpegExtractVideoAudio(media, sound, videoStart, videoEnd)
      } else {
        val sound = tempDir / s"sound-${sounds.size}.wav"
        sounds = sounds :+ sound
        ffmpegConvertAudio(media, sound)
      }
      prevSoundEnd = soundEnd
    }
    val filelist = tempDir / "filelist.txt"
    filelist.writeOver(st"${(for (sound <- sounds) yield st"file '$sound'", "\n")}".render)
    ffmpegConcat(filelist, wav)
    println()

    val vtt = presentasiDir / s"$name.vtt"
    val srt = presentasiDir / s"$name.srt"
    if (!vtt.exists && !srt.exists) {
      println(s"Could not find a .vtt or .srt file in ${vtt.up.canon}")
      return
    }
    val output = presentasiDir / s"$name.mp4"
    val outputSubtitled = presentasiDir / s"$name-srt.mp4"

    println(s"Generating $output ...")
    Os.proc(ISZ("ffmpeg", "-y", "-i", avi.get.string, "-i", wav.string, "-pix_fmt", "yuv420p10le", "-c:v", if (Os.isMac) "hevc_videotoolbox" else "libx265", "-c:a", "aac", "-q:a", "2", "-b:a", "192k", "-preset", "slow", "-crf", "28", "-g", "60", "-x265-params", "profile=main10", "-movflags", "+faststart", output.string)).console.runCheck()
    println()

    if (vtt.exists && vtt.lastModified > srt.lastModified) {
      println(s"Generating $srt ...")
      Os.proc(ISZ("ffmpeg", "-y", "-i", vtt.string, srt.string)).runCheck()
      println()
    }

    println(s"Generating $outputSubtitled ...")
    Os.proc(ISZ("ffmpeg", "-y", "-i", output.string, "-i", srt.string, "-c", "copy", "-c:a", "copy", "-c:s", "mov_text", "-metadata:s:s:0", "language=eng", outputSubtitled.string)).runCheck()
    println()
  }
}

def rec(d: Os.Path): Unit = {
  if ((d / "bin" / "project.cmd").exists) {
    generateMp4Subtitle(d)
  }
  for (p <- d.list if p.isDir) {
    rec(p)
  }
}

rec(Os.path(Os.cliArgs(0)).canon)
