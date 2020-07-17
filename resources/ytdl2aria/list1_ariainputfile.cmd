@echo off
chcp 65001 2>nul >nul
@echo on
call aria2c --dir="." --file-allocation="falloc" --human-readable="true" --enable-color="true" --split="3" --min-split-size="1M" --user-agent="Mozilla/5.0 Chrome" --continue="true" --allow-overwrite="false" --auto-file-renaming="false" --check-certificate="false" --check-integrity="false" --enable-http-keep-alive="true" --enable-http-pipelining="true" --disable-ipv6="true" --max-concurrent-downloads="4" --max-connection-per-server="16" --input-file="D:/DOS/youtube-dl-p/ytdl2aria/list1_ariainputfile.txt"
@echo off
pause