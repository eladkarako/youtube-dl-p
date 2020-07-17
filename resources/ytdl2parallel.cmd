@echo off


::                               input is a list of URLs.
set LIST="%~1"
if [%LIST% == ""]         ( goto NOLIST       )
for /f %%a in (%LIST%) do ( set "LIST=%%~fsa" )
if not exist %LIST%       ( goto NOLIST       )


::                               working environment.
set FOLDER_BATCH=%~dp0
set YTDL2DOWNLOAD=%FOLDER_BATCH%ytdl2download.cmd


::                               normalise path.
for /f %%a in ("%FOLDER_BATCH%")do (   set "FOLDER_BATCH=%%~fsa"    )
for /f %%a in ("%YTDL2DOWNLOAD%")do (  set "YTDL2DOWNLOAD=%%~fsa"   )


::                               processing a new-line separated file.
for /f %%e in (%LIST%) do (
  echo %%e
  start /low "cmd /c "call %YTDL2DOWNLOAD% "%%e"
) 


goto EXIT


:NOLIST
  echo.
  echo ERROR: argument missing (textual-based file, filled with URLs, one per line).
  goto EXIT
  
:EXIT
  echo.
  pause
