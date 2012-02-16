#!/usr/local/bin/tclsh8.4
#
## message sending client by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

## settings ##
set AuthKey "9afgEuzFArZtRfoR89y0GRaCo24W5lJI2P56puA6"

## end settings ##

proc timeout {sock nfo} {
global connected
	if {(![info exists connected($sock,$nfo)]) || ($connected($sock,$nfo) != 1)} {
		set connected($sock,nfo) 0
		catch { fileevent $sock readable {} }
		close $sock
		puts "Error, Socket($sock) ($nfo) timed out."
	}
}

proc send_message { host port dest text } {
global AuthKey connected
	puts "Sending '$text' to '$dest' ..."
	set sock [socket $host $port]
	fileevent $sock writable { set connected($sock,$port) 1 }
	after 3000 [list timeout $sock $port]
	vwait connected
	fconfigure $sock -buffering line
	puts $sock "+HEADER $AuthKey\:$dest"
	puts $sock "+MESSAGE $text"
	puts $sock "EOF"
	puts "DONE: Message sent to '$dest' successfully."
}

send_message [lindex $argv 0] [lindex $argv 1] [lindex $argv 2] [lindex $argv 3]
