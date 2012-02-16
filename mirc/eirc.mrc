;; blowfish encrypted irc (EIRC)
;; version 0.08
;; by leprechau @ EFnet
;; 04.03.03
;;
;; NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
;; this is the only official location for any of my scripts
;;

;; main alias for all commands
alias eirc {
  if ($1 == $null) { 
    echo -a Command Syntax: /eirc <on|off|setkey|showkey|showchans|help> | halt
  }
  elseif ($1 == on) {
    ;; set/view encrypted channels
    if (%eircon == $null) {
      set %eircon $chan %eircon
    }
    elseif ($chan !isin %eircon) {
      set %eircon $chan %eircon
    }
    else {
      echo -a Channel Already Active
      echo -a Currently Active Channel(s): %eircon
      halt
    }
    echo -a $chr(2) $+ EIRC Activated $+ $chr(2)
    echo -a Currently Active Channel(s): %eircon
  }
  elseif ($1 == off) {
  ;; remove/view encrypted channels
    if (%eircon == $null) {
      echo -a No Active Channels
      halt
    }
    elseif ($chan isin %eircon) {
      set %eircon $remove(%eircon,$chan)
    }
    else {
      echo -a Channel Not Active
      echo -a Currently Active Channel(s): %eircon
      halt
    }
    echo -a $chr(2) $+ EIRC Deactivated $+ $chr(2)
    echo -a Currently Active Channel(s): %eircon
  }
  elseif ($1 == setkey) {
    ;; set encryption key
    if ($1 == $null) {
      echo -a Usage: /eirckey <encryption key>
      echo -a Example: /eirckey abc123
      halt
    }
    set %eirckey $1
    echo -a $chr(2) $+ Set Key:  $+ $chr(2) $+ $chr(32) %eirckey
  }
  elseif ($1 == showkey) {
    ;; alias to show current encryption key
    if (%eirckey == $null) {
      echo -a $chr(2) $+ NO KEY SET $+ $chr(2)
    }
    else {
      echo -a Current Key: %eirckey
    }
  }
  elseif ($1 == showchans) {
    echo -a Currently Active Channel(s): %eircon
  }
  elseif ($1 == help) {
    ;; show detailed command help
    echo -a Blowfish Encrypted IRC (EIRC)
    echo -a version 0.08 (04.03.03) by leprechau@EFnet
    echo -a Commands:
    echo -a /eirc on
    echo -a ^- turns script on for active channel and shows currently active channels
    echo -a /eirc off
    echo -a ^- turns script off for active channel and shows still active channels
    echo -a /eirc setkey <key>
    echo -a ^- sets the desired encryption key
    echo -a /eirc showkey
    echo -a ^- shows the current encryption key
    echo -a /eirc showchans
    echo -a ^- shows currently enabled channels
    echo -a /eirc help
    echo -a ^- displays this help menu :P
  }
  else { echo -a Command Syntax: /eirc <setkey|showkey|on|off|help> | halt }
}

;; input/encryption handler
on *:INPUT:#:{
  if ((%eircon != $null) && ($chan isin %eircon)) {
    if (/* !iswm $1 ) {
      if (%eirckey == $null) {
         echo -t $chan Sorry, you must set a key before sending encrypted messages.
         halt
      }
      echo -mt $chan $chr(2) $+ $chr(3) $+ 12 $+ $chr(40) $+ $chr(2) $+ $nick($chan,$me).pnick $+ $chr(2) $+ $chr(41) $+ $chr(2) $+ $chr(3) $+ $chr(58) $+ $chr(32) $+ $1-
      .msg $chan $dll(blowfish.dll,Encrypt,%eirckey $1-) | halt
    }
  }
}

;; output/decryption handler
on ^*:TEXT:+OK*:#:{
  if ((%eircon != $null) && ($chan isin %eircon)) {
    if (%eirckey == $null) {
      echo -t $chan Sorry, you must set a key to view encrypted messages.
      halt
    }
    echo -mt $chan $chr(2) $+ $chr(3) $+ 3 $+ $chr(40) $+ $chr(2) $+ $nick($chan,$nick).pnick $+ $chr(2) $+ $chr(41) $+ $chr(2) $+ $chr(3) $+ $chr(58) $+ $chr(32) $+ $right($dll(blowfish.dll,Decrypt,%eirckey $2),-3) | halt
  }
}
