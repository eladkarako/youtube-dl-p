@echo off
chcp 65001 2>nul >nul

set "EXIT_CODE=0"

set "COMMAND="
set "NODE=%~sdp0node.exe"
set "SCRIPT=%~sdp0index.js"

for /f %%a in ("%NODE%")   do ( set "NODE=%%~fsa"   )
for /f %%a in ("%SCRIPT%") do ( set "SCRIPT=%%~fsa" )

if ["%~1"] EQU [""]    ( goto NOFILE )
if not exist %~fs1     ( goto NOFILE )
if     exist %~fs1\NUL ( goto NOFILE )

set COMMAND="%NODE%" "%SCRIPT%" "%~f1" "%~2"
::title %COMMAND%
echo  %COMMAND% 1>&2
call  %COMMAND%
set "EXIT_CODE=%ErrorLevel%"

goto END

:NOARG
  echo ERROR. Missing Argument. 1>&2
  set "EXIT_CODE=8888"
  goto END

:END
:: pass-on any existing exit-code (either 0 - success of whatever got from 'node.exe index.js' execution (which wraps youtube-dl.exe execution and JSON.parse(...) of the output).
  exit /b %EXIT_CODE%
