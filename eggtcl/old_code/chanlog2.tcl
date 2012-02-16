##################################################
## simple channel stats for www version 1.0     ##
## by leprechau@efnet for fiz@efnet             ##
## Wednesday, September 11, 2002                ##
##################################################


##################################################
# User Defined Settings                          #
##################################################
set chanlog "chanlog.log"
# the name and path of your log file
# default path is eggdrop root directory
set chanlog_exempt "#channela, #channelb"
# a comma seperated list of channels not to log
set log_time "15"
# frequency in minutes that you wish to log stats

##################################################
##          DO NOT EDIT THIS SCRIPT             ##
##         DOING SO IS NOT SUPPORTED            ##
##################################################
set chanlog_ver "1.0"

## Startup and Initialization
if {![file isfile $chanlog]} {
   putlog "\[\002ERROR\002\] File '$chanlog' does not exist!"
   putlog "   --- Creating empty file"
   if {[catch {exec touch $chanlog} error] != 0} {
      putlog "\[\002ERROR\002\] Could not create new chanlog file:  $error" ; return
   }
   putlog "Done! Continuing to load chanlog.tcl ..."
}

# 2 small procs to aid in setting/resetting timers
proc kill_timer { args } {
   set timerID [lindex $args 0]
   set killed 0
   foreach 1timer [timers] {
      if {[lindex $1timer 1] != $timerID} { continue }
      killtimer [lindex $1timer 2]
      set killed 1
   }
   return $killed
}

proc settimer { minutes command } {
   if {$minutes < 1} { set minutes 1 }
   kill_timer "$command"
   timer $minutes "$command"
}

# start the logging timer
if {![info exists chanlog_running]} {   
   settimer $log_time chanlog_trigger
   set chanlog_running 1
}

## Small proc to remove blank lines from database
proc clean_chanlog {} {
global chanlog
   if {![file isfile $chanlog]} {
      putlog "\[\002ERROR\002\] File '$chanlog' does not exist!"
      putlog "   --- Creating empty file"
      if {[catch {exec touch $chanlog} error] != 0} {
         putlog "\[\002ERROR\002\] Could not create new chanlog file:  $error" ; return
      }
      putlog "Done!"
   }

   if {[catch {set file [open $chanlog r]} open_error] != 0} {
      putlog "\[\002ERROR\002\] Could not open 'chanlog' for reading:  $open_error" ; return
   }
   if {[catch {set tmpfile [open .chanlog.tmp w 0600]} open_error] != 0} {
      putlog "\[\002ERROR\002\] Could not open temp file '.chanlog.tmp' for writing:  $open_error" ; return
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
      putlog "\[\002ERROR\002\] Error closing 'chanlog' file:  $close_error"
   }
   if {[catch {close $tmpfile} close_error] != 0} {
      set success 0
      putlog "\[\002ERROR\002\] Error closing temp file '.chanlog.tmp':  $close_error"
   }
   if {[catch {exec mv -f .chanlog.tmp $chanlog} error] != 0} {
      set success 0
      putlog "\[\002ERROR\002\] Could not move chanlog from temp file:  $error"
   }
   return $success
}
clean_chanlog

# small universal tool proc to aid in dealing with strings
proc srange { string start end } { return [join [lrange [split [string trim $string] " "] $start $end]] }

# logging proc
proc chanlog_log { arg } {
global chanlog
   if {[catch {exec rm -f $chanlog ; exec touch $chanlog} error] != 0} {
      putlog "\[\002ERROR\002\] Could not create new chanlog file:  $error" ; return
   }
   if {[catch {set file [open $chanlog w 0600]} open_error] != 0} {
      putlog "\[\002ERROR\002\] Could not open chanlog for writing:  $open_error" ; return
   }
   if { [catch { puts $file "[srange $arg 0 end]" } write_error] != 0} {
      putlog "\[\002ERROR\002\] Could not write to chanlog file:  $write_error"
   }
   if {[catch {close $file} close_error] != 0} {
      putlog "\[\002ERROR\002\] Error closing chanlog file:  $close_error"
   }
   clean_chanlog
}

# check and log all channels at specified increment
proc chanlog_trigger {} {
global log_time chanlog_exempt
   foreach 1channel [channels] {
      if {![string match *$1channel* [join [split $chanlog_exempt ,] ""]]} {
         set loginfo "[date]:[time]:[split $1channel]:[llength [split [userlist $1channel]]]:[join [split [topic $1channel]]]"
	 putlog "\002\[CHANLOG\]\002] [srange $loginfo 0 end]"
         chanlog_log [srange $loginfo 0 end]
      }
   }
   settimer $log_time chanlog_trigger
}

putlog "chanlog.tcl v$chanlog_ver by leprechau@efnet loaded."