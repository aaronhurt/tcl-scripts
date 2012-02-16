## first revision..no comments or help yet
##
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::tclman {
	namespace export pubSearch
	variable url "http://www.tcl.tk/man/tcl8.4/TclCmd/contents.htm"
	variable connected; array set connected [list]
	variable data; array set data [list]

	proc timeout {sock} {
	variable connected
		if {(![info exists connected($sock)]) || ($connected($sock) != 1)} {
			set connected($sock) 0; close $sock
			puts "Error, Socket($sock) timed out."
		}
	}

	proc putData {sock {path {}}} {
		fileevent $sock writable {}
		fconfigure $sock -buffering full
		set ::tclman::connected($sock) 1
		if {[string equal {} $path]} { set path / }
		puts $sock "GET $path HTTP/1.0\n\n"; flush $sock
	}

	proc getData {sock} {
	variable data
		if {[eof $sock] || [catch {gets $sock line}]} {
			fileevent $sock readable {}; close $sock
		} else { set data($sock) [split [read $sock] \n] }
	}

	proc fetchData {host port {path {}}} {
	variable data
		set sock [socket -async $host $port]
		set data($sock) {}
		fileevent $sock writable [list ::tclman::putData $sock $path]
		fileevent $sock readable [list ::tclman::getData $sock]
		utimer 10 [list ::tclman::timeout $sock]
		return $sock
	}

	proc pubSearch {nick uhost hand chan text} {
	variable url; variable data
		if {(![channel get $chan tclman]) || (![string equal "[string trim $text {?}]?" $text])} { return }
		set text [lindex [split [string trim $text {?}] { }] 0]
		set host [join [lindex [split [string trimleft $url {http://}] {/}] 0]]
		set path /[join [lrange [split [string trimleft $url {http://}] {/}] 1 end] {/}]
		set page [join [lindex [array get data [set token [::tclman::fetchData $host 80 $path]]] end]]; array unset data $token
		foreach {match link name} [regexp -all -inline {href=\"([^\"]*)\">([^<]*)</a>} [string map {{&nbsp;} {_}} $page]] {
			array set cmds [list $name $link]
		}
		set result [join [lindex [array get cmds [lsearch -exact -inline [array names cmds] $text]] end]]
		if {![string equal {} $result]} {
			putserv "PRIVMSG $chan :\002$text\002 -> [format [string trimright $url {contents.htm}]%s $result]"
		}
	}
	setudef flag tclman
	bind pubm - * ::tclman::pubSearch
}
package provide tclman 0.2

putlog "TCL Manual public search v0.2 by leprechau LOADED!"
