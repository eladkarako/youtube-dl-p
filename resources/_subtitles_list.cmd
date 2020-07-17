@echo off
chcp 65001          2>nul >nul
call "youtube-dl.cmd" --skip-download --list-subs "%1"
pause