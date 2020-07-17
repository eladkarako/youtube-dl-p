@echo off
set "EXIT_CODE=0"
chcp 65001  1>nul 1>nul

::---------------------------------------------------------------------
echo."%CD%" | findstr /I /C:"Windows\Sys" 2>nul 1>nul
IF ["%ErrorLevel%"] EQU ["0"] ( pushd "%~dp0" ) else ( pushd "%CD%" ) 
::---------------------------------------------------------------------

::---------------------------------------------------------------------
set ARGS=--config-location "%~dp0ytdl.conf" --external-downloader aria2c --external-downloader-args "--conf-path=%~dp0aria2c.conf" --ffmpeg-location "%~dp0ffmpeg.exe" %*
set ARGS=%ARGS:\=/%
::---------------------------------------------------------------------


::---------------------------------------------------------------------
call "%~dp0youtube-dl.cmd" %ARGS%
set "EXIT_CODE=%ErrorLevel%"
goto END
::---------------------------------------------------------------------



::---------------------------------------------------------------------
::---------------------------------------------------------------------
::---------------------------------------------------------------------
:ERROR_EMPTY
  set "EXIT_CODE=111"
  echo [ERROR] empty. 1>&2
  goto END

:END
  echo [INFO] Done. [EXIT_CODE:%EXIT_CODE%] 1>&2
  pause
  popd
  exit /b %EXIT_CODE%
