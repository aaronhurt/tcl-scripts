##################################################
## grepable eggdrop channel logging version 1.2 ##
## by leprechau@efnet for innuendon@efnet       ##
## 1.0 initial release monday, june 17, 2002    ##
## 1.2 friday, october 4, 2002                  ##
##   - fixed open records caused by log switch  ##
##   - fixed open records caused by bot drop    ##
##   - other miscellaneous code cleanup         ##
##################################################
##          DO NOT EDIT THIS SCRIPT             ##
##         DOING SO IS NOT SUPPORTED            ##
##################################################
set nicklog_ver "1.2"

## Startup and Initialization
if {![file isfile nicklog]} {
   putlog "\[\002ERROR\002\] File 'nicklog' does not exist!"
   putlog "   --- Creating empty file"
   if {[catch {exec touch nicklog} error] != 0} {
      putlog "\[\002ERROR\002\] Could not create new nicklog file:  $error"
   }
   putlog "Done! Continuing to load nicklog.tcl ..."
}

## Small proc to remove blank lines from database
proc clean_nicklog {} {
   if {![file isfile nicklog]} {
      putlog "\[\002ERROR\002\] File 'nicklog' does not exist!"
      putlog "   --- Creating empty file"
      if {[catch {exec touch nicklog} error] != 0} {
         putlog "\[\002ERROR\002\] Could not create new nicklog file:  $error"
      }
      putlog "Done!"
   }

   if {[catch {set file [open nicklog r]} open_error] != 0} {
      putlog "\[\002ERROR\002\] Could not open 'nicklog' for reading:  $open_error" ; return
   }
   if {[catch {set tmpfile [open .nicklog.tmp w 0600]} open_error] != 0} {
      putlog "\[\002ERROR\002\] Could not open temp file '.nicklog.tmp' for writing:  $open_error" ; return
   }
   set success 1
   while {![eof $file]} {
      gets $file line
      if {"" != [string tolower $line]} {
         if {[catch { puts $tmpfile "$line" } write_error] != 0} {
            set success 0
            putlog "\[\002ERROR\002\] Could not write to temp file:  $write_error"
         }
      }
   }
   if {[catch {close $file} close_error] != 0} {
      set success 0
      putlog "\[\002ERROR\002\] Error closing 'nicklog' file:  $close_error"
   }
   if {[catch {close $tmpfile} close_error] != 0} {
      set success 0
      putlog "\[\002ERROR\002\] Error closing temp file '.nicklog.tmp':  $close_error"
   }
   if {[catch {exec mv -f .nicklog.tmp nicklog} error] != 0} {
      set success 0
      putlog "\[\002ERROR\002\] Could not move nicklog from temp file:  $error"
   }
   return $success
}
clean_nicklog

# small universal tool proc to aid in dealing with strings
proc srange { string start end } { return [join [lrange [split [string trim $string] " "] $start $end]] }

# logging proc used for all events
proc event_log { args } {
   if {[catch {set file [open nicklog a 0600]} open_error] != 0} {
      putlog "\[\002ERROR\002\] Could not open nicklog for writing:  $open_error" ; return
   }
   if { [catch { puts $file "[srange $args 0 end]" } write_error] != 0} {
      putlog "\[\002ERROR\002\] Could not write to nicklog file:  $write_error"
   }
   if {[catch {close $file} close_error] != 0} {
      putlog "\[\002ERROR\002\] Error closing nicklog file:  $close_error"
   }
   clean_nicklog
}

# close all open records on server disconnect
proc nicklog_disconnect { type } {
global open_records nicklog_disconnected
   if {![info exists open_records]} { return }
   foreach 1chan [array names open_records] {
      if {[info exists open_records($1chan)]} {
         foreach 1user [srange $open_records($1chan) 0 end] {
            event_log [lindex [date] 1] [lindex [date] 0] [lindex [date] 2] [time] $1chan $1user QUIT BOT_DISCONNECT
         }
         unset open_records($1chan)
      }
   }
   if {[info exists open_records]} { unset open_records }
   set nicklog_disconnected 1
}
bind evnt - disconnect-server nicklog_disconnect

# small proc to close open records
proc nicklog_closerecord { chan hand } {
global open_records
   if {![info exists open_records($chan)]} { return }
   set index [lsearch -exact $open_records($chan) $hand]
   if {$index != -1} {
     set open_records($chan) [split [join [string map {"{}" ""} [lreplace $open_records($chan) $index $index ""]] ,] ,]
   } else { return }
}


# write records for all users on given channel
proc nicklog_writeall { chan event reason } {
   foreach 1user [srange [chanlist $chan] 0 end] {
      if {[validuser [nick2hand $1user]]} {
         set hand [nick2hand $1user]
	 nicklog_closerecord $chan $hand
         event_log [lindex [date] 1] [lindex [date] 0] [lindex [date] 2] [time] $chan $hand $event $reason
      }
   }
}

# check and log joins
proc nicklog_joins { nick uhost hand chan } {
global open_records botnick nicklog_disconnected
   if {([string match $nick $botnick]) && ([info exists nicklog_disconnected])} {
      nicklog_writeall $chan JOIN BOT_REJOIN
   } elseif {([validuser [nick2hand $nick]]) && (![string match $nick $botnick])} {
      if {![info exists open_records($chan)]} {
         lappend open_records($chan) $hand 
      } elseif {([lsearch -exact $open_records($chan) $hand] == -1)} {
         lappend open_records($chan) $hand
      } else { continue } 
      event_log [lindex [date] 1] [lindex [date] 0] [lindex [date] 2] [time] $chan $hand JOIN
   } else { return }
}
bind join - * nicklog_joins

# check and log parts
proc nicklog_parts { nick uhost hand chan {msg ""} } {
   if {[validuser [nick2hand $nick]]} {
      nicklog_closerecord $chan $hand
      event_log [lindex [date] 1] [lindex [date] 0] [lindex [date] 2] [time] $chan $hand PART
   } else { return }
}
bind part - * nicklog_parts

# check and log quits
proc nicklog_quits { nick uhost hand chan {reason ""} } {
   if {[validuser [nick2hand $nick]]} {
      nicklog_closerecord $chan $hand
      event_log [lindex [date] 1] [lindex [date] 0] [lindex [date] 2] [time] $chan $hand QUIT
   } else { return }
}
bind sign - * nicklog_quits

# time bound proc to rotate log files in eggdrop style
proc nicklog_rotate { minute hour day month year } {
   putlog "\[\002NICKLOG\002\] Preparing to switch nicklog file: writing parts for all users in all channels"
   foreach 1chan [channels] { nicklog_writeall $1chan PART END_OF_DAY }
   putlog "\[\002NICKLOG\002\] Switching nicklog file from 'nicklog' to 'nicklog.yesterday'"
   if {[catch {exec mv -f nicklog nicklog.yesterday} error] != 0} {
      putlog "\[\002ERROR\002\] Could not move nicklog to nicklog.yesterday:  $error"
   }
   if {[catch {exec touch nicklog} error] != 0} {
      putlog "\[\002ERROR\002\] Could not create new nicklog file:  $error"
   }
   putlog "\[\002NICKLOG\002\] Post nicklog switch: writing joins for all users in all channels"
   foreach 1chan [channels] { nicklog_writeall $1chan JOIN START_OF_DAY }
}
bind time - "00 00 * * *" nicklog_rotate

putlog "nicklog.tcl v$nicklog_ver by leprechau@efnet loaded."