@echo off
chcp 65001          2>nul >nul

set "ARG=%~1"

if ["%ARG%"] EQU [""] ( 
  for /f "tokens=*" %%a in ('%~sdp0input2stdout.exe "URL" 2^>nul') do ( set "ARG=%%a" ) 
) 

if ["%ARG%"] EQU [""] ( goto ERROR_EMPTY ) 

call "%~sdp0youtube-dl.cmd" --skip-download --sub-lang "en,he,iw" --all-subs "%ARG%"


for %%e in (*.vtt) do (
  ffmpeg -y -hide_banner -loglevel "info" -strict "experimental" -stats -i "%%e" "%%e.srt"
)


goto END


:ERROR_EMPTY
echo [ERROR] no argument.
goto END

:END
pause
exit /b 0
