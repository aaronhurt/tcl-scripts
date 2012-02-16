;; blowfish encrypted irc (EIRC)
;; version 0.08
;; by leprechau @ EFnet
;; 02/03/03

;; alias to show help :P
alias eirchelp {
  echo -a Blowfish Encrypted IRC (EIRC)
  echo -a version 0.08 by leprechau@EFnet
  echo -a Commands:
  echo -a /eirckey <key>
  echo -a ^- sets the desired encryption key
  echo -a /eircshowkey
  echo -a ^- shows the current encryption key
  echo -a /eircon
  echo -a ^- turns script on for active channel and shows currently active channels
  echo -a /eircoff
  echo -a ^- turns script off for active channel and shows still active channels
  echo -a /eirchelp
  echo -a ^- displays this help menu :P
}

;; alias to help set/view encryption key
alias eirckey {
  if ($1 == $null) {
    echo -a Usage: /eirckey <encryption key>
    echo -a Example: /eirckey abc123
    halt
  }
  set %eirckey $1
  echo -a $chr(2) $+ Set Key:  $+ $chr(2) $+ $chr(32) %eirckey
}

;; alias to show current encryption key
alias eircshowkey {
  if (%eirckey == $null) {
    echo -a $chr(2) $+ NO KEY SET $+ $chr(2)
  }
  else {
    echo -a Current Key: %eirckey
  }
}

;; alias to set/view encrypted channels
alias eircon {
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

;; alias to remove/view encrypted channels
alias eircoff {
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

;; input handler
on 1:INPUT:#:{
  if ((%eircon != $null) && ($chan isin %eircon)) {
    if (/* !iswm $1 ) {
      if (%eirckey == $null) {
         echo -t $chan Sorry, you must set a key before sending encrypted messages.
         halt
      }
      echo -mt $chan $chr(2) $+ $chr(3) $+ 12 $+ $me $+ $chr(2) $+ $chr(3) $+ $chr(58) $+ $chr(32) $+ $1-
      .msg $chan EIRC $+ $chr(32) $+ $right($dll(blowfish.dll,Encrypt,%eirckey $1-),-3) | halt
    }
  }
}

;; output handler
on ^1:TEXT:EIRC*:#:{
  if ((%eircon != $null) && ($chan isin %eircon)) {
    if (%eirckey == $null) {
      echo -t $chan Sorry, you must set a key to view encrypted messages.
      halt
    }
    echo -mt $chan $chr(2) $+ $chr(3) $+ 3 $+ $nick $+ $chr(2) $+ $chr(3) $+ $chr(58) $+ $chr(32) $+ $right($dll(blowfish.dll,Decrypt,%eirckey $2),-3) | halt
  }
}
