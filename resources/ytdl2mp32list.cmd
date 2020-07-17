@echo off
call "%~sdp0ytdl2download.cmd" --format "bestaudio[ext=mp3]/bestaudio[ext=m4a]/bestaudio" --audio-format "mp3" --extract-audio --audio-quality "192k" "--batch-file" %*

exit /b %ErrorLevel%
