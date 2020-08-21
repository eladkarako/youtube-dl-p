@echo off
::cleanup
set "ARGS="
set "EXIT_CODE="

chcp 65001 2>nul >nul


set "EXIT_CODE=0"

set ARGS=%*

call "%~dp0_history.cmd" %ARGS%

echo %ARGS% | findstr /I /C:"--log=" 2>nul 1>nul
if ["%ErrorLevel%"] NEQ ["0"] ( 
  set ARGS=--log="%~sdp0last.log" %ARGS%
) 

echo %ARGS% | findstr /I /C:"--conf-path=" 2>nul 1>nul
if ["%ErrorLevel%"] NEQ ["0"] ( 
  set ARGS=--conf-path="%~sdp0aria2.conf" %ARGS%
) 

title aria2c.exe %ARGS%
echo "%~sdp0aria2c.exe" %ARGS%
call "%~sdp0aria2c.exe" %ARGS%
set "EXIT_CODE=%ErrorLevel%"

exit /b %EXIT_CODE%




::---------------------------------------------------------
:: based on Windows builds for Aria2C from 
:: https://github.com/q3aql/aria2-static-builds/releases
::---------------------------------------------------------
::                                  Elad Karako. July 2020.
::---------------------------------------------------------
