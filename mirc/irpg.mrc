;; irpg@EFnet stats script for mirc
;; v1.2 by leprechau@EFnet
;; 07.06.2004
;;
;; NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
;; this is the only official location for any of my scripts
;;

;; get user id
alias irpg_init {
   goto $$1
   :first
   var %input = $input(Thank you for testing #irpg@EFnet statistics for mIRC.  After clicking OK $+ $chr(44) $+ $chr(32) $+ you will be asked a few questions to configure this script.  If you have any questions or comments $+ $chr(44) $+ $chr(32) $+ contact leprechau@EFnet.,oi,Welcome)
   if (%input == $true) { return }
   else { goto first }
   return
   :vwarn
   var %input = $input(The #irpg@EFnet statistics script has only been tested on mIRC version 6.10 and greater.  You are running mIRC version $chr(39) $+ $version $+ $chr(39) $+ $chr(44) $+ $chr(32) $+ Some or all of this script may not function properly.  It is reccomended that you upgrade to the latest version of mIRC. $+ $crlf $crlf $+ Available from http://www.mirc.com,ow,Version Warning)
   if (%input == $true) { return }
   else { goto vwarn }
   :uid
   var %id = $input(Enter your #irpg@EFnet user id:,oe,Enter ID Number)
   if (%id !isnum) { var %input = $input(Sorry $chr(39) $+ %id $+ $chr(39) is not a valid id number.,o,ERROR) | goto uid }
   var %input = $input(You entered $chr(39) $+ %id $+ $chr(39) is this correct?,y,Confirm User ID)
   if (%input == $false) { goto uid }
   if (%input == $true) { set %irpg_id %id } | return
   :cc
   echo -ae COLORS: 1,0 0 0,1 1 0,2 2 0,3 3 0,4 4 0,5 5 0,6 6 0,7 7 1,8 8 1,9 9 0,10 10 1,11 11 0,12 12 0,13 13 0,14 14 1,15 15 
   var %cc = $input(Enter the color code you would like to use for text headers (see below),oe,Enter Color Code)
   if (%cc !isnum 0-15) { var %input = $input(Sorry $chr(39) $+ %cc $+ $chr(39) is not a valid color code.,o,ERROR) | goto cc }
   var %input = $input(You entered $chr(39) $+ %cc $+ $chr(39) is this correct?,y,Confirm Color Code)
   if (%input == $false) { goto cc }
   elseif (%input == $true) {
      if ($len(%cc) < 2) { set %irpg_cc 0 $+ %cc }
      else { set %irpg_cc %cc }
   }
   else { goto cc }
   return
   :colors
   var %input = $input(Would you like to show colored output?,y,Use Colors?)
   if (%input == $true) { set %irpg_use_color 1 }
   if (%input == $false) { set %irpg_use_color 0 }
   return
   :thanks
   var %input = $input(Your #irpg@EFnet statistics script is now configured. $+ $crlf $+ $crlf $+ To use type: /irpg $+ $crlf $+ $crlf $+ You can change the configuration options at any time by right clicking in any channel or query window and selecting the $chr(39) $+ Irpg Settings $+ $chr(39) menu. $+ $crlf $+ $crlf $+ Report any bugs or suggestions to leprechau@EFnet,oi,Thank You)
   if (%input == $true) { set %irpg_configured true }
   else { goto end }
   return
}

;; clear variables on first load
on *:load:{ unset %irpg* | irpg_init first }

;; check status of dependent variables
on *:start:{
   if ($version < 6.10) { irpg_init vwarn }
   if (%irpg_id == $null) { irpg_init uid }
   if (%irpg_cc == $null) { irpg_init cc }
   if (%irpg_use_color == $null) { irpg_init colors }
   if (%irpg_configured == $null) { irpg_init thanks }
}

;; formatting alias
alias irpgf {
  if (($1 != $null) && ($2 != $null)) {
    if ((%irpg_use_color == 1) && (%irpg_cc != $null)) {
      return $chr(3) $+ %irpg_cc $+ $1 $+ $chr(3) $+ $chr(31) $+ $chr(91) $+ $chr(31) $+ $2 $+ $chr(31) $+ $chr(93) $+ $chr(31)
    }
    else { return $1 $+ $chr(91) $+ $2 $+ $chr(93) }
  }
}

;; fetch xml stats
on *:sockopen:irpg:{
   if ($sockerr > 0) {
      echo -a Error: Socket $sockname $sock($sockname).wsmsg $+ , closing socket.
      sockclose $sockname
   }
   else { sockwrite $sockname GET http://idlerpg.com/gsrpg/player.php?id= $+ %irpg_id HTTP/1.0 $+ $crlf $+ $crlf }
}

;; get and parse data returned from website
on *:sockread:irpg:{
   if ($sockerr > 0) {
      echo -a Error: Socket $sockname $sock($sockname).wsmsg $+ , closing socket.
      sockclose $sockname | return
   }
   :nextread
   sockread %line
   if ($sockbr == 0) {
      sockclose $sockname
      if (%irpg_output != $null) { msg $active %irpg_output | unset %irpg_output }
      return
   }
   if (%line == $null) { %line = -- }
   if ($regex(%line,(<.+?>)([^<]*)(<.+?>)) > 0) {
      goto $remove($regml(1),<,>)
      :id
         goto nextread
      :username
         set %irpg_output $irpgf(Username,$regml(2)) | goto nextread
      :level
         set %irpg_output %irpg_output $+ $chr(32) $+ $irpgf(Level,$regml(2)) | goto nextread
      :class
         set %irpg_output %irpg_output $+ $chr(32) $+ $irpgf(Class,$regml(2)) | goto nextread
      :nextlevel
         set %irpg_output %irpg_output $+ $chr(32) $+ $irpgf(Next Level,$duration($regml(2))) | goto nextread
      :online
         set %irpg_output %irpg_output $+ $chr(32) $+ $irpgf(Status,$replace($regml(2),1,Online,0,Offline)) | goto nextread
      :idled
         set %irpg_output %irpg_output $+ $chr(32) $+ $irpgf(Total Idled,$duration($regml(2))) | goto nextread
      :created
         set %irpg_output %irpg_output $+ $chr(32) $+ $irpgf(Registered,$asctime($regml(2),mmm dd yyyy@HH:nn:ss)) | goto nextread
      :lastlogin
         set %irpg_output %irpg_output $+ $chr(32) $+ $irpgf(Last Login,$asctime($regml(2),mmm dd yyyy@HH:nn:ss)) | goto nextread
      :lastlogout
         goto nextread
      :nick
         goto nextread
      :timetochallenge
         if ($regml(2) != 0) { var %next = $duration($regml(2)) }
         else { var %next = Now }
         set %irpg_output %irpg_output $+ $chr(32) $+ $irpgf(Next Challenge,%next) | goto nextread
      :challenges
         set %irpg_output %irpg_output $+ $chr(32) $+ $irpgf(Challenges,$regml(2)) | goto nextread
      :itemsum
         set %irpg_output %irpg_output $+ $chr(32) $+ $irpgf(Itemsum,$regml(2)) | goto nextread
   }
   goto nextread
}

;; give error if connection closed by remote
on *:sockclose:irpg:{ echo -a Error: Connection closed by remote host. }

;; open initial socket to get stats
alias irpg {
   if (%irpg_output != $null) { unset %irpg_output }
   if ($sock(irpg) != $null) {
      echo -a Error: Socket already in use.  Please wait one minute and try again. | halt
   }
   else { sockopen irpg idlerpg.com 80 }
}

;; make a couple menus for script settings
menu channel,query {
   Irpg Settings
   .User ID:irpg_init uid
   .Color Code:irpg_init cc
   .Toggle Color
   ..On:set %irpg_use_color 1 | echo -a Irpg stats colored output enabled.
   ..Off:set %irpg_use_color 0 | echo -a Irpg stats colored output disabled.
}
