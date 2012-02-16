## example public command scanner
## using my sockScan package
##
## http://woodstock.anbcs.com/scripts/tcl/sockscan.tcl
##
## read comments below..
##
#
namespace eval ::pubScan {

	## initiate the scanner...just let it auto-detect
	::sockScan::init

	## our callback proc...this is where we will do our result processing
	## remember...the callback always appends the token as the last argument
	proc callback {nick chan host port token} {
		## check the status of the token...if it was an error or timeout...just let them know and stop
		switch -exact -- [set status [::sockScan::status $token]] {
			ERROR {putserv "PRIVMSG $chan :Sorry $nick, there was an error checking $host:$port"}
			TIMEOUT {putserv "PRIVMSG $chan :Sorry $nick, connection timeout to $host:$port"}
		}
		## check for OK ... if not...return
		if {![string equal OK $status]} {::sockScan::cleanup $token; return}
		## tell them what we found...
		switch -exact -- [set type [::sockScan::type $token]] {
			4 - 5 {
				## well we got a real socks..let's see if it's open or closed
				switch -exact -- [set anon [::sockScan::anon $token]] {
					0 {putserv "PRIVMSG $chan :Secure Socks v$type found @ $host:$port"}
					1 {putserv "PRIVMSG $chan :Open Socks v$type found @ $host:$port"}
				}
			}
			U {putserv "PRIVMSG $chan :Non-Socks Daemon found @ $host:$port"}
		}
		## cleanup our token and stop...
		::sockScan::cleanup $token; return
	}

	## get info from our users..
	proc pubCmd {nick uhost hand chan text} {
		## split it up...
		foreach {host port} [split [lindex [split $text] 0] {:}] {}
		## do our idiot checks...
		if {![info exists host] || ![string length $host] || ![info exists port] || ![string length $port]} {
			putserv "PRIVMSG $chan :\002Usage\002: $::lastbind host:port"; return
		}
		## pass it off to the scanner along with the vars we want to use later
		::sockScan::scan $host $port -timeout 3 -command [list ::pubScan::callback $nick $chan $host $port]
	}
	bind pub - !scan ::pubScan::pubCmd
}
putlog "public socks scanner example script by leprechau@EFnet loaded!"

## EOF ##
