#!/usr/local/bin/tclsh8.4

## pure tcl file receiver
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

if {[file exists getshell.conf]} {
   source getshell.conf
} else {
   puts "Error: Config file not found!"
   exit
}

proc timestamp {} { return [clock format [clock seconds] -format "%a %b %d %H:%M:%S %Z %Y"] }

proc bgerror { text } {
global LogType
   if {$LogType == 1} {
      write_log "Error: $text"
   }
   puts "$text"
   exit 0
}

proc write_log { text } {
global LogType LogFile
   puts "$text"
   if {$LogType == 1} {
      set logfile [open $LogFile a+ 0600]
      puts $logfile "$text"
      close $logfile
   }
}

proc init {} {
global ListenPort MyAddr IpRestrict IpList ServerSock
   if {$MyAddr != ""} {
      set ServerSock [socket -server server_connect -myaddr $MyAddr $ListenPort]
   } else {
      set ServerSock [socket -server server_connect $ListenPort]
   }
   puts ""
   puts "GetShell: Listening Port $ListenPort"
   if {$MyAddr != ""} {
      puts "GetShell: Listening Host $MyAddr"
   } else {
      puts "GetShell: Listening Host *"
   }
   if {$IpRestrict == "1"} {
      puts "GetShell: IP Restriction Active"
      puts "GetShell: Allowed IPs: $IpList"
   } else {
      puts "GetShell: IP Restriction NOT ACTIVE (please activate for increased security)"
   }
   puts "GetShell: Launched..."
   puts "GetShell: Press <CTRL> + <C> to close server."
   puts ""
   write_log "Server socket ($ServerSock) opened at [timestamp]\n"
   vwait forever
}

proc close_socket { addr sock } {
global Session Authorized
   catch { close $sock }
   catch { unset Authorized($addr,$sock) }
   catch { unset Session($addr,$sock) }
}

proc server_connect { sock addr cport } {
global Session IpRestrict IpList Authorized
   set allow_connect 0 ; set Authorized($addr,$sock) 0
   set Session($addr,$sock) [list $addr $cport]
   fconfigure $sock -buffering line
   if {$IpRestrict == 1} {
      foreach ip "$IpList" {
         if {[string match "$ip" "$addr"]} {
            set allow_connect 1
         }
      }
   } else { set allow_connect 1 }
   if {$allow_connect != 1} {
      write_log "Closed unauthorized connect ($sock) from $Session($addr,$sock) at [timestamp]"
      close_socket $addr $sock
   } else {
      write_log "Accept $sock from $Session($addr,$sock)"
      fileevent $sock readable [list input_handler $sock $addr]
   }
}

proc input_handler { sock addr } {
global Session ServerSock MyAddr ListenPort FilePath AuthKey Authorized
   if {[eof $sock] || [catch {gets $sock line}]} {
      close $sock
      write_log "Closed $Session($addr,$sock)"
      unset Session($addr,$sock)
   } else {
      if {[string equal "[lindex [split $line] 0]" "+HEADER"]} {
         set header [split [lindex [split $line] 1] :]
         if {[string equal "[lindex $header 0]" "$AuthKey"]} { set Authorized($addr,$sock) 1 }
         if {![string equal {} "[lindex $header 1]"]} { set fName($addr,$sock) [lindex $header 1] }
      }
      if {$Authorized($addr,$sock) != 1} {
         write_log "Closed unauthorized connect ($sock) from $Session($addr,$sock) at [timestamp]"
         close_socket $addr $sock; return
      }
      if {![string equal "[lindex [split $line] 1]" "exit"]} {
         write_log "Accepting file $fName($addr,$sock) from $Session($addr,$sock)"
			fconfigure $sock -buffering none -encoding binary -translation binary
         set outfile [open $FilePath/$fName($addr,$sock) w]
         fconfigure $outfile -buffering none -encoding binary -translation binary
         set startsecs [clock seconds]
         set bytes [fcopy $sock $outfile]; close $outfile
         set time [expr [clock seconds] - $startsecs]
         if {$time != 0} {
            set speed [expr ($bytes / $time) / 1000.0]
         } else { set speed 0 }
         puts "DONE: Transfered $fName($addr,$sock) $bytes total bytes in $time seconds ($speed Kbps)."
         write_log "Closed connection ($sock) from $Session($addr,$sock) at [timestamp]"
         close_socket $addr $sock
         puts "\nGetShell: Waiting for next connection..."
         puts "GetShell: Press <CTRL> + <C> to close server.\n"
      } elseif {[string equal "[lindex [split $line] 1]" "exit"]} {
         close_socket $addr $sock
      } else { return }
   }
}
init
