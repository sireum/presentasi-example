::#! 2> /dev/null                                   #
@ 2>/dev/null # 2>nul & echo off & goto BOF         #
if [ -z ${SIREUM_HOME} ]; then                      #
  echo "Please set SIREUM_HOME env var"             #
  exit -1                                           #
fi                                                  #
exec ${SIREUM_HOME}/bin/sireum slang run "$0" "$@"  #
:BOF
setlocal
if not defined SIREUM_HOME (
  echo Please set SIREUM_HOME env var
  exit /B -1
)
%SIREUM_HOME%\bin\sireum.bat slang run "%0" %*
exit /B %errorlevel%
::!#
// #Sireum

import org.sireum._
import org.sireum.presentasi._
import org.sireum.presentasi.Presentation._

val home = Os.slashDir.up.canon
val resources = home / "jvm" / "src" / "main" / "resources"
val image = resources / "image"
val video = resources / "video"
val claps = resources / "audio" / "Clapping-sound-effect.mp3"

val slide1 = Slide(
  path = (image / "Slang.001.png").string,
  delay = 0,
  text =
    s"""
     [2000]
     Hello! Today I am going to present Slang, the Seereeum Programming Language.

     Let me first give the motivation for our work.
     """
)

val slide2 = Slide(
  path = (image / "Slang.002.png").string,
  delay = -2000,
  text =
    s"""
     Recent years have seen significant advancements on formal methods.
     """
)

val video3 = Video(
  path = (video / "demo-1.mp4").string,
  delay = 0,
  volume = 1.0,
  rate = 1.0,
  start = 0.0,
  end = 0.0,
  textOpt = None()
)

val video4 = Video(
  path = (video / "demo-2.mp4").string,
  delay = 0,
  volume = 1.0,
  rate = 1.0,
  start = 0.0,
  end = 1000.0,
  textOpt = Some(
    s"""
     For this demonstration, I will use a sha three crypto algorithm implementation in Slang.
     """
  )
)

val video5 = Video(
  path = (video / "demo-2.mp4").string,
  delay = 0,
  volume = 1.0,
  rate = 1.0,
  start = 4000.0,
  end = 10000.0,
  textOpt = Some(
    s"""
     The implementation was hand-translated from a C code that is available online.
     """
  )
)

val slide6 = Slide(
  path = (image / "Slang.036.png").string,
  delay = 0,
  text =
    s"""
     Thank you all for attending! We now can take any questions that you might have.

     [-1000]
     [1.0; $claps]
     """
)

val presentation = Presentation.empty + slide1 + slide2 + video3 + video4 + video5 + slide6

presentation.cli(Os.cliArgs)