@echo off
chcp 65001 2>nul >nul

call index.cmd "list1.txt"

echo ErrorLevel === %ErrorLevel%

pause
