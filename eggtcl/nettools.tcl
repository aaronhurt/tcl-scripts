##################################################
## dnslookup via dig and whois lookup           ##
## by leprechau@efnet version 1.0               ##
## Friday, October 27, 2002                     ##
##################################################
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::nettools {
	## default settings for bins should work on almost all systems
	variable dig [lindex [split [exec which dig]] 0]
	variable whois [lindex [split [exec which whois]] 0]

	proc dig {host type args} {
		variable dig; lappend hosts $host
		if {[regexp {^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$} $host]} {
			set arg "-x "; set type "PTR"
		} else {set arg ""}
		if {[catch {set lookup [read [set cid [open "|$dig $arg$host $type" r]]];close $cid} open_error] != 0} {
			return -code error "Error opening command pipe: $open_error"
		}
		foreach {x y} [regexp -inline {ANSWER SECTION\:(.+?)\;\;} $lookup] {continue}
		if {[info exists y]} {set lookup [split [string trim $y] \n]} else {set lookup {}}
		foreach line $lookup {
			switch -- [lindex $line 3] {
				CNAME {set hosts [linsert $hosts 0 [string trimright [lindex $line end] .]]}
				A - PTR {lappend ips [lindex $line end]}
				MX {lappend mxs "[lindex $line end-1] [string trimright [lindex $line end] .]"}
				NS {lappend nss [string trimright [lindex $line end] .]}
				default {continue}
			}
		}
		foreach var {ips mxs nss} {if {![info exists [set var]]} {set [set var] NULL}}
		if {[string equal {-callback} [lindex $args 0]]} {
			switch -- $type {
				A - PTR {[lindex $args 1] $hosts $ips [lrange $args 2 end]}
				MX {[lindex $args 1] $hosts $mxs [lrange $args 2 end]}
				NS {[lindex $args 1] $hosts $nss [lrange $args 2 end]}

			}
		} else {
			switch -- $type {
				A - PTR {return [list $hosts $ips $args]}
				MX {return [list $hosts $mxs $args]}
				NS {return [list $hosts $nss $args]}
			}
		}
	}

	proc whois {host args} {
		variable whois
		if {[catch {set lookup [split [read [set cid [open "|$whois $host" r]]] \n];close $cid} open_error] != 0} {
			return -code error "Error opening command pipe: $open_error"
		}
		if {[string equal {-callback} [lindex $args 0]]} {
			[lindex $args 1] $lookup [lrange $args 2 end]
		} else {
			return [list $lookup $args]
		}
	}
}
package provide nettools 1.0

namespace eval ::dcctools {
	## set our dcc port range...
	variable portMin "4095"
	variable portMax "4100"
	variable cText {}; variable servSock {}
	variable dccSession; array set dccSession [list]

	proc chatInit {client text} {
		variable servSock; variable cText
		if {![info exists ::my-ip]} {return}
		set cText $text
		foreach {a b c d} [split ${::my-ip} .] {}
		set longip [format %u 0x[format %02X%02X%02X%02X $a $b $c $d]]
		set port [expr {int(rand()*($::dcctools::portMax-$::dcctools::portMin+1)+$::dcctools::portMin)}]
		set servSock [socket -myaddr ${::my-ip} -server ::dcctools::chatAccept $port]
		putserv "PRIVMSG $client :\001DCC CHAT $client $longip $port\001"
	}

	proc chatAccept {sock addr port} {
		variable servSock; variable dccSession
		putlog "Accepting DCC CHAT ($sock) connection from $addr:$port"
		close $servSock; set dccSession($sock) [list $addr $port]
		fconfigure $sock -buffering line
		fileevent $sock writable [list ::dcctools::chatSend $sock]
	}

	proc chatSend {sock} {
		variable dccSession; variable cText
		fileevent $sock writable {}
		puts $sock [join $cText \n]
		putlog "Terminating DCC CHAT ($sock) to [join $dccSession($sock) {:}]"; close $sock
	}
}
package provide dcctools 0.1

proc get_dns {hosts ips args} {
	foreach {nick chan} [lindex $args 0] {}
	if {![string equal NULL [join $ips]]} {
		puthelp "PRIVMSG $chan :\[\002DNS\002\] Resolved [join $hosts {, }] to [join $ips {, }]"
	} else {
		puthelp "PRIVMSG $chan :\[\002DNS\002\] Sorry $nick, [string trim [join $hosts] {, }] could not be resolved."
	}
}

proc pub_dns {nick uhost hand chan text} {
	if {[string equal {} $text]} {return}
	if {![onchan [set text [string trim [lindex [split $text] 0]]] $chan]} {
		::nettools::dig $text A -callback get_dns $nick $chan
	} else {
		::nettools::dig [lindex [split [getchanhost $text $chan] @] end] A -callback get_dns $nick $chan
	}
}
bind pub - !dns pub_dns

proc get_mx {hosts mxs args} {
	foreach {nick chan} [lindex $args 0] {}
	if {![string equal NULL [join $mxs]]} {
		puthelp "PRIVMSG $chan :\[\002MX\002\] MX for [join $hosts {, }] listed as [join $mxs {, }]"
	} else {
		puthelp "PRIVMSG $chan :\[\002MX\002\] Sorry $nick, [string trim [join $hosts] {, }] MX records could not be located."
	}
}

proc pub_mx {nick uhost hand chan text} {
	if {[string equal {} $text]} {return}
	::nettools::dig $text MX -callback get_mx $nick $chan
}
bind pub - !mx pub_mx

proc get_ns {hosts nss args} {
	foreach {nick chan} [lindex $args 0] {}
	if {![string equal NULL [join $nss]]} {
		puthelp "PRIVMSG $chan :\[\002NS\002\] NS for [join $hosts {, }] listed as [join $nss {, }]"
	} else {
		puthelp "PRIVMSG $chan :\[\002NS\002\] Sorry $nick, [string trim [join $hosts] {, }] NS records could not be located."
	}
}

proc pub_ns {nick uhost hand chan text} {
	if {[string equal {} $text]} {return}
	::nettools::dig $text NS -callback get_ns $nick $chan
}
bind pub - !ns pub_ns

proc get_whois {lookup args} {
	::dcctools::chatInit [lindex $args 0] $lookup
}

proc pub_whois {nick uhost hand chan text} {
	if {[string equal {} $text]} {return}
	::nettools::whois [string trim [lindex [split $text] 0]] -callback get_whois $nick
}
bind pub - !whois pub_whois

putlog "nettools.tcl v1.0 by leprechau@efnet loaded."
