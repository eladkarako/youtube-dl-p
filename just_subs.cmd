@echo off
set "EXIT_CODE=0"
chcp 65001  1>nul 1>nul

call "%~dp0ytdl.cmd" --skip-download --sub-lang "en,he,iw" --write-auto-sub --write-sub --convert-subs "srt" %*
set "EXIT_CODE=%ErrorLevel%"

if ["%EXIT_CODE%"] NEQ ["0"] ( goto ERROR_DOWNLOAD )

for %%e in (*.vtt) do (
  call "%~dp0ffmpeg.exe" -hide_banner -strict experimental -threads 16 -stats -err_detect ignore_err -i "%%e" "%%e.srt" 
) 

goto END

::-----------------------------------------------------

:ERROR_DOWNLOAD
  echo [ERROR] download failed. 1>&2
  goto END

:END
  echo [INFO] Done [EXIT_CODE:%EXIT_CODE%] 1>&2
  pause
  exit /b %ErrorLevel%
  