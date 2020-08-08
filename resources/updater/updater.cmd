@echo off

set  CURL_COMMAND=curl.exe --ipv4 --anyauth --insecure --location-trusted --verbose --resolve "youtube-dl.org:443:95.143.172.170" --resolve "youtube-dl.org:80:95.143.172.170"

call %CURL_COMMAND% --url "http://youtube-dl.org/downloads/latest/youtube-dl.exe" --output "youtube-dl.exe"
if ["%ErrorLevel%"] NEQ ["0"] ( goto ERROR_DOWNLOAD_EXE )

call %CURL_COMMAND% --url "http://youtube-dl.org/downloads/latest/youtube-dl"     --output "youtube-dl.rar"
if ["%ErrorLevel%"] NEQ ["0"] ( goto ERROR_DOWNLOAD_RAR )


move /y  "youtube-dl.exe"  "..\youtube-dl\."
if ["%ErrorLevel%"] NEQ ["0"] ( goto ERROR_MOVE )

move /y  "youtube-dl.rar"  "..\youtube-dl\."
if ["%ErrorLevel%"] NEQ ["0"] ( goto ERROR_MOVE )


::---------------------------------------------------------------------------------------
::---------------------------------------------------------------------------------------


::remove old-version
del /f /q     "..\youtube-dl\__main__.py"   2>nul >nul
del /f /q /s  "..\youtube-dl\youtube_dl\"   2>nul >nul
rmdir  /q /s  "..\youtube-dl\youtube_dl\"   2>nul >nul
del /f /q /s  "..\youtube-dl\youtube_dl\"   2>nul >nul


7z x "..\youtube-dl\youtube-dl.rar" -y -o"..\youtube-dl\."


del /f /q "..\youtube-dl\youtube-dl.rar"


::updating "help"-information.
echo version:                            >"..\..\readme_youtube-dl.nfo"
call "..\..\youtube-dl.cmd" "--version"  >>"..\..\readme_youtube-dl.nfo"
echo --------------------------------    >>"..\..\readme_youtube-dl.nfo"
echo.                                    >>"..\..\readme_youtube-dl.nfo"
call "..\..\youtube-dl.cmd" "--help"     >>"..\..\readme_youtube-dl.nfo"


goto END


:ERROR_DOWNLOAD_EXE
  echo [ERROR] can not download:                                1>&2
  echo http://youtube-dl.org/downloads/latest/youtube-dl.exe    1>&2
  goto END

:ERROR_DOWNLOAD_RAR
  echo [ERROR] can not download:                                1>&2
  echo http://youtube-dl.org/downloads/latest/youtube-dl        1>&2
  goto END

:ERROR_MOVE
  echo [ERROR] can not move file      1>&2
  goto END
  
:END
  pause
