## auto ping script for #pingme@EFNet
##
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::pingme {
	namespace export jping
	variable counter "/home/ahurt/lepster/scripts/misc/pingme.txt"

	setudef flag pingme

	proc inc {} {
	variable counter
		if {[file exists $counter] && ([file size $counter] != 0)} {
			gets [set fid [open $counter r]] count; close $fid
		} else {
			set count 0
		}
		puts [set fid [open $counter w]] [incr count]; close $fid
		return $count
	}

	proc graph {secs} {
		set used [expr {round((round($secs)/60.0)*10)}]
		return "\[[string repeat \# $used][string repeat - [expr {10-$used}]]\]"
	}

	proc reply {nick uhost hand dest keyword text} {
		if {(![string is digit -strict $text]) || ([string equal {} $text])} {return}
		putlog "Sending ping reply to $nick -> [date]@[time]"
		puthelp "PRIVMSG $nick :Your ping to me was: [set secs [expr {abs(($text - abs([clock clicks -milliseconds])))/1000.0}]] seconds [::pingme::graph $secs]"
	}
	bind ctcr - PING ::pingme::reply

	proc jping {nick uhost hand chan} {
		if {(![channel get $chan pingme]) || ([string equal $nick $::botnick])} {return}
		putlog "Pinging $nick on $chan -> [date]@[time]"
		putquick "PRIVMSG $nick :\001PING [expr {abs([clock clicks -milliseconds])}]\001"
		puthelp "TOPIC $chan :Served up [::pingme::inc] pings fresh from the oven to date!"
	}
	bind join - * ::pingme::jping

	proc pubping {nick uhost hand chan text} {
		if {[string match *ping* [lindex [split $text { }] 0]]} {
			::pingme::jping $nick $uhost $hand $chan
		}
	}
	bind pubm - * ::pingme::pubping
}
package provide pingme 0.1

putlog "Pingme.tcl v0.1 by leprechau loaded"
