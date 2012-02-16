;; AMIP mirc script
;; v2.71-FINAL by leprechau@EFnet
;; 11.23.2003
;;
;; NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
;; this is the only official location for any of my scripts
;;

alias cfp2 { if ($1- != $null) { return $chr(2) $+ $chr(3) $+ 02 $+ ( $+ $chr(3) $+ $chr(2) $+ $1- $+ $chr(2) $+ $chr(3) $+ 02 $+ ) $+ $chr(3) $+ $chr(2) } }
alias cfb2 { if ($1- != $null) { return $chr(2) $+ $chr(3) $+ 02 $+ $chr(91) $+ $chr(3) $+ $chr(2) $+ $1- $+ $chr(2) $+ $chr(3) $+ 02 $+ $chr(93) $+ $chr(3) $+ $chr(2) } }
alias disp2 { if ($1- != $null) { echo -a $chr(42) $+ $chr(3) $+ 02 $+ $chr(42) $+ $chr(3) $+ 12 $+ $chr(42) $+ $chr(32) $+ $chr(3) $+ 02 $+ $1- } }

;on *:START:{
;  mp3-clean-table
;}

;; check if hash table exists and/or create/load table
alias amip_table_exists_check {
  if (($hget(amip-mp3s).size == 0) && (!$exists(amip-mp3s.htbl))) {
    hmake amip-mp3s 1000
  }
  elseif (($hget(amip-mp3s).size == 0) && ($exists(amip-mp3s.htbl))) {
    hmake amip-mp3s 1000
    hload amip-mp3s amip-mp3s.htbl
  }
  else { continue }
}

alias getfilesize {
  var %filebytes = $file($1-).size
  if (%filebytes < 1024) { 
    return %filebytes $+ b 
  }
  elseif ((%filebytes > 1024) && (%filebytes < 1048576)) {
    return $round($calc(%filebytes / 1024),1) $+ k
  }
  elseif ((%filebytes < 1073741824)) {
    return $round($calc(%filebytes / 1048576),2) $+ mb
  }
  else { return $round($calc(%filebytes / 1073741824),2) $+ gb }
}

;; alias to clean mp3 database of nonexistent or moved files
alias mp3-clean-table {
  amip_table_exists_check
  echo -s amip-mp3s Cleaning bad/non-existent files from hash table...
  var %i = 1
  var %removed = 0
  var %tablesize = $hget(amip-mp3s,0).item
  while (%i <= %tablesize) {
    var %filenumber = $hget(amip-mp3s,%i).item
    if (%filenumber != $null) {
      var %fullname = $gettok($hget(amip-mp3s,%i).data,2,124)
      if ((*.mp3 !iswm $nopath(%fullname)) || (!$exists(%fullname))) {
        hdel amip-mp3s %filenumber
        hsave -o amip-mp3s amip-mp3s.htbl
        echo -s amip-mp3s table updated non-existent file removed: %fullname
        inc %removed
      }
    }
    inc %i
  }
  echo -s amip-mp3s Finished cleaning database.
  if (%removed != 0) {
    if (%removed > 1) { var %fileword = files }
    else { var %fileword = file }
    echo -s amip-mp3s Removed %removed non-existent %fileword removed from hash table ( $hget(amip-mp3s,0).item total items in table)
  }
  else {
    echo -s amip-mp3s No files removed from database ( $hget(amip-mp3s,0).item total items in table)
  }
}

;; update hash tables alias/amip preset
alias table-update-preset {
  amip_table_exists_check
  var %need_update = 0
  var %fn = $dde mPlug var_fn ""
  var %nm = $dde mPlug var_nm ""
  var %ext = $dde mPlug var_ext ""
  if (%ext != mp3) { halt }
  if ($hfind(amip-mp3s,%nm $+ $chr(42),1,w).data == $null) {
    var %filenumber = $rand(100000,999999)
    if ($hget(amip-mp3s,%filenumber) == $null) {
      hadd amip-mp3s %filenumber %nm $+ $chr(124) $+ %fn
      var %need_update = 1
    }
    else {
      while ($hget(amip-mp3s,%filenumber) != $null) {
        var %filenumber = $rand(100000,999999)
      }
      hadd amip-mp3s %filenumber %nm $+ $chr(124) $+ %fn
      var %need_update = 1
    }
  }
  else {
    var %filenumber = $hfind(amip-mp3s,%nm $+ $chr(42),1,w).data
    var %filename = $gettok($hget(amip-mp3s,%filenumber),1,124)
    var %fullname = $gettok($hget(amip-mp3s,%filenumber),2,124)
    if (!$exists(%fullname)) {
      hdel amip-mp3s %filenumber
      hadd amip-mp3s %filenumber %nm $+ $chr(124) $+ %fn
      var %need_update = 1
    }
  }
  if (%need_update == 1) {
    hsave -o amip-mp3s amip-mp3s.htbl
    return amip-mp3s table updated: %filenumber - %nm ( $hget(amip-mp3s,0).item total items in table)
  }
  else { halt }
}

