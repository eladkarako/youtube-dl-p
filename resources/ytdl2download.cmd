@echo off
chcp 65001          2>nul >nul
::-----------------------------------------------------------------------------
::  you can download a whole channel using:  ytdl2download
::  "https://www.youtube.com/user/henders007/videos?disable_polymer=1"
::-----------------------------------------------------------------------------

::                               working environment state.
  set "EXIT_CODE=0"
  set "FOLDER_BATCH=%~sdp0"
  set "YTDL=%FOLDER_BATCH%youtube-dl.cmd"


::                               normalise to short-path.
  for /f %%a in ("%FOLDER_BATCH%") do (   set "FOLDER_BATCH=%%~fsa"    )
  for /f %%a in ("%YTDL%")         do (   set "YTDL=%%~fsa"            )


::                               replace \ to / for youtube-dl (its internal script).
  set FOLDER_BATCH=%FOLDER_BATCH:\=/%


  set "ARGS="

::===================================================================================
::------use native
::set ARGS=%ARGS% --hls-prefer-native

::------use aria2c
  set ARGS=%ARGS% --external-downloader aria2c
  set ARGS=%ARGS% --external-downloader-args "--min-split-size=\"1M\" --check-certificate=\"false\" --enable-http-pipelining=\"true\" --file-allocation=\"prealloc\" --human-readable=\"true\" --enable-color=\"true\" --split=\"3\" --save-session-interval=\"10\" --auto-save-interval=\"10\" --retry-wait=\"3\" --max-tries=\"10\" --timeout=\"120\" --connect-timeout=\"300\" --max-file-not-found=\"3\" --continue=\"true\" --allow-overwrite=\"false\" --auto-file-renaming=\"false\" --enable-http-keep-alive=\"true\" --enable-http-pipelining=\"true\" --disable-ipv6=\"true\" --connect-timeout=\"120\" --max-concurrent-downloads=\"5\"  --max-connection-per-server=\"16\" "

::------use ffmpeg
::set ARGS=%ARGS% --hls-prefer-ffmpeg
::set ARGS=%ARGS% --external-downloader      "ffmpeg"
::::set ARGS=%ARGS% --external-downloader-args "-hide_banner -strict experimental -threads 16 -loglevel info"
::set ARGS=%ARGS% --external-downloader-args "-hide_banner -strict experimental -threads \"16\" -loglevel \"notice\" -flags \"+low_delay+global_header-unaligned-ilme-cgop-loop-output_corrupt\"  -flags2 \"+fast+ignorecrop+showall+export_mvs\" -fflags \"+autobsf+genpts+discardcorrupt-fastseek-nofillin-ignidx-igndts\" -thread_queue_size 500 -start_at_zero -avoid_negative_ts \"make_zero\" "
::===================================================================================


::------arguments- encoder
::set ARGS=%ARGS% --postprocessor-args       "-hide_banner -strict experimental -threads \"16\" -loglevel \"notice\" -flags \"+low_delay+global_header-unaligned-ilme-cgop-loop-output_corrupt\"  -flags2 \"+fast+ignorecrop+showall+export_mvs\" -fflags \"+autobsf+genpts+discardcorrupt-fastseek-nofillin-ignidx-igndts\" -thread_queue_size 500 -mpv_flags \"+strict_gop+naq\" -movflags \"+faststart+disable_chpl\" -start_at_zero -avoid_negative_ts \"make_zero\" -segment_time_metadata \"1\" -force_duplicated_matrix \"1\" -tune \"zerolatency\" -map_chapters \"-1\" -map_metadata \"-1\""
::set ARGS=%ARGS% --ffmpeg-location          "%FOLDER_BATCH%"

::------arguments- subtitles
  set ARGS=%ARGS% --sub-lang "en,he"
  set ARGS=%ARGS% --write-sub --write-auto-sub

::------arguments- program
  set ARGS=%ARGS% --restrict-filenames
  set ARGS=%ARGS% --verbose
  set ARGS=%ARGS% --print-traffic
  set ARGS=%ARGS% --abort-on-error

::------arguments- network
  set ARGS=%ARGS% --http-chunk-size "10M"
  set ARGS=%ARGS% --force-ipv4
::set ARGS=%ARGS% --geo-bypass --geo-bypass-country "US"
  set ARGS=%ARGS% --no-check-certificate
  set ARGS=%ARGS% --prefer-insecure
  set ARGS=%ARGS% --no-call-home




::------arguments already have '--format' (don't use default format)
  echo.%* | findstr /C:"--format" 2>nul 1>nul
  IF ["%ErrorLevel%"] EQU ["0"] ( goto RUN )

::------no '--format', use default '--format' (prefer single MP4 stream, or mux to MP4 container)::144,240,360,480,720,1080
  set ARGS=%ARGS% --format "best"
::set ARGS=%ARGS% --format "best[ext=mp4][height <=? 720]/bestvideo[ext=mp4][height <=? 720]+bestaudio[ext=mp3]/bestvideo[ext=mp4][height <=? 720]+bestaudio[ext=m4a]"
::set ARGS=%ARGS% --format "bestaudio[ext=mp3]/bestaudio[ext=m4a]/bestaudio"

::set ARGS=%ARGS% --recode-video           "mp4"
::set ARGS=%ARGS% --merge-output-format    "mp4"




:RUN
  ::---------------------------------------keeping history.
  call "d:\dos\parallel_aria2\history.cmd" %*
  ::-------------------------------------------------------

  
  set ARGS=%YTDL% %ARGS% %*

  echo.                                           1>&2
  echo.                                           1>&2
  echo  %ARGS%
  call  %ARGS%

  set "EXIT_CODE=%ErrorLevel%"
  IF ["%EXIT_CODE%"] NEQ ["0"] ( goto ERR )

  echo.
  echo.
  echo Completed Successfully!
  goto END


:ERR
  echo.                                           1>&2
  echo.                                           1>&2
  echo [ERROR] YouTube-DL Exit-Code: %EXIT_CODE%  1>&2
  echo Command:                                   1>&2
  echo %ARGS%                                     1>&2
  goto END


:END
  echo.                                           1>&2
  ::color
  pause                                           1>&2
  exit /b %EXIT_CODE%


::---------------------------------------------
:: exit-codes are managed by 'YouTube-DL.cmd'
::---------------------------------------------

