#!/usr/local/bin/tclsh8.4

proc bgerror {text} {puts "ERROR: $text"; exit 1}

namespace eval ::hordePasswd {
	## some simple settings
	variable rHost "mail.kiddinc.com:6481"
	variable aKey "e7888ac34e5574bd39db72a6a57398ec2bffa57f622bda7546f3ec31351acd22"
	variable myIP "216.153.18.133"
	## end settings

	## we use this alot
	package require base64

	## connect array for timeouts
	variable connected; array set connected [list]
	## end of cycle variable
	variable done; array set done [list]

	## socket close proc
	proc closeSock {sock}  {
		catch {close $sock}
	}

	## simple timeout proc
	proc timeout {sock} {
		fileevent $sock writable {}
		if {(![info exists ::hordePasswd::connected($sock)]) || ($::hordePasswd::connected($sock) != 1)} {
			puts "Error, Socket($sock) timed out."; ::hordePasswd::closeSock $sock
		}
	}

	## get input form stdin
	proc getInput {} {
		while {![eof stdin]} {
			if {[string length [gets stdin line]]} {lappend input $line}
		}
		## $input = username oldpass newpass
		::hordePasswd::openSock $input
	}

	## get info from server
	proc getOutput {input sock} {
		set ::hordePasswd::connected($sock) 1
		if {[eof $sock] || [catch {gets $sock} line]} {::hordePasswd::closeSock $sock; set ::hordePasswd::done($sock) 1}
		set servText [::base64::decode [join [lrange [split $line] 1 end]]]
		switch -exact -- [lindex [split $line] 0] {
			+SENDAUTH {::hordePasswd::sendString +0 $::hordePasswd::aKey|$::argv0 $sock}
			+AUTHOK {::hordePasswd::sendString +1 $input $sock}
			-AUTHOK {::hordePasswd::closeSock $sock; return -code error $servText}
			+PASSOK {::hordePasswd::sendString +2 DATA_OK_DO_PASS_CHANGE $sock}
			-PASSOK {::hordePasswd::closeSock $sock; return -code error $servText}
			+CHANGEOK {::hordePasswd::closeSock $sock; puts $servText}
			-CHANGEOK {::hordePasswd::closeSock $sock; return -code error $servText}
			default {::hordePasswd::closeSock $sock; set ::hordePasswd::done($sock) 1}
		}
	}

	## open the socket and start the process
	proc openSock {input} {
		foreach {host port} [split $::hordePasswd::rHost {:}] {}
		set sock [socket -async -myaddr $::hordePasswd::myIP $host $port]
		fconfigure $sock -blocking no -buffering line -buffersize 1024
		fileevent $sock readable [list ::hordePasswd::getOutput $input $sock]
		set ::hordePasswd::connected($sock) 0; after 10000 [list ::hordePasswd::timeout $sock];
		vwait ::hordePasswd::done($sock)
	}

	## send the info to remote server when ready
	proc sendString {state input sock} {
		set input [join [split [::base64::encode $input] \n] {}]
		switch -exact -- $state {
			+0 {set outs "+AUTHINFO $input"}
			+1 {set outs "+PASSINFO $input"}
			+2 {set outs "+CHANGEPASS $input"}
		}
		if {[catch {puts $sock $outs} pError] != 0} {
			::hordePasswd::closeSock $sock; return -code error "Could not write to remote socket: $pError"
		}
	}
}
## start the script...
::hordePasswd::getInput