alias amip {
  if ($1 == $null) {
    disp2 Syntax: /amip <on|off>
  }
  elseif ($1 == on) {
    if ($dde mPlug cfg_enabled "" == 0) {
      dde mPlug control on
      disp2 AMIP Enabled!
    }
    else {
      disp2 AMIP Already Enabled.
    }
  }
  elseif ($1 == off) {
    if ($dde mPlug cfg_enabled "" == 1) {
      dde mPlug control off
      disp2 AMIP Disabled!
    }
    else {
      disp2 AMIP Already Disabled.
    }
  }
}

alias mp3 {
  ;; determine if AMIP is enabled (if not, enable it)
  if ($dde mPlug cfg_enabled "" == 0) {
    dde mPlug control on
    disp2 AMIP Enabled!
  }
  ;; determine if winamp is playing
  if (($1 != $null) && ($1 != search) && ($1 != play) && ($1 != playfile) && ($dde mPlug var_playing "" == $null)) {
    disp2 Error: Winamp is not playing, please start winamp. | halt
  }
  ;; load hash table of filenames or create if it does not exist
  amip_table_exists_check
  ;; set amip variables
  var %fn = $dde mPlug var_fn ""
  var %nm = $dde mPlug var_nm ""
  var %ext = $dde mPlug var_ext ""
  var %name = $dde mPlug var_name ""
  var %br = $dde mPlug var_br ""
  var %sr = $dde mPlug var_sr ""
  var %mode = $dde mPlug var_mode ""
  var %min = $dde mPlug var_min ""
  var %sec = $dde mPlug var_sec ""
  var %ps = $dde mPlug var_ps ""
  var %pm = $dde mPlug var_pm ""
  if (%br > 10000) { var %br = UNKNOWN }
  ;; begin mp3 if-then-else switches
  if ($1 == $null) { 
    disp2 IRC Command Syntax: /mp3 <show|showself|search|playfile>
    disp2 Winamp Control Syntax: /mp3 <play|pause|stop|ff|rew|vup|vdwn|voff|vmax|repeat|shuffle|next|prev>
    disp2 Search file path for Mp3s and add to hash table: /mp3find
    halt
  }
  elseif ($1 == show) {
    var %need_update = 0
    var %is_stream = 0
    if (http://* iswm %fn) {
     var %is_stream = 1
    }
    elseif (%ext != mp3) {
        disp2 Sorry, This command only supports Mp3 files. | halt
    }
    elseif ($hfind(amip-mp3s,%nm $+ $chr(42),1,w).data == $null) {
      var %filenumber = $rand(100000,999999)
      if ($hget(amip-mp3s,%filenumber) == $null) {
        hadd amip-mp3s %filenumber %nm $+ $chr(124) $+ %fn
        var %need_update = 1
      }
      else {
        while ($hget(amip-mp3s,%filenumber) != $null) {
          var %filenumber = $rand(100000,999999)
        }
        hadd amip-mp3s %filenumber %nm $+ $chr(124) $+ %fn
        var %need_update = 1
      }
    }
    else {
      var %filenumber = $hfind(amip-mp3s,%nm $+ $chr(42),1,w).data
      var %filename = $gettok($hget(amip-mp3s,%filenumber),1,124)
      var %fullname = $gettok($hget(amip-mp3s,%filenumber),2,124)
      if (!$exists(%fullname)) {
        hdel amip-mp3s %filenumber
        hadd amip-mp3s %filenumber %nm $+ $chr(124) $+ %fn
        var %need_update = 1
      }
    }
    if (%need_update == 1) {
      hsave -o amip-mp3s amip-mp3s.htbl
    }
    if (%is_stream == 0) {
      msg $active mp3 $+ $cfb2(%name) $+ $chr(32) $+ $cfb2(%br $+ kbps $+ @ $+ %sr $+ kHz) $+ $chr(32) $+ $cfb2(%min $+ m $+ %sec $+ s $+ $chr(47) $+ $getfilesize(%fullname)) $+ $chr(32) $+ $cfp2(Playing: %pm $+ m $+ %ps $+ s) $+ $chr(32) $+ $chr(2) $+ $chr(33) $+ $me $+ _mp3 $+ $chr(32) $+ %filenumber $+ $chr(2) $+ $chr(32) $+ to get it! 
    }
    else {
      msg $active mp3 $+ $cfb2(%name) $+ $chr(32) $+ $cfb2(%br $+ kbps $+ @ $+ %sr $+ kHz) $+ $chr(32) $+ $cfp2(Playing: %pm $+ m $+ %ps $+ s) $+ $chr(32) $+ $chr(2) $+ %fn $+ $chr(2) $+ $chr(32) $+ to listen in!
    }
  }
  elseif ($1 == showself) {
    if (%is_stream == 0) {
      disp2 Currently Playing: $+ $chr(32) $+ $cfb2(%name) $+ $chr(32) $+ $cfb2(%br $+ kbps $+ @ $+ %sr $+ kHz) $+ $chr(32) $+ $cfb2(%min $+ m $+ %sec $+ s $+ $chr(47) $+ $getfilesize(%fullname)) $+ $chr(32) $+ $cfp2(Playing: %pm $+ m $+ %ps $+ s)
    }
    else {
      disp2 Currently Playing: $+ $chr(32) $+ $cfb2(%name) $+ $chr(32) $+ $cfb2(%br $+ kbps $+ @ $+ %sr $+ kHz) $+ $chr(32) $+ $cfp2(Playing: %pm $+ m $+ %ps $+ s)
    }
  }
  elseif ($1 == search) {
    if ($2- == $null) { disp2 Syntax: $chr(47) $+ mp3 $+ $chr(32) $+ search <search string> | halt }
    var %numresults = $hfind(amip-mp3s,$chr(42) $+ $replace($2-,$chr(32),$chr(42)) $+ $chr(42),0,w).data
    if ($window(@amip-mp3_results,status) == 0) { window -aCe +le @amip-mp3_results }
    aline -c 12 @amip-mp3_results Found $+ $chr(32) $+ %numresults $+ $chr(32) $+ result(s) for $+ $chr(32) $+ $chr(42) $+ $replace($2-,$chr(32),$chr(42)) $+ $chr(42)
    if (%numresults != 0) {
      var %i = 1
      while (%i <= %numresults) {
        var %filenumber = $hfind(amip-mp3s,$chr(42) $+ $replace($2-,$chr(32),$chr(42)) $+ $chr(42),%i,w).data
        var %filename = $gettok($hget(amip-mp3s,%filenumber),1,124)
        aline @amip-mp3_results %filenumber - %filename
        inc %i
      }
      aline -c 12 @amip-mp3_results To play a file: $chr(47) $+ mp3 $+ $chr(32) $+ playfile <filenumber>
    }
  }
  elseif ($1 == playfile) {
    if ($2 == $null) { disp2 Syntax: $chr(47) $+ mp3 $+ $chr(32) $+ search <file number> | halt }
    if ((%winamp_path == $null) || (!$exists(%winamp_path))) {
      set %winamp_path $sdir(\,Please select the path to your winamp binary)
      echo -s %winamp_path
      if (%winamp_path == $null) { halt }
    }
    if (($isdir(%winamp_path)) && ($exists(%winamp_path $+ winamp.exe))) {
      if ($hget(amip-mp3s,$2) != $null) {
        var %fullname = $gettok($hget(amip-mp3s,$2),2,124)
      }
      else {
        disp2 Sorry, that is not a valid file number.  Try $chr(47) $+ mp3 $+ $chr(32) $+ search <search string> to search.
        halt
      }
      if ($exists(%fullname)) {
        run %winamp_path $+ winamp.exe $+ $chr(32) $+ $chr(34) $+ %fullname $+ $chr(34)
        disp2 Playing %fullname with winamp.
      }
      else {
        disp2 Sorry, I was unable to find the file you requested.  Try $chr(47) $+ mp3 $+ $chr(32) $+ search <search string> to search.
        hdel amip-mp3s $2
        hsave -o amip-mp3s amip-mp3s.htbl
        halt
      }
    }
    else {
      disp2 Sorry, I could not locate your winamp binary.  Please select the path to your winamp binary.
      unset %winamp_path
      set %mp3path $sdir(\,Please select the path to your winamp binary.)
      disp2 Please try to play your filenumber again.
    }
  }
  elseif ($1 == play) {
    if ($dde mPlug var_playing "" == $null) {
      dde mPlug control play
      disp2 Winamp now playing.
    }
    else {
      disp2 Winamp already playing.
    }
  }
  elseif ($1 == pause) {
    dde mPlug control pause
  }
  elseif ($1 == stop) {
    dde mPlug control stop
  }
  elseif ($1 == ff) {
    dde mPlug control ff
  }
  elseif ($1 == rew) {
    dde mPlug control rew
  }
  elseif ($1 == vup) {
    dde mPlug control vup
  }
  elseif (($1 == vdown) || ($1 == vdwn)) {
    dde mPlug control vdwn
  }
  elseif ($1 == voff) {
    dde mPlug control vol 0
  }
  elseif ($1 == vmax) {
    dde mPlug control vol 255
  }
  elseif ($1 == repeat) {
    var %repeat = $dde mPlug var_repeat ""
    if (%repeat == off) {
      dde mPlug setrepeat on
    }
    elseif (%repeat == on) {
      dde mPlug setrepeat off
    }
  }
  elseif ($1 == shuffle) {
    var %shuffle = $dde mPlug var_shuffle ""
    if (%shuffle == off) {
      dde mPlug setshuffle on
    }
    elseif (%shuffle == on) {
      dde mPlug setshuffle off
    }
  }
  elseif ($1 == next) {
    dde mPlug control >
  }
  elseif ($1 == prev) {
    dde mPlug control <
  }
  else {
    disp2 IRC Command Syntax: /mp3 <show|showself|search|playfile>
    disp2 Winamp Control Syntax: /mp3 <play|pause|stop|ff|rew|vup|vdwn|voff|vmax|repeat|shuffle|next|prev>
  }
}

