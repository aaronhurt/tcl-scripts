## script to check/monitor wikipedia for users needing help
## commands: !helpme
## channel flags: .chanset #channel +/-wikihelp
## to enable/disable announcements and public commands
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::wikihelp {

	## begin settings ##

	variable uinterval 2;
	## update interval in minutes (connection to wikipedia)
	variable messagetarget "chan";
	## public command target (must be "nick" or "chan")
	variable url "http://en.wikipedia.org/w/query.php?format=xml&nousage=yes&what=category&cptitle=Wikipedians%20looking%20for%20help"
	## url for wikipedia to query

	## end settings ##

	## setup our data array and init our timer tracker
	variable data; array set data [list]; variable uinterval2 0

	## use my http package...
	## available at:  http://woodstock.anbcs.com/scripts/tcl/
	package require lephttp
	## make us look like IE...
	::lephttp::config -useragent {Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)}
	## set our control flag
	setudef flag wikihelp

	## our callback handler
	proc callback {token} {
		if {[catch {::lephttp::status $token} status] != 0} {return}
		if {![string equal -nocase {ok} $status]} {
			switch -exact -- $status {
				timeout {
					putlog "\[\002WikiHelp\002\] Timeout (60 seconds) on connection to server."
				}
				default {
					putlog "\[\002WikiHelp\002\] Unknown error occured, server output of the error is as follows: $status"
				}
			}
			::lephttp::cleanup $token; return
		}
		# cleanup our old array...
		array unset ::wikihelp::data; array set ::wikihelp::data [list]
		# get our data...
		set xml [::lephttp::data $token]; ::lephttp::cleanup $token
		## check for empty result...and start parsing...
		if {[string match *emptyresult* $xml]} {return}
		## well...it's not empty...go ahead and get our data...
		foreach {x title} [regexp -all -inline -- {<title>(.+?)</title>} $xml] {
			switch -glob -- [string tolower [set title [::lephttp::map $title]]] {
				{user talk:*} {set title "\[\[$title\]\]\*"}
				{user:*} {set title "\[\[$title\]\] \(\[\[User talk:[lindex [split [lindex [split $title {:}] 1] {/}] 0]\]\]\)"}
			}; lappend ::wikihelp::data(titles) $title
		}
		foreach chan [channels] {
			if {[channel get $chan wikihelp]} {puthelp "PRIVMSG $chan :\[WikiHelp\] User(s) needing help\: [join $::wikihelp::data(titles) { | }]"}
		}
	}

	## the proc on the timer loop...
	proc getData {minute hour day month year} {
		if {[incr ::wikihelp::uinterval2] >= $::wikihelp::uinterval} {
			::lephttp::geturl $::wikihelp::url -command ::wikihelp::callback -timeout 60000
			set ::wikihelp::uinterval2 0
		}
	}
	bind time - "* * * * *" ::wikihelp::getData

	## our public command handler
	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan wikihelp]} {return}
		putcmdlog "# $nick@$chan !wikihelp $text #"
		switch -glob -- $::wikihelp::messagetarget {
			n* - N* {set target $nick}
			c* - C* {set target $chan}
			default {putlog "\[\002WikiHelp\002\] Error, unknown messagetarget specified in script!"; return}
		}
		## check array size...if there is nothing there then we should let them know and stop
		if {![llength [array get ::wikihelp::data titles]]} {puthelp "PRIVMSG $target :\[WikiHelp\] There are no users currently looking for help."; return}
		## go ahead and show what we have...
		puthelp "PRIVMSG $target :\[WikiHelp\] User(s) needing help\: [join $::wikihelp::data(titles) { | }]"
	}
	bind pub - !helpme ::wikihelp::pubCmds
}
package provide wikihelp 0.1

## start init ##
foreach timer [utimers] {
	if {[string match {::wikihelp::getData*} [join [lindex $timer 1]]]} {
		killutimer [lindex $timer end]
	}
}
set ::wikihelp::uinterval2 $::wikihelp::uinterval; utimer 8 {::wikihelp::getData - - - - -}
## end init ##

putlog "wikihelp.tcl v0.1 by leprechau@EFNet loaded!"
