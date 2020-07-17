"use strict";

const  LIMIT             = 15               //limit for the lines in the file. number of parallel-processes to start.
      ,VALID_URL_LENGTH  = 10               //limit for the lines in the file. number of parallel-processes to start.
      ,fs                = require("fs")
      ,path              = require("path")
      ,exec              = require("child_process").exec
      ,trim              = function(s){return (s || "").replace(/(^\s+|\s+$)/gm, "");}
      ,ARGS              = process.argv.filter(function(s){return false === /node\.exe/i.test(s) && false === /index\.js/i.test(s);})
      ,MODE_VIDEO_AUDIO  = (true === /VIDEO/i.test(ARGS[1] || "VIDEO")) ? "VIDEO" : "AUDIO"
      ,file              = path.resolve(ARGS[0].replace(/\\+/g,"/")).replace(/\\+/g,"/")
      ,file_out          = (function(){
                              var parts = path.parse(file);
                              parts = parts.dir + "/" + parts.name + "_ariainputfile" + parts.ext;
                              parts = parts.replace(/\\+/g,"/");
                              parts = path.resolve(parts).replace(/\\+/g,"/");
                              return parts;
                           }())
   ,file_out_just_current_dir_for_cmd_text= (function(){  //used inline the CMD text.
                                               var parts = path.parse(file);
                                               parts = "%~sdp0" + parts.name + "_ariainputfile" + parts.ext;
                                               parts = parts.replace(/\/+/g,"\\");
                                               return parts;
                                            }())
   ,file_cmd              = (function(){
                               var parts = path.parse(file);
                               parts = parts.dir + "/" + parts.name + "_ariainputfile" + ".cmd";
                               parts = parts.replace(/\\+/g,"/");
                               parts = path.resolve(parts);
                               parts = parts.replace(/\\+/g,"/");
                               return parts;
                            }())

   ,lines                 = fs.readFileSync(file,{encoding: "utf8"})
                              .replace(/[\r\n]+/gm, "\n")
                              .split("\n")
                              .filter(function(line){return trim(line).length > 2;})    //trim whitespace
                              .filter(function(line){return line.length > 3})           //filter-out empty lines
                              .reduce(function(carry, current, index, array){           //no double lines.
                                        carry[current]="";
                                        return (index+1===array.length) ? Object.keys(carry) : carry;
                                     },{})

   ,COMMAND    =    "youtube-dl.cmd --abort-on-error --no-warnings "
                 +  " --format "
                 +  ("VIDEO" === MODE_VIDEO_AUDIO ? "\"best[ext=mp4][height <=? 720]\"" : "\"bestaudio[ext=mp3]/bestaudio[ext=m4a]/bestaudio\"" )
                 +  " --force-ipv4 --no-check-certificate --no-call-home --restrict-filenames --skip-download --dump-json \"##LINE##\" "
   ,CONF_EXEC  = {timeout:     300 * 1000   //300s delay limit
                 ,encoding:    "utf8"
                 ,windowsHide: false
                 }
   ,CONF_WRITE = {flag:"w", encoding:"utf8"}
   ,TEMPLATE_OUT  = "##URL##\r\n    out=\/##OUT##"    //one entry of Aria2c's '--input-file'. Note that for some reason you can not wrap the path with \".......\"  due to Aria2C quirk/bug.
   ,TEMPLATE_CMD  = ['@echo off'
                    ,'chcp 65001 2>nul >nul'
                    ,'@echo on'


                    ,'call aria2c.exe --split="5" --min-split-size="1M" --dir="." --file-allocation="prealloc" --save-session-interval="5" --human-readable="true" --enable-color="true" --user-agent="Mozilla/5.0 (Windows NT 6.1; Win64; x64; rv:55.0) Gecko/20100101 Firefox/55.0" --http-no-cache="true" --header="DNT: 1" --auto-save-interval="5" --content-disposition-default-utf8="true" --retry-wait="2" --max-tries="10" --timeout="120" --connect-timeout="300" --max-file-not-found="2" --continue="true" --allow-overwrite="false" --auto-file-renaming="false" --console-log-level="notice" --check-certificate="false" --check-integrity="false" --http-auth-challenge="true" --rpc-allow-origin-all="true" --rpc-secure="false" --max-concurrent-downloads="16" --max-connection-per-server="16" --enable-http-keep-alive="true" --enable-http-pipelining="true" --connect-timeout="120" --disable-ipv6="true" --async-dns="true" --async-dns-server="8.8.8.8,8.8.4.4" --input-file="##FILE_OUT##"'
                    ,'@echo off'
                    ,'pause'
                    ].join("\r\n")
   ;


var  counter    = lines.length
    ,output     = []
    ;


