@echo off

set "_DATE="
set "_TIME="

For /f "tokens=2-4 delims=/ " %%a in ("%DATE%") do ( set "_DATE=%%c/%%a/%%b" ) 
For /f "tokens=1-2 delims=/:" %%a in ("%TIME%") do ( set "_TIME=%%a:%%b"     )

echo %_DATE% %_TIME%   %* >>"%~sdp0_history.txt"

exit /b %ErrorLevel%