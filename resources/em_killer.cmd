@echo off
::                                                        external resources (path normalised)
set "FILE_TASKKILL=%windir%\System32\taskkill.exe"
if ["%PROCESSOR_ARCHITECTURE%"] == ["AMD64"] (
  set "FILE_TASKKILL=%windir%\SysWOW64\taskkill.exe"
)

call "%FILE_TASKKILL%" /T /IM "node.exe"

call "%FILE_TASKKILL%" /T /IM "youtube-dl.exe"

call "%FILE_TASKKILL%" /T /IM "python.exe"

pause