## simple pure tcl socks scanner
##
## available commands:
##
## ::sockScan::init ?ip? ?hostname?
## ^- initialize the scanner...set the outgoing ip/host
##    this is a REQUIRED...scanning will fail if not set
##    this is only required once per script load
##    example: ::sockScan::init 1.2.3.4 example.test.com
##    if no info passed auto detect will occur
##    for socks4 detection to be accurate...this must be
##    an external ip connectable via tcp 2000-2999
##
## ::sockScan::scan <host> ?port? ?-command command? ?-timeout seconds?
## ^- scan a host/ip for open socks4/5
##    port defaults to 1080 if none passed
##    returns token for later commands
##
## ::sockScan::cleanup <token>
## ^- cleaup the state array and
##    close any outstanding sockets
##
## ::sockScan::status <token>
## ^- returns either: OK or ERROR or TIMEOUT
##    depending on scan status
##
## ::sockScan::type <token>
## ^- returns proxy type
##    return values:
##    4 == socks4
##    5 == socks5
##    U == unknown proxy*
##
## ::sockScan::anon <token>
## ^- check for anonymous proxy
##    return values:
##    1 == anonymous proxy...no auth needed
##    0 == secure proxy...auth needed
##    U == unknown auth method*
##
## ::sockScan::tokens
## ^- returns all currently open tokens
##
##
## * U return type for anon/type means that the scanned ip/port was open and accepted
## a connection but it was NOT a valid socks4/5 proxy...it could be any other daemon such
## such as a web or ftp or ssh daemon
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
#
namespace eval ::sockScan {
	package require Tcl 8.4
	variable version 1.0
	## our state array...everything we store is in here
	## don't overwrite this info if it already exists
	if {(![array exists ::sockScan::STATE]) || (![array size ::sockScan::STATE])} {
		variable STATE; array set STATE [list tokenID 0]
	}
}

## create tokens
proc ::sockScan::gettok {} {
	set token ::sockScan::[incr ::sockScan::STATE(tokenID)]
	foreach {sock port} [::sockScan::doListen] {}
	array set ::sockScan::STATE [list $token,lsock $sock $token,lport $port]; return $token
}

## cleanup arrays
proc ::sockScan::cleanup {token} {
	if {![string length [set status [array get ::sockScan::STATE $token,status]]]} {
		return -code error "Invalid token specified"
	}
	catch {close $::sockScan::STATE($token,lsock)}
	catch {close $::sockScan::STATE($token,sock)}
	catch {array unset ::sockScan::STATE $token,*}
}

## list current tokens
proc ::sockScan::tokens {} {
	if {[llength [set toks [array names ::sockScan::STATE ::sockScan::*]]]} {
		foreach tok $toks {lappend tokens [lindex [split $tok {,}] 0]}
		return [lsort -decreasing -dictionary -unique $tokens]
	} else {return {}}
}


## return status
proc ::sockScan::status {token {text {}}} {
	if {![string length [set status [array get ::sockScan::STATE $token,status]]]} {
		return -code error "Invalid token specified"
	}
	switch -exact -- [string tolower $text] {
		anon {return $::sockScan::STATE($token,anon)}
		type {return $::sockScan::STATE($token,socktp)}
		default {return [lindex $status end]}
	}
}

proc ::sockScan::type {token} {::sockScan::status $token type}

proc ::sockScan::anon {token} {::sockScan::status $token anon}

## handle timeouts
proc ::sockScan::timeout {token} {
	if {([info exists ::sockScan::STATE($token,connected)]) && ($::sockScan::STATE($token,connected) != 1)} {
		set ::sockScan::STATE($token,connected) 0; catch {close $::sockScan::STATE($token,sock)}
		set ::sockScan::STATE($token,done) 1; set ::sockScan::STATE($token,status) TIMEOUT
	}
	## pass it along to our callback if we had one...
	::sockScan::outputIt $token
}

## execute our callback if we had one...
proc ::sockScan::outputIt {token} {
	if {[string length [set cmd [::sockScan::getOpt {-command -timeout} -command $::sockScan::STATE($token,args)] ]]} {
		catch {eval [linsert [set cmd] end $token]}
	}
}

## option fetcher
proc ::sockScan::getOpt {opts key text} {
	## make sure only valid options are passed
	foreach {opt val} $text {
		if {[lsearch -exact $opts $opt] == -1} {
			return -code error "Unknown option '$opt', must be one of: [join $opts {, }]"
		}
	}
	## return selected option
	if {[set index [lsearch -exact $text $key]] != -1} {
		return [lindex $text [expr {$index +1}]]
	} else {return {}}
}

## generate long ips
proc ::sockScan::ip2long {ip} {
	foreach {a b c d} [split $ip .] {}
	return [format %.0f [expr {($a * pow(256,3)) + ($b * pow(256,2)) + ($c * 256) + $d}]]
}

## init the scanner
proc ::sockScan::init {{ip {}} {host {}}} {
	## set our outgoing ip...
	if {![string length $ip]} {
		## little messy...but it gets the job done...
		set ip [lindex [split [fconfigure [set tsock [socket -server none -myaddr [info hostname] 0]] -sockname]] 0]
		catch {close $tsock}; array set ::sockScan::STATE [list myIP $ip]
	} else {array set ::sockScan::STATE [list myIP $ip]}
	## set our outgoing hostname...
	if {![string length $host]} {
		array set ::sockScan::STATE [list myHost [info hostname]]
	} else {array set ::sockScan::STATE [list myHost $host]}
}

## just accept a connection and close
proc ::sockScan::getSocks {sock addr port} { catch {close $sock} }

## open a listening socket
proc ::sockScan::doListen {} {
	for {set x 2000} {$x < 2999} {incr x} {
		if {![catch {set sock [socket -server ::sockScan::getSocks -myaddr $::sockScan::STATE(myHost) $x]}]} {return [list $sock $x]}
	}
}

## handle the sock connection
proc ::sockScan::doWrite {token} {
	## cleanup fileevent
	fileevent $::sockScan::STATE($token,sock) writable {}
	## set connected and cancel timeout...
	array set ::sockScan::STATE [list $token,connected 1]; catch {after cancel $::sockScan::STATE($token,afterid)}
	## check for socket error
	if {[string length [set sockError [fconfigure $::sockScan::STATE($token,sock) -error]]]} {
		array set ::sockScan::STATE [list $token,status ERROR $token,done 1]
		catch {close $::sockScan::STATE($token,sock)}; catch {close $::sockScan::STATE($token,lsock)}
		## do our callback if we have one...
		::sockScan::outputIt $token; return
	}
	## yes...we are connected...send data...
	if {$sockScan::STATE($token,sv4) == 1} {
		set data "[binary format ccSI 4 1 $::sockScan::STATE($token,lport) [::sockScan::ip2long $::sockScan::STATE(myIP)]]$::env(USER)[binary format c 0]"
	} else {
		set data "[binary format ccc 5 1 0]"
	}
	if {[catch {puts $::sockScan::STATE($token,sock) $data}]} {
		## well that didn't work...let's mark it errord and stop
		array set ::sockScan::STATE [list $token,status ERROR $token,done 1]
		catch {close $::sockScan::STATE($token,sock)}; catch {close $::sockScan::STATE($token,lsock)}
		## do our callback if we have one...
		::sockScan::outputIt $token; return
	}
}

