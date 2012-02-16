#!/usr/local/bin/tclsh8.4

proc ip2long {ip} {
   foreach {a b c d} [split $ip .] {}
   set long [expr {$a * pow(256,3)} + {$b * pow(256,2)} + {$c * 256} + $d]
   return [format %0.f $long]
}

proc init:send {client fname} {
global ircsock
   set tmpsock [socket -server NULL -myaddr [info hostname] 0]
   set myip [lindex [split [fconfigure $tmpsock -sockname]] 0]
   close $tmpsock
   set longip [ip2long $myip]
   set port [expr int(rand() * 3976) + 1024]
   uplevel #0 set fName $fname
   set sock [socket -server dcc:accept $port]
   puts $ircsock "PRIVMSG $client :\001DCC SEND $fname $longip $port [file size $fname]\001"
   vwait dccdone
}

proc dcc:accept {sock addr port} {
global dccSession fName
   puts "Accepting DCC ($sock) connection from $addr port $port"
   set dccSession(addr,$sock) [list $addr $port]
   fconfigure $sock -buffering line -encoding binary -translation binary
   fileevent $sock writable [list dcc:send $sock $fName]
}

proc dcc:send {sock fname} {
global dccSession
   set fsize [file size $fname]
   set sfile [open $fname r]
   fconfigure $sfile -encoding binary -translation binary
   set errorlevel 0
   set bsent 0
   set buff 1024
   while {$errorlevel != 1} {
      if {[eof $sfile]} {
         catch {close $sfile}
         catch {unset dccSession(addr,$sock)}
         set errorlevel 1 ; break
      } else {
         set bleft [expr $fsize - $bsent]
         if {$bleft <= $buff } {
            set data [read $sfile $bleft]
         } else {
            set data [read $sfile $buff]
         }
      }
      if {[eof $sock]} {
         catch {close $sock}
         catch {unset dccSession(addr,$sock)}
         set errorlevel 1 ; break
      } else {
         puts -nonewline $sock $data
         set bsent [expr $bsent + $buff]
      }
   }
   uplevel #0 set dccdone 1
   puts "DONE: $bsent bytes sent of $fsize total bytes with $buff bytes buffer"
}
