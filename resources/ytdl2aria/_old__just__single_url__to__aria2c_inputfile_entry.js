/*
this script limits the URL to a single MP4 (v+a) file, it then outputs the URL and file-name (title) in a format that is capable of adding to Aria2C '--input-file' text-file.
-------------------------------
exit-code (ErrorLevel)
YouTube-DL
  1-100 = Reserved for network errors, usage errors etc. (everything not extractor related)
  101   = Video not found
  102   = Video deleted
  103   = Country restricted
  104   = Copyright claim
  105   = Requires login (private video or requires subscription)

  123   python-catch (fallback) of exceptions during YouTube-DL execution that was ended with a `0` exit-code.
  234   some textual-content in the stderr (won't be outputed) - //since using `--abort-on-error`+`--no-warnings`+`--dump-json` (which is use 'quite mode'), any string-content is stderr means there was an error.
  345   invalid stdout-JSON, empty string/filled with just-whitespace.
  456   unparsable-invalid JSON.
  567   JSON parsed into an empty object (maybe due to an error-parsing that was gulped-up to fallback to empty string).
  678   JSON does not include '.url' and '._filename' entries ---- this may require a check to see if the JSON-format has changed.
*/

var  fs        = require("fs")
    ,path      = require("path")
    ,log       = require("console").log
    ,exec      = require("child_process").exec
    ,ARG       = process.argv.filter(function(s){return false === /node\.exe/i.test(s) && false === /index\.js/i.test(s);})[0]
    ,COMMAND   = "youtube-dl.exe --abort-on-error --no-warnings --format \"best[ext=mp4][height <=? 720]\" --force-ipv4 --no-check-certificate --no-call-home --skip-download --dump-json \"" + ARG + "\""
    ,CONF      = {timeout:     60 * 1000   //60s delay limit
                 ,encoding:    "utf8"
                 ,windowsHide: false
                 }
    ,trim      = function(s){return (s || "").replace(/(^\s+|\s+$)/gm, "");}
    ,OUT_TEMPL = "##URL##\r\n    out=\"##OUT##\" referer=\"##REFERER##\" "    //one entry of Aria2c's '--input-file'
    ;


exec(COMMAND, CONF, function(error, stdout, stderr){
  if(null !== error){
    process.exitCode = (0 !== error.status) ? error.status : 123; //try using the original error-code from YouTube-dl.
    process.exit();
  }

  stderr = trim(stderr);    //since using `--abort-on-error`+`--no-warnings`+`--dump-json` (which is use 'quite mode'), any string-content is stderr means there was an error.
  if(stderr.length > 3){
    process.exitCode = 234;
    process.exit();
  }
  
  stdout = trim(stdout);    //is valid-output? - "by length" check
  if(stdout.length < 10){
    process.exitCode = 345;
    process.exit();
  }

  try{                      //is valid-output? - "by ability to parse a JSON-text" check
    stdout = JSON.parse(stdout);
  }catch(err){
    process.exitCode = 456;
    process.exit();
  }
  if(null === stdout){      //is valid-output? - "by not-null JSON" check
    process.exitCode = 567;
    process.exit();
  }

  if("string" !== typeof stdout.url
  || "string" !== typeof stdout._filename){      //is valid-output? - "by json-contains specific-entries"
    process.exitCode = 678;
    process.exit();
  }

  //----------------------------//
  //----- should be ok now -----//
  //----------------------------//


  log(
    OUT_TEMPL.replace(/##URL##/g,     stdout.url)
             .replace(/##OUT##/g,     stdout._filename)
             .replace(/##REFERER##/g, ARG)
  );
});
