##
## DEPRECATED - NOT MAINTAINED USE - secwatch.tcl
##
## script to check/monitor securitytracker.com xml feeds
## commands: !sectrack
## channel flags: .chanset #channel +/-sectrack
## to enable/disable announcements and public commands
##
## always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::sectrack {

	## begin settings ##
	
	variable maxresults 10;
	## maximum results to display on public commands
	variable uinterval 10;
	## update interval in minutes (connection to securitytracker.com)
	variable messagetarget "nick";
	## public command target (must be "nick" or "chan")
	variable url "http://news.securitytracker.com/server/affiliate?AFFILIATE_ID_HERE"
	## url including your affiliate ID number for the RSS(04) feed at securitytracker.com

	## end settings ##

	variable data; array set data [list]
	variable data2; array set data2 [list]
	variable uinterval2 0

	package require http
	::http::config -useragent {Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)}
	setudef flag sectrack

	proc mapEntities {html} {
		return [string map "{&quot;} {\"} {&amp;} {\&} {&lt;} {\<} {&gt;} {\>} {&#39;} {\'}" $html]
	}

	proc callback {token} {
		if {[catch {::http::status $token} status] != 0} {return}
		if {![string equal {ok} $status]} {
			switch -exact -- $status {
				reset {
					putlog "\[\002SECTRACK\002\] Connection to server was reset."
				}
				timeout {
					putlog "\[\002SECTRACK\002\] Timeout (60 seconds) on connection to server."
				}
				default {
					putlog "\[\002SECTRACK\002\] Unknown error occured, server output of the error is as follows: $status"
				}
			}
			::http::cleanup $token; return
		}
		array unset ::sectrack::data2; array set ::sectrack::data2 [array get ::sectrack::data]; array unset ::sectrack::data
		# start the parsing :-)
		set xml {}; foreach line [split [::http::data $token] \n] {append xml [string trim $line]}; ::http::cleanup $token
		foreach {x title link} [regexp -all -inline -- {<item><title>([^<]*)</title><link>([^<]*)</link></item>} $xml] {
			lappend ::sectrack::data(titles) [set title [::sectrack::mapEntities $title]]
			lappend ::sectrack::data(links) $link
			if {([array size ::sectrack::data2] != 0) && ([lsearch -exact [set ::sectrack::data2(links)] $link] == -1)} {
				putlog "\[\002SECTRACK\002\] \002$title\002 >> $link"
				foreach chan [channels] {
					if {[channel get $chan sectrack]} {
						puthelp "PRIVMSG $chan :\[\002SECTRACK\002] \002$title\002 >> $link"
					}
				}
			}
		}
	}

	proc getData {minute hour day month year} {
		if {[incr ::sectrack::uinterval2] >= $::sectrack::uinterval} {
			::http::geturl $::sectrack::url -command "::sectrack::callback" -timeout 60000
			set ::sectrack::uinterval2 0
		}
	}
	bind time - "* * * * *" ::sectrack::getData

	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan sectrack]} {return}
		putcmdlog "# $nick@$chan !sectrack #"
		switch -- $::sectrack::messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002SECTRACK\002\] Error, unknown messagetarget specified in script!"; return}
		}
		set lineout 0
		foreach title $::sectrack::data(titles) link $::sectrack::data(links) {
			if {(![string equal {} $title]) && (![string equal {} $link])} {
				puthelp "PRIVMSG $target :\002[::sectrack::mapEntities $title]\002 >> $link"
				if {[incr lineout] >= $::sectrack::maxresults} {break}
			}
		}
	}
	bind pub - !sectrack ::sectrack::pubCmds
}
package provide sectrack 1.0

## start init ##
foreach timer [utimers] {
	if {[string match {::sectrack::getData*} [join [lindex $timer 1]]]} {
		killutimer [lindex $timer end]
	}
}
set ::sectrack::uinterval2 $::sectrack::uinterval; utimer 8 {::sectrack::getData - - - - -}
## end init ##

putlog "sectrackxml.tcl v1.0 by leprechau@EFNet loaded!"