function normalise_filename(input){
  return  input.replace(/\&+/g, " and ")        //'&' to "and"
               .replace(/[\r\n\v\t\ ]+/g, " ")  //normalize weird-whitespace
               .replace(/[\'\"]+/gm, "")
               
               /*
               .replace(/\([^\)]+\)/g, "")  //remove () [] {} with content.
               .replace(/\[[^\]]+\]/g, "")
               .replace(/\{[^\}]+\}/g, "")
               .replace(/[\(\)\[\]\{\}]+\}/g, "")
               */

               /*
               */
               .replace(/[^a-z0-9\ \-\.א-ת]+/gi, " ")  //force to limited ASCII.
               
             //.replace(/[\u0028#\u0029#\u005B#\u005D#\u007B#\u007D#\u00AB#\u00BB#\u0F3A#\u0F3B#\u0F3C#\u0F3D#\u169B#\u169C#\u2018#\u2019#\u201A#\u201B#\u201C#\u201D#\u201E#\u201F#\u2039#\u203A#\u2045#\u2046#\u207D#\u207E#\u208D#\u208E#\u2329#\u232A#\u2768#\u2769#\u276A#\u276B#\u276C#\u276D#\u276E#\u276F#\u2770#\u2771#\u2772#\u2773#\u2774#\u2775#\u27C5#\u27C6#\u27E6#\u27E7#\u27E8#\u27E9#\u27EA#\u27EB#\u27EC#\u27ED#\u27EE#\u27EF#\u2983#\u2984#\u2985#\u2986#\u2987#\u2988#\u2989#\u298A#\u298B#\u298C#\u298D#\u298E#\u298F#\u2990#\u2991#\u2992#\u2993#\u2994#\u2995#\u2996#\u2997#\u2998#\u29D8#\u29D9#\u29DA#\u29DB#\u29FC#\u29FD#\u2E02#\u2E03#\u2E04#\u2E05#\u2E09#\u2E0A#\u2E0C#\u2E0D#\u2E1C#\u2E1D#\u2E20#\u2E21#\u2E22#\u2E23#\u2E24#\u2E25#\u2E26#\u2E27#\u2E28#\u2E29#\u3008#\u3009#\u300A#\u300B#\u300C#\u300D#\u300E#\u300F#\u3010#\u3011#\u3014#\u3015#\u3016#\u3017#\u3018#\u3019#\u301A#\u301B#\u301D#\u301E#\u301F#\uFD3E#\uFD3F#\uFE17#\uFE18#\uFE35#\uFE36#\uFE37#\uFE38#\uFE39#\uFE3A#\uFE3B#\uFE3C#\uFE3D#\uFE3E#\uFE3F#\uFE40#\uFE41#\uFE42#\uFE43#\uFE44#\uFE47#\uFE48#\uFE59#\uFE5A#\uFE5B#\uFE5C#\uFE5D#\uFE5E#\uFF08#\uFF09#\uFF3B#\uFF3D#\uFF5B#\uFF5D#\uFF5F#\uFF60#\uFF62#\uFF63]+/igu,"")  //remove brackets and the '#' sign (I've used it just for readibility), various brackets will be removed.
             //.replace(/[\u00AB#\u00BB#\u0F3A#\u0F3B#\u0F3C#\u0F3D#\u1D115#\u2E0A#\u2E0C#\u2E0D#\u2E1C#\u2E1D#\u2E02#\u2E03#\u2E04#\u2E05#\u2E09#\u2E20#\u2E21#\u2E22#\u2E23#\u2E24#\u2E25#\u2E26#\u2E27#\u2E28#\u2E29#\u005B#\u005D#\u007B#\u007D#\u23A1#\u23A2#\u23A3#\u23A4#\u23A5#\u23A6#\u23A7#\u23A8#\u23A9#\u23AA#\u23AB#\u23AC#\u23AD#\u23B0#\u23B1#\u23B4#\u23B5#\u23B6#\u23DE#\u23DF#\u23E0#\u23E1#\u27C5#\u27C6#\u27E6#\u27E7#\u27E8#\u27E9#\u27EA#\u27EB#\u27EC#\u27ED#\u27EE#\u27EF#\u0028#\u0029#\u29D8#\u29D9#\u29DA#\u29DB#\u29FC#\u29FD#\u169B#\u169C#\u201A#\u201B#\u201C#\u201D#\u201E#\u201F#\u203A#\u207D#\u207E#\u208D#\u208E#\u232A#\u276A#\u276B#\u276C#\u276D#\u276E#\u276F#\u298A#\u298B#\u298C#\u298D#\u298E#\u298F#\u300A#\u300B#\u300C#\u300D#\u300E#\u300F#\u301A#\u301B#\u301D#\u301E#\u301F#\u2018#\u2019#\u2039#\u2045#\u2046#\u2329#\u2768#\u2769#\u2770#\u2771#\u2772#\u2773#\u2774#\u2775#\u2983#\u2984#\u2985#\u2986#\u2987#\u2988#\u2989#\u2990#\u2991#\u2992#\u2993#\u2994#\u2995#\u2996#\u2997#\u2998#\u3008#\u3009#\u3010#\u3011#\u3014#\u3015#\u3016#\u3017#\u3018#\u3019#\uE005B#\uE005D#\uE007B#\uE007D#\uFD3E#\uFD3F#\uFE3A#\uFE3B#\uFE3C#\uFE3D#\uFE3E#\uFE3F#\uFE5A#\uFE5B#\uFE5C#\uFE5D#\uFE5E#\uFE17#\uFE18#\uFE35#\uFE36#\uFE37#\uFE38#\uFE39#\uFE40#\uFE41#\uFE42#\uFE43#\uFE44#\uFE47#\uFE48#\uFE59#\uFF3B#\uFF3D#\uFF5B#\uFF5D#\uFF5F#\uFF08#\uFF09#\uFF60#\uFF62#\uFF63]+/igu,"")  //remove brackets and the '#' sign (I've used it just for readibility), various brackets will be remo
               .replace(/^\s+/gi, "")             //trim right
               .replace(/\s+$/gi, "")             //trim left
               .replace(/\s+/gi,  "\ ")           //single whitespace
}


function handler(error, stdout, stderr){
  if(null !== error){console.error("youtube-dl returned with an error."); return;}

  stdout = trim(stdout);
  if(stdout.length < VALID_URL_LENGTH){console.error("youtube-dl returned with an empty STDOUT"); return;}

  try{stdout = JSON.parse(stdout);
  }catch(err){stdout = null;}
  if(null === stdout){console.error("youtube-dl returned with an invalid JSON.");return;}

  if("string" !== typeof stdout.url){       console.error("youtube-dl returned a JSON without \".url\" attribute."); return;}
  if("string" !== typeof stdout._filename){ console.error("youtube-dl returned a JSON without \"._filename\" attribute."); return;}

  console.error("-------------------------------------");
  console.error("got url: " + "\r\n" + "\"" + stdout.url + "\"");
  console.error("got _filename: " + "\r\n" + "\"" + stdout._filename + "\"");
  
  stdout._filename = normalise_filename(stdout._filename);
  console.error("got normalised _filename:" + "\r\n" + "\"" + stdout._filename + "\"");
  console.error("-------------------------------------");
  console.error("\r\n");
  
  stdout = TEMPLATE_OUT.replace(/##URL##/gm, stdout.url)
                       .replace(/##OUT##/gm, stdout._filename)
                       ;

  output.push(stdout);

  counter-=1;
  if(counter > 0){return;} //not last


  //----------------last----------------

  if(0 === output.length){  //download-list empty due to errors in every sub-process.
    console.error("error: all sub-processes of youtube-dl are done, but the result is empty..");
    process.exitCode = 999;
    process.exit();
  }

  console.error("success: all sub-processes of youtube-dl are done.");
  output = output.join("\r\n\r\n");
  console.error("writing " + "\"" + file_out + "\"");
  fs.writeFileSync(file_out, output, CONF_WRITE);                                         //download-list.
  console.error("writing " + "\"" + file_cmd + "\"");
  fs.writeFileSync(file_cmd, TEMPLATE_CMD.replace("##FILE_OUT##", file_out_just_current_dir_for_cmd_text), CONF_WRITE); //helper.
  console.log(file_out);

  console.error("\r\n");
  console.error("success. program is finished.");
  process.exitCode = 0; //at this point, even if there was an error since the files were written we can assume we have something to work with..
  process.exit();
}


/*****************
 * PROGRAM START *
 *****************/

console.error("download mode is set to [" + MODE_VIDEO_AUDIO + "]");
console.error(("VIDEO" === MODE_VIDEO_AUDIO) ? "it means an MP4 with video and audio (default mode)." : "it means an MP3 or M4A with audio-data only.");
console.error("\r\n");


fs.writeFileSync(file, lines.join("\r\n"), CONF_WRITE);  //rewrite a cleaned URL-list (no whitespace, no empty lines). Just for debug.


process.exitCode = 0;

if(lines.length > LIMIT){ //only handle lists with up-to 10 URLs.
  console.error("there are too many URLS [" + lines.length + "], the limit is [" + LIMIT + "].");
  process.exitCode = 999;
  process.exit();
}


lines.forEach(function(line, index){
  line = COMMAND.replace("##LINE##", line);
  console.error("\r\n");
  console.error("starting: #" + (index+1) + "/" + lines.length);
  console.error(line);
  exec(line, CONF_EXEC, handler);

  if(1+index === lines.length){ console.error("\r\nfinished launching all of the youtube-dl sub-processes, waiting for each-one to finish.."); }
});

