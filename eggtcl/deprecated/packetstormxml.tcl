##
## DEPRECATED - NOT MAINTAINED - USE secwatch.tcl
##
## script to check/monitor packetstorm xml feed
## commands: !packetstorm
## channel flags: .chanset #channel +/-packetstorm
## to enable/disable announcements and public commands
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::packetstorm {

	## begin settings ##
	
	variable maxresults 5;
	## maximum results to display on public commands
	variable uinterval 10;
	## update interval in minutes (connection to securitytracker.com)
	variable messagetarget "nick";
	## public command target (must be "nick" or "chan")
	variable desctrim 180;
	## trim descriptions to this many characters for channel announcements (0 disables)
	variable url "http://packetstorm.linuxsecurity.com/whatsnew20.xml"
	## url including your affiliate ID number for the XML feed at securitytracker.com

	## end settings ##

	variable data; array set data [list]
	variable data2; array set data2 [list]
	variable uinterval2 0

	package require http
	::http::config -useragent {Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)}
	setudef flag packetstorm

	proc mapEntities {html} {string map "{&quot;} {\"} {&amp;} {\&} {&lt;} {\<} {&gt;} {\>} {&#39;} {\'}" $html}

	proc wrapit {text {len 80}} {
		if {[string length $text] > $len} {
			set list [split $text]
			set x 0; set y 0
			for {set i 0} {$i <= [llength $list]} {incr i} {
				if {[string length [set tmp [join [lrange $list $x $y]]]] < $len} {
					incr y
				} else {
					lappend outs $tmp; set x [incr y]
				}
			}
			if {[info exists outs]} {return $outs}
		} else {return [list $text]}
	}

	proc callback {token} {
		if {[catch {::http::status $token} status] != 0} {return}
		if {![string equal {ok} $status]} {
			switch -exact -- $status {
				reset {
					putlog "\[\002PACKETSTORM\002\] Connection to server was reset."
				}
				timeout {
					putlog "\[\002PACKETSTORM\002\] Timeout (60 seconds) on connection to server."
				}
				default {
					putlog "\[\002PACKETSTORM\002\] Unknown error occured, server output of the error is as follows: $status"
				}
			}
			::http::cleanup $token; return
		}
		array unset ::packetstorm::data2; array set ::packetstorm::data2 [array get ::packetstorm::data]; array unset ::packetstorm::data
		# start the parsing :-)
		set xml {}; foreach line [split [::http::data $token] \n] {append xml [string trim $line]}; ::http::cleanup $token
		foreach {x title link desc} [regexp -all -inline -- {<item><title>(.+?)</title><link>(.+?)</link><description>(.+?)</description></item>} $xml] {
			lappend ::packetstorm::data(titles) [set title [::packetstorm::mapEntities $title]]
			lappend ::packetstorm::data(links) $link
			lappend ::packetstorm::data(descs) [set desc [::packetstorm::mapEntities $desc]]
			if {([array size ::packetstorm::data2] != 0) && ([lsearch -exact $::packetstorm::data2(links) $link] == -1)} {
				if {($::packetstorm::desctrim != 0) && ([string length $desc] > $::packetstorm::desctrim)} {
					set desc "[string range $desc 0 $::packetstorm::desctrim]..."
				}
				foreach line [::packetstorm::wrapit "\[\002PACKETSTORM\002\] \002$title\002 >> $desc >> \002$link\002" 300] {
					putlog $line;
					foreach chan [channels] {
						if {[channel get $chan packetstorm]} {puthelp "PRIVMSG $chan :$line"}
					}
				}
			}
		}
	}

	proc getData {minute hour day month year} {
		if {[incr ::packetstorm::uinterval2] >= $::packetstorm::uinterval} {
			::http::geturl $::packetstorm::url -command "::packetstorm::callback" -timeout 60000
			set ::packetstorm::uinterval2 0
		}
	}
	bind time - "* * * * *" ::packetstorm::getData

	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan sectrack]} {return}
		putcmdlog "# $nick@$chan !packetstorm #"
		switch -- $::packetstorm::messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002PACKETSTORM\002\] Error, unknown messagetarget specified in script!"; return}
		}
		set lineout 0
		foreach title $::packetstorm::data(titles) link $::packetstorm::data(links) desc $::packetstorm::data(descs) {
			if {(![string equal {} $title]) && (![string equal {} $link]) && (![string equal {} $desc])} {
				foreach line [::packetstorm::wrapit "\002$title\002 >> $desc >> \002$link\002" 300] {
					puthelp "PRIVMSG $target :$line"
				}
			}
		}
	}
	bind pub - !packetstorm ::packetstorm::pubCmds
}
package provide packetstorm 1.0

## start init ##
foreach timer [utimers] {
	if {[string match {::packetstorm::getData*} [join [lindex $timer 1]]]} {
		killutimer [lindex $timer end]
	}
}
set ::packetstorm::uinterval2 $::packetstorm::uinterval; utimer 8 {::packetstorm::getData - - - - -}
## end init ##

putlog "packetstormxml.tcl v1.0 by leprechau@EFNet loaded!"