## handle replies
proc ::sockScan::getRead {token} {
	## cleanup fileevent and mark this token done...stop update loop
	fileevent $::sockScan::STATE($token,sock) readable {}; array set ::sockScan::STATE [list $token,done 1]
	## check for socket error
	if {[string length [set sockError [fconfigure $::sockScan::STATE($token,sock) -error]]]} {
		array set ::sockScan::STATE [list $token,status ERROR $token,done 1]
		catch {close $::sockScan::STATE($token,sock)}; catch {close $::sockScan::STATE($token,lsock)}
		## do our callback if we had one...
		::sockScan::outputIt $token; return
	}
	## weee...we got a response...read first 2 bytes of reply and close our socket...we are done with it
	catch {binary scan [read $::sockScan::STATE($token,sock) 2] cc reply reply2}; catch {close $::sockScan::STATE($token,sock)}
	## check our reply
	if {([info exists reply] && [info exists reply2])} {
		if {$reply == 0} {set reply 4}
		## check for 4 vs 5
		if {$reply == 4 || $reply == 5} {
			## socks4? ... let's connect and see
			if {$reply == 4 && $reply2 == 91} {
				## check for socks4 specific once...
				if {$sockScan::STATE($token,sv4) == 0} {
					array set ::sockScan::STATE [list $token,sv4 1]
					::sockScan::scanIt $::sockScan::STATE($token,host) $::sockScan::STATE($token,port) $token; return
				}
			}
			## looks like an anon proxy... (90 = sock4, 0 = sock5)
			if {($reply == 4 && $reply2 == 90 || $reply == 5 && $reply2 == 0)} {
				set anon 1; ## anon socks found
			} else {set anon 0; ## well...it's a socks...but it wants authentication}
		## who knows what the hell this is...
		} else {set reply U; set anon U}
		## save it in our state array
		array set ::sockScan::STATE [list $token,socktp $reply $token,anon $anon]
	} else {array set ::sockScan::STATE [list $token,status ERROR]}
	## okay...done scanning let's close our listening socket for socks4
	catch {close $::sockScan::STATE($token,lsock)}
	## do our callback if we have one
	::sockScan::outputIt $token
}

## the heart of it all...this is what gets it all rolling
proc ::sockScan::scanIt {host {port {1080}} {token {}}} {
	if {[catch {socket -async $host $port} sock] != 0} {
		catch {close $sock}; array set ::sockScan::STATE [list $token,status ERROR $token,done 1]
		## do our callback if we got one...
		::sockScan::outputIt $token; return
	}
	fconfigure $sock -translation binary -buffering none -blocking off
	## record our sockid to the state array
	array set ::sockScan::STATE [list $token,sock $sock]
	## setup our fileevents
	fileevent $sock writable [list ::sockScan::doWrite $token]
	fileevent $sock readable [list ::sockScan::getRead $token]
}

## just a little wrapper to the beast above...makes error messages more readable
proc ::sockScan::scan {host {port {}} args} {
	## create a token...
	set token [::sockScan::gettok]
	## populate our state array with some important info...
	array set ::sockScan::STATE [list $token,host $host $token,port $port $token,args $args $token,sv4 0]
	## check if we got a timeout argument
	if {[string length [set to [::sockScan::getOpt {-command -timeout} -timeout $args]]]} {
		array set ::sockScan::STATE [list $token,afterid [after [expr {$to * 1000}] ::sockScan::timeout $token]]
	} else {
		## default to 15 second timeout
		array set ::sockScan::STATE [list $token,afterid [after 15000 ::sockScan::timeout $token]]
	}
	## set our socket status variables
	array set ::sockScan::STATE [list $token,connected 0 $token,done 0 $token,status OK]
	## start the scanner
	::sockScan::scanIt $host $port $token
	## keep event loop updated untill connect (only run if we are not in eggdrop)
	if {[lsearch -exact [info commands] *dcc:dccstat] == -1} {
		while {([info exists :::sockScan::STATE($token,done)]) && ($::sockScan::STATE($token,done) == 0)} {
			## conserve cpu...pause for 1/100th of a second between updates
			update; after 10
		}
	}
	## return our token
	return $token
}
package provide sockscan $::sockScan::version
