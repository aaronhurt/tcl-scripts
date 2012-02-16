#!/usr/local/bin/tclsh8.4

proc bgerror {text} {::hordePasswd::writeLog "Error: $text -> $::errorInfo"; exit 1}

namespace eval ::hordePasswd {

	## simple settings
	variable pFile "hordepasswd.pid"
	variable myIP "216.153.18.132"
	variable lPort "6481"
	variable aKey "e7888ac34e5574bd39db72a6a57398ec2bffa57f622bda7546f3ec31351acd22"
	variable ipRestrict "1"
	variable ipList {127.*.*.* 216.153.18.133}
	variable vpopBins "/usr/local/vpopmail/bin"
	variable logFile "/var/log/hordepasswd.log"
	## end settings

	variable servSock {}
	variable Session; array set Session [list]
	variable version "numver 0001 hver 0.01"
	## we need this alot later on...
	package require base64

	if {[file exists $pFile]} {
		catch {set ppid [gets [set fid [open $pFile r]]]; close $fid}
		if {([info exists ppid]) && ([catch {set pslist "[exec ps -p $ppid]"} execError] == 0)} {
			puts "\nError: Already running? (pid: $ppid)"
			puts "\tIf not, please remove pidfile '$pFile' and restart server.\n\n"; exit 0
		}
	}

	proc timeStamp {} {clock format [clock seconds] -format "%a %b %d %H:%M:%S %Z %Y"}

	proc writeLog {text} {
			catch {puts [set fid [open $::hordePasswd::logFile a+ 0600]] "[::hordePasswd::timeStamp] -> $text"; close $fid}
	}

	proc closeSock {sock} {
		catch {close $sock}; catch {unset ::hordePasswd::Session(addr,$sock)}
	}

	proc sendString {sock key {text {NULL}}} {
		if {[catch {puts $sock "$key [join [split [::base64::encode $text] \n] {}]"} pError] != 0} {
			::hordePasswd::writeLog "Error: closing socket $sock -> $pError"; ::hordePasswd::closeSock $sock
		}
	}

	proc initServer {} {
		if {[string length $::hordePasswd::myIP]} {
			set ::hordePasswd::servSock [socket -server ::hordePasswd::serverCon -myaddr $::hordePasswd::myIP $::hordePasswd::lPort]
		} else {set ::hordePasswd::servSock [socket -server ::hordePasswd::serverCon $::hordePasswd::lPort]}
		catch {puts [set fid [open $::hordePasswd::pFile w]] [pid]; close $fid}
		::hordePasswd::writeLog "Server socket ($::hordePasswd::servSock) opened at"
		vwait forever
	}

	proc conGreet {sock} {
		fileevent $sock writable {}; set ::hordePasswd::Session(seq,$sock) "+0"
		::hordePasswd::sendString $sock +SENDAUTH "Horde password server $::hordePasswd::version"; flush $sock
	}

	proc authHandler {sock text} {
		if {![string equal {+0} $::hordePasswd::Session(seq,$sock)]} {
			::hordePasswd::writeLog "Error: Client $::hordePasswd::Session(addr,$sock) sent out of sequence...closing socket ($sock)."
			::hordePasswd::closeSock $sock; return
		}
		foreach {key script} [split $text {|}] {}
		if {![string equal $::hordePasswd::aKey $key]} {set errMsg "Invalid authkey passed...access denied."}
		if {![string equal $::hordePasswd::rScript $script]} {set errMsg "Invalid script location...access denied."}
		if {![info exists errMsg]} {
			::hordePasswd::sendString $sock +AUTHOK; set ::hordePasswd::Session(seq,$sock) "+1"
		} else {
			::hordePasswd::writeLog "Error: Closing client $::hordePasswd::Session(addr,$sock) -> $errMsg"
			::hordePasswd::sendString $sock -AUTHOK $errMsg; ::hordePasswd::closeSock $sock
		}
	}

	proc passHandler {sock text} {
		if {![string equal {+1} $::hordePasswd::Session(seq,$sock)]} {
			::hordePasswd::writeLog "Error: Client $::hordePasswd::Session(addr,$sock) sent out of sequence...closing socket ($sock)."
			::hordePasswd::closeSock $sock; return
		}
		foreach {uname opass npass} [split $text] {}
		if {![string equal $::hordePasswd::aKey $key]} {set errMsg "Invalid authkey passed...access denied."}
		if {![string equal $::hordePasswd::rScript $script]} {set errMsg "Invalid script location...access denied."}
		if {![info exists errMsg]} {
			::hordePasswd::sendString $sock +PASSOK; set ::hordePasswd::Session(seq,$sock) "+2"
		} else {
			::hordePasswd::writeLog "Error: Closing client $::hordePasswd::Session(addr,$sock) -> $errMsg"
			::hordePasswd::sendString $sock -PASSOK $errMsg; ::hordePasswd::closeSock $sock
		}
	}

	proc changeHandler {sock text} {
		if {![string equal {+2} $::hordePasswd::Session(seq,$sock)]} {
			::hordePasswd::writeLog "Error: Client $::hordePasswd::Session(addr,$sock) sent out of sequence...closing socket ($sock)."
			::hordePasswd::closeSock $sock; return
		}
		::hordePasswd::sendString $sock +CHANGEOK; ::hordePasswd::closeSock $sock
	}

	proc conHandler {sock} {
		if {[eof $sock] || [catch {gets $sock} line]} {
			::hordePasswd::writeLog "Closing $sock -> $::hordePasswd::Session(addr,$sock)"; ::hordePasswd::closeSock $sock; return
		}
		if {![info exists line]} {return}; set kWord [lindex [split $line] 0]; set cMsg [::base64::decode [lindex [split $line] 1]] 
		switch -exact -- $kWord {
			+AUTHINFO {::hordePasswd::authHandler $sock $cMsg}
			+PASSINFO {::hordePasswd::passHandler $sock $cMsg}
			+CHANGEPASS {::hordePasswd::changeHandler $sock $cMsg}
		}
	}

	proc serverCon {sock addr cport} {
		set ::hordePasswd::Session(addr,$sock) $addr\:$cport; set allowConnect 0
		fconfigure $sock -blocking no -buffering line -buffersize 1024
		if {$::hordePasswd::ipRestrict} {
			foreach ip $::hordePasswd::ipList {
				if {[string match "$ip" "$addr"]} {set allowConnect 1}
			}
		} else {set allowConnect 1}
		if {$allowConnect != 1} {
			::hordePasswd::closeSock $sock; ::hordePasswd::writeLog "Closed unauthorized connect ($sock) from $addr\:$cport"
		} else {
			writeLog "Accept connection ($sock) from $addr\:$cport"
			fileevent $sock writable [list ::hordePasswd::conGreet $sock]
			fileevent $sock readable [list ::hordePasswd::conHandler $sock]
		}
	}	
}
::hordePasswd::initServer