;; search given path for mp3 files to add to hash table
alias mp3find {
  amip_table_exists_check
  if ($1- == $null) {
    var %mp3path = $sdir(\,Select the folder containing your mp3 files)
    if (%mp3path == $null) { halt }
  }
  else { var %mp3path = $1- }
  if ($isdir(%mp3path)) {
    var %input = $input(Searching file paths may take some time. $+ $crlf $+ Are you sure you wish to continue?,yv,Continue?)
    if (%input == $no) { halt }
    elseif (%input == $yes) {
      var %numfiles = $findfile(%mp3path,*.mp3,0)
      var %i = 1
      var %i2 = 0
      while (%i <= %numfiles) {
        var %filepath = $findfile(%mp3path,*.mp3,%i)
        var %need_update = 0
        if ($hfind(amip-mp3s,$nopath(%filepath) $+ $chr(42),1,w).data == $null) {
          var %filenumber = $rand(100000,999999)
          if ($hget(amip-mp3s,%filenumber) == $null) {
            hadd amip-mp3s %filenumber $nopath(%filepath) $+ $chr(124) $+ %filepath
            var %need_update = 1
            inc %i2
          }
          else {
            while ($hget(amip-mp3s,%filenumber) != $null) {
              var %filenumber = $rand(100000,999999)
            }
            hadd amip-mp3s %filenumber $nopath(%filepath) $+ $chr(124) $+ %filepath
            var %need_update = 1
            inc %i2
          }
        }
        else {
          var %filenumber = $hfind(amip-mp3s,%nm $+ $chr(42),1,w).data
          var %filename = $gettok($hget(amip-mp3s,%filenumber),1,124)
          var %fullname = $gettok($hget(amip-mp3s,%filenumber),2,124)
          if (!$exists(%fullname)) {
            hdel amip-mp3s %filenumber
            hadd amip-mp3s %filenumber $nopath(%filepath) $+ $chr(124) $+ %filepath
            var %need_update = 1
            inc %i2
          }
        }
        if (%need_update == 1) {
          hsave -o amip-mp3s amip-mp3s.htbl
          echo -s amip-mp3s table updated: %filenumber - $nopath(%filepath) ( $hget(amip-mp3s,0).item total items in table)
        }
        inc %i
      }
      disp2 Search finished: Found %i files in specified path ( %i2 table entries updated )
      }
    }
    else { halt }
  else { disp2 Sorry, that doesn't appear to be a valid directory. | halt }
}

;; mp3 leech/search
on *:TEXT:*:#:{
  if ($1 == $chr(33) $+ $me $+ _mp3) {
    amip_table_exists_check
    if ($hget(amip-mp3s,$2) != $null) {
      var %fullname = $gettok($hget(amip-mp3s,$2),2,124)
    }
    else {
      .notice $nickSorry, that is not a valid file number.  Try $+ $chr(32) $+ $chr(33) $+ $me $+ _mp3find $+ $chr(32) $+ <search string> to search.
      halt
    }
    if ($exists(%fullname)) {
      dcc send $nick %fullname
    }
    else {
      .notice $nick Sorry, I was unable to find the file you requested.  Try $+ $chr(32) $+ $chr(33) $+ $me $+ _mp3find $+ $chr(32) $+ <search string> to search.
      hdel amip-mp3s $2
      hsave -o amip-mp3s amip-mp3s.htbl
      halt
    }
  }
  elseif ($1 == $chr(33) $+ $me $+ _randmp3) {
    amip_table_exists_check
    var %filenumber = $hget(amip-mp3s,$rand(1,$hget(amip-mp3s,0).item)).item
    var %fullname = $gettok($hget(amip-mp3s,%filenumber),2,124)
    if ($exists(%fullname)) {
      dcc send $nick %fullname
    }
    else {
      .notice $nick Sorry, I was unable to find the file you requested.  The file may have been moved or deleted, please try again.
      hdel amip-mp3s %filenumber
      hsave -o amip-mp3s amip-mp3s.htbl
      halt
    }
  }
  elseif ($1 == $chr(33) $+ $me $+ _mp3find) {
    amip_table_exists_check
    var %numresults = $hfind(amip-mp3s,$chr(42) $+ $replace($2-,$chr(32),$chr(42)) $+ $chr(42),0,w).data
    var %send_file = 0
    .notice $nick Found $+ $chr(32) $+ %numresults $+ $chr(32) $+ result(s) for $+ $chr(32) $+ $chr(42) $+ $replace($2-,$chr(32),$chr(42)) $+ $chr(42)
    if (%numresults != 0) {
      if (%numresults > 4) {
        .notice $nick your search returned more than 4 results, dcc sending a text file.
        var %send_file = 1
        var %send_file_name = $gmt $+ . $+ $nick $+ .txt
        write -c %send_file_name $str($chr(45),45)
        write -a %send_file_name Search results for $+ $chr(32) $+ $chr(42) $+ $replace($2-,$chr(32),$chr(42)) $+ $chr(42)
        write -a %send_file_name Performed $fulldate
        write -a %send_file_name $str($chr(45),45)
      }
      var %i = 1
      while (%i <= %numresults) {
        var %filenumber = $hfind(amip-mp3s,$chr(42) $+ $replace($2-,$chr(32),$chr(42)) $+ $chr(42),%i,w).data
        var %filename = $gettok($hget(amip-mp3s,%filenumber),1,124)
        if (%send_file == 1) {
          write -a  %send_file_name %filenumber - %filename
        }
        else {
          if (%i = 4) { var %numresults = 5 }
          .notice $nick %filenumber - %filename
        }
        inc %i
      }
      .notice $nick $chr(32) $+ $chr(33) $+ $me $+ _mp3 $+ $chr(32) $+ <number> to get a song.
      if (%send_file == 1) {
        dcc send $nick %send_file_name
        .timer $+ %send_file_name 1 60 .remove %send_file_name
      }
    }
  }
  else { halt }
}
