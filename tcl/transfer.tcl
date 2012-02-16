#!/usr/local/bin/tclsh8.4
#
## pure tcl file sender...works with getshell.tcl in this same webspace
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

## settings ##
set AuthKey "9afgEuzFArZtRfoR89y0GRaCo24W5lJI2P56puA6"

## end settings ##

proc file_transfer { fname host port } {
global AuthKey
   puts "Starting transfer of $fname ..."
   set sock [socket $host $port]
	fconfigure $sock -buffering line
   fileevent $sock writable { set connected 1 }
   vwait connected
	puts $sock "+HEADER $AuthKey\:[file tail $fname]"
	fconfigure $sock -buffering none -encoding binary -translation binary
   set startsecs [clock seconds]
	fconfigure [set in [open $fname r]] -buffering none -encoding binary -translation binary
   set bytes "[fcopy $in $sock]"; close $in; close $sock
   set time [expr [clock seconds] - $startsecs]
   if {$time != 0} {
      set speed [expr ($bytes / $time) / 1000.0]
   } else { set speed 0 }
   puts "DONE: transfered $bytes total bytes in $time seconds ($speed Kbps)."
}

file_transfer [lindex [split $argv] 0] [lindex [split $argv] 1] [lindex [split $argv] 2]
