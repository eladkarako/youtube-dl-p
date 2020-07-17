@echo off
chcp 65001 2>nul >nul

set COMMAND="%~dp0resources\youtube-dl\youtube-dl.exe"

for /f "tokens=*" %%a in ('where python.exe 2^>nul') do ( set "PYTHON=%%a" )
if ["%ErrorLevel%"] NEQ ["0"] ( goto CONTINUE )
if not exist "%PYTHON%" ( goto CONTINUE )
set COMMAND="%PYTHON%" "%~dp0resources\youtube-dl\__main__.py"
:CONTINUE

set COMMAND=%COMMAND:\=/%

call %COMMAND% %*
exit /b %ErrorLevel%
