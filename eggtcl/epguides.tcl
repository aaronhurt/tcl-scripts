## tv episode lookup script
## fetch episode information from http://epguides.com/
## no documentation or support other than provided herein
## 
## by leprechau@EFnet
##
## channel settings: .chanset #chan +/-epguides
## ^-- toggle public commands per channel
##
## public commands: !ep show name
##
## NOTE: This script uses my http package
## http://woodstock.anbcs.com/scripts/lephttp.tcl
## download and source before this script
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::epguides {
	
	## begin settings ##

	variable messagetarget "chan";
	## target for messages on pub commands (nick or chan)

	## end settings ##
	variable version 0.5

	## get my http package from
	## http://woodstock.anbcs.com/scripts/lephttp.tcl
	package require lephttp
	
	## defines
	setudef flag epguides

	## our callback handler
	proc callback {utext target token} {
		if {[catch {::lephttp::status $token} status] != 0} {return}
		if {![string equal -nocase {OK} $status]} {
			switch -exact -- [string tolower $status] {
				timeout {
					putlog "\[\002EPGUIDES\002\] Timeout (60 seconds) on connection to server."
					putserv "PRIVMSG $target :\[\002ERROR\002\] Timeout (60 seconds) on connection to server."
				}
				"not found" {
					putserv "PRIVMSG $target :Sorry, nothing found for: $utext"
				}
				default {
					putlog "\[\002EPGUIDES\002\] Unknown error occured, server output of the error is as follows: $status"
					putserv "PRIVMSG $target :\[\002ERROR\002\] Unknown error occured."
				}
			}
			::lephttp::cleanup $token; return
		}
		set outs [::lephttp::data $token]; ::lephttp::cleanup $token
		set wtitle [string trim [lindex [regexp -all -nocase -inline -- {<title>(.+?)</title>} $outs] end]]
		set wtitle [string map [subst {"a Titles and Air Dates Guide" "http://epguides.com/[join [string tolower $utext] {}]/"}] \
		[::lephttp::map $wtitle]]
		regsub -all -- {^.*<pre>} $outs {} outs
		regsub -all -- {</pre>.*$} $outs {} outs
		set today [clock scan [clock format [clock seconds] -format {%d %b %y}]]
		foreach line [split $outs \n] {
			if {![regexp {[0-9]+\.} $line]} {continue}
			if {![string length [set date [lindex [regexp -all -inline {([0-9]+) ([A-Z][a-z]+) ([0-9]+)} $line] 0]]]} {continue}
			## clean up extra spaces...ugly..but it works :(
			while {[string match {*  *} $line]} {set line [string map {{  } { }} $line]}
			## continue on...
			regsub -all -- {([0-9]+)- } $line {\1-} line; set line [string trim $line]
			if {[set dtag [clock scan $date]] <= $today} {
				set latest "$dtag [list [lindex [split $line] 0] [lindex [split $line] 1] [lindex [regexp -all -inline {<a(.+?)>(.+?)</a>} $line] 2]]"
			}
			if {$dtag > $today} {
				lappend next $dtag [lindex [split $line] 0] [lindex [split $line] 1] [lindex [regexp -all -inline {<a(.+?)>(.+?)</a>} $line] 2]
			}
		}
		if {[info exists wtitle]} {
			putserv "PRIVMSG $target :\002$wtitle\002"
		} else {
			putserv "PRIVMSG $target :\002Unknown Series Title\002 \(http://epguides.com/[join [string tolower $utext] {}]/\)"
		}
		if {[info exists latest]} {
			foreach {dtag ep se title} $latest {
				putserv "PRIVMSG $target :\002Latest:\002 #[string trimright $ep {.}] - S[string map {- E} $se] - \
				[clock format $dtag -format {%d %b %y}] - [::lephttp::map $title]"
			}
		} else {
			putserv "PRIVMSG $target :\002Latest:\002 No episode found!"
		}
		if {[info exists next]} {
			foreach {dtag ep se title} $next {
				if {![info exists ltag]} {
					putserv "PRIVMSG $target :\002Next:\002 #[string trimright $ep {.}] - S[string map {- E} $se] - \
					[clock format $dtag -format {%d %b %y}] - [::lephttp::map $title]"; set ltag $dtag
				} elseif {([info exists ltag]) && ($dtag == $ltag)} {
					putserv "PRIVMSG $target :\002Next:\002 #[string trimright $ep {.}] - S[string map {- E} $se] - \
					[clock format $dtag -format {%d %b %y}] - [::lephttp::map $title]"; set ltag $dtag
				}
			}
		} else {
			putserv "PRIVMSG $target :\002Next:\002 No episode found!"
		}
	}

	## public commands handler
	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan epguides]} {return}
		if {[string equal {} [set ep [join [string trim $text] {}]]]} {
			putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !ep <series name>"; return
		}
		switch -exact -- $::epguides::messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002EPGUIDES\002\] Error, unknown messagetarget specified in script!"; return}
		}
		::lephttp::fetch http://epguides.com/$ep/ -command [list ::epguides::callback $text $target] -timeout 60000
	}
	bind pub - !ep ::epguides::pubCmds
}
##package provide epguides $::epguides::version

putlog "epguides.tcl v$::epguides::version by leprechau@EFNet loaded!"
