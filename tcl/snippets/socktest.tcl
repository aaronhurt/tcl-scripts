#!/usr/local/bin/tclsh8.4
#
## test if a socket (ip/port) is open
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
proc sock:timeout {sock} {
global connected
	if {(![info exists connected($sock)]) || ($connected($sock) != 1)} {
		set connected($sock) 0
		close $sock
		puts "Error, Socket($sock) timed out."
	}
}

proc sock:check {sock} {
	uplevel #0 set connected($sock) 1
	if {[eof $sock]} {
		puts "Error, Socket($sock) not connected."
	} else {
		catch {fconfigure $sock -peername} peer
		if {[string match "*not connected*" $peer]} {
			puts "Error, Socket($sock) not connected."
		} else {
			puts "Connected: $peer"
		}
	}
	close $sock
}

proc sock:init {host port} {
	if {[catch {set sock [socket -async $host $port]} sock_error] != 0} {
		puts "Error, $sock_error"
		return
	}
	after 1000 [list sock:check $sock]
	after 10000 [list sock:timeout $sock]
	vwait connected($sock)
}

if {$argc != 2} {
	puts "Error, Usage: $argv0 <host> <port>"
} else {
	sock:init [lindex $argv 0] [lindex $argv 1]
}
