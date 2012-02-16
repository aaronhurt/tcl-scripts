##
## DEPRECATED - NOT MAINTAINED - netsys.com is dead - see secwatch.tcl
## 
##
## script to check/monitor netsys.com rss feeds
## commands: !netsys
## channel flags: .chanset #channel +/-netsys
## to enable/disable announcements and public commands
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::netsys {

	## begin settings ##
	
	variable maxresults 10;
	## maximum results to display on public commands
	variable uinterval 10;
	## update interval in minutes (connection to netsys.com)
	variable messagetarget "nick";
	## public command target (must be "nick" or "chan")
	variable url "http://www.netsys.com/news.rdf"
	## url for netsys.com rss feed

	## end settings ##

	variable data; array set data [list]
	variable data2; array set ndata2 [list]
	variable uinterval2 0

	package require http
	::http::config -useragent {Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)}
	setudef flag netsys

	proc mapEntities {html} {
		return [string map "{&quot;} {\"} {&amp;} {\&} {&lt;} {\<} {&gt;} {\>} {&#39;} {\'}" $html]
	}

	proc callback {token} {
		if {[catch {::http::status $token} status] != 0} {return}
		if {![string equal {ok} $status]} {
			switch -exact -- $status {
				reset {
					putlog "\[\002NETSYS\002\] Connection to server was reset."
				}
				timeout {
					putlog "\[\002NETSYS\002\] Timeout (60 seconds) on connection to server."
				}
				default {
					putlog "\[\002NETSYS\002\] Unknown error occured, server output of the error is as follows: $status"
				}
			}
			::http::cleanup $token; return
		}
		# clean out old arrays
		array unset ::netsys::data2; array set ::netsys::data2 [array get ::netsys::data]; array unset ::netsys::data
		# start the parsing :-)
		set rss {}; foreach line [split [::http::data $token] \n] {append rss [string trim $line]}; ::http::cleanup $token
		foreach {x y title link desc} [regexp -all -inline -- {<item (.+?)><title>(.+?)</title><link>(.+?)</link><description>(.+?)</description></item>} $rss] {
			lappend ::netsys::data(titles) [set title [::netsys::mapEntities $title]]
			lappend ::netsys::data(links) $link
			lappend ::netsys::data(descs) [set desc [::netsys::mapEntities $desc]]
			if {([array size ::netsys::data2] != 0) && ([lsearch -exact $::netsys::data2(links) $link] == -1)} {
				putlog "\[\002NETSYS\002\] \002$title\002 >> $link"
				foreach chan [channels] {
					if {[channel get $chan netsys]} {
						puthelp "PRIVMSG $chan :\[\002NETSYS\002] \002$title\002 >> $link"
					}
				}
			}
		}
	}

	proc getData {minute hour day month year} {
		if {[incr ::netsys::uinterval2] >= $::netsys::uinterval} {
			::http::geturl $::netsys::url -command "::netsys::callback" -timeout 60000
			set ::netsys::uinterval2 0
		}
	}
	bind time - "* * * * *" ::netsys::getData

	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan netsys]} {return}
		if {[string match -nocase {-d*} [lindex [split [set text [string trim $text]]] 0]]} {
			set details 1; set text [lindex [split $text] 1]
		}
		putcmdlog "# $nick@$chan !netsys $text #"
		switch -- $::netsys::messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002NETSYS\002\] Error, unknown messagetarget specified in script!"; return}
		}
		set lineout 0
		foreach title $::netsys::data(titles) link $::netsys::data(links) desc $::netsys::data(descs) {
			if {[info exists details]} {
				if {(![string equal {} $title]) && (![string equal {} $link])} {
					puthelp "PRIVMSG $target :\002$title\002 >> $desc >> $link"
					if {[incr lineout] >= $::netsys::maxresults} {break}
				}
			} else {
				if {(![string equal {} $title]) && (![string equal {} $link])} {
					puthelp "PRIVMSG $target :\002$title\002 >> $link"
					if {[incr lineout] >= $::netsys::maxresults} {break}
				}
			}
		}
	}
	bind pub - !netsys ::netsys::pubCmds
}
package provide netsys 1.0

## start init ##
foreach timer [utimers] {
	if {[string match {::netsys::getData*} [join [lindex $timer 1]]]} {
		killutimer [lindex $timer end]
	}
}
set ::netsys::uinterval2 $::netsys::uinterval; utimer 8 {::netsys::getData - - - - -}
## end init ##

putlog "netsysrss.tcl v1.0 by leprechau@EFNet loaded!"
