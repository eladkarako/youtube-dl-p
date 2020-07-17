@echo off
chcp 65001          2>nul >nul

set "YTDL=%~sdp0ytdl.cmd"
set "ARGS="

::---------------------------------------prefer "audio only" streams (overrides the '--format' used in ytdl2download).
set  ARGS=%ARGS% --format "bestaudio[ext=mp3]/bestaudio[ext=m4a]/bestaudio"

::---------------------------------------when required: extract audio + re-encode.
set  ARGS=%ARGS% --audio-format "mp3"
set  ARGS=%ARGS% --extract-audio
set  ARGS=%ARGS% --audio-quality "192k"

::---------------------------------------for YTDL: first argument is the URL (%1 is tested to have '//' in it to be a valid URL)
set  ARGS="%YTDL%" %ARGS% %*

echo  %ARGS%
call  %ARGS%

exit /b %ErrorLevel%
