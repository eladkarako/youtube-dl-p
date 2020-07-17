@echo off
chcp 65001 2>nul >nul
call "%~sdp0youtube-dl.cmd" --help >readme_youtube-dl.nfo

::updating "help"-information.
echo version:                             >"%~sdp0readme_youtube-dl.nfo"
call "%~sdp0youtube-dl.cmd" "--version"  >>"%~sdp0readme_youtube-dl.nfo"
echo --------------------------------    >>"%~sdp0readme_youtube-dl.nfo"
echo.                                    >>"%~sdp0readme_youtube-dl.nfo"
call "%~sdp0youtube-dl.cmd" "--help"     >>"%~sdp0readme_youtube-dl.nfo"
