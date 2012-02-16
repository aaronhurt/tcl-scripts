##
## DEPRECATED - NOT MAINTAINED - USE secwatch.tcl
##
## script to check and monitor insecure.org lists via rss feeds
## provided by http://www.djeaux.com/rss
## commands: !insecure <fulldisclosure|vulnwatch|news>
## channel flags: .chanset #channel +/- insecure
## to enable/disable announcements and public commands
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::insecure {

	## begin settings #

	variable maxresults 10;
	## maximum results to display from public commands
	variable uinterval 10;
	## update interval in minutes (connection to djeaux.com)
	variable messagetarget "nick";
	## destination target for public commands (nick or chan)
	variable filterreps 1;
	## do not post reply messages (0 == no 1 == yes)

	## end settings ##

	variable urls; array set urls {
		fd "http://www.djeaux.com/rss/insecure-fulldisclosure.rss"
		vw "http://www.djeaux.com/rss/insecure-vulnwatch.rss"
		sn "http://djeaux.com/rss/insecure-isn.rss"
	}
	variable fdata; array set fdata [list]
	variable fdata2; array set fdata2 [list]
	variable vdata; array set vdata [list]
	variable vdata2; array set vdata2 [list]
	variable ndata; array set ndata [list]
	variable ndata2; array set ndata2 [list]
	variable uinterval2 0

	package require http
	::http::config -useragent {Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)}
	setudef flag insecure

	proc mapEntities {html} {
		return [string map "{&quot;} {\"} {&amp;} {\&} {&lt;} {\<} {&gt;} {\>} {&#39;} {\'}" $html]
	}
	
	proc callback {type token} {
		if {[catch {::http::status $token} status] != 0} {return}
		if {![string equal {ok} $status]} {
			switch -exact -- $status {
				reset {
					putlog "\[\002INSECURE\002\] Connection to server was reset."
				}
				timeout {
					putlog "\[\002INSECURE\002\] Timeout (60 seconds) on connection to server."
				}
				default {
					putlog "\[\002INSECURE\002\] Unknown error occured, server output of the error is as follows: $status"
				}
			}
			::http::cleanup $token; return
		}
		array unset ::insecure::[set type]2; array set ::insecure::[set type]2 [array get ::insecure::[set type]]; array unset ::insecure::[set type]
		# start the parsing :-)
		set xml {}; foreach line [split [::http::data $token] \n] {append xml [string trim $line]}; ::http::cleanup $token
		foreach {x title link desc} [regexp -all -inline -- {<item><title>([^<]*)</title><link>([^<]*)</link><description>([^<]*)</description></item>} $xml] {
			lappend ::insecure::[set type](titles) [set title [::insecure::mapEntities $title]]
			lappend ::insecure::[set type](links) $link
			lappend ::insecure::[set type](descs) [set desc [::insecure::mapEntities $desc]]
			## is message a reply...if so and we are filtering them, let's stop here
			if {($::insecure::filterreps == 1) && ([string match -nocase {re:*} [lindex [split $title] 0]])} {continue}
			if {([array size ::insecure::[set type]2] != 0) && ([lsearch -exact [set ::insecure::[set type]2(links)] $link] == -1)} {
				switch -- $type {
					fdata {
						putlog "\[\002INSECURE-FULL DISCLOSURE\002\] \002$title\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan insecure]} {
								puthelp "PRIVMSG $chan :\[\002INSECURE-FULL DISCLOSURE\002] \002$title\002 >> $link"
							}
						}
					}
					vdata {
						putlog "\[\002INSECURE-VULNWATCH\002\] \002$title\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan insecure]} {
								puthelp "PRIVMSG $chan :\[\002INSECURE-VULNWATCH\002] \002$title\002 >> $link"
							}
						}
					}
					ndata {
						putlog "\[\002INSECURE-SECURITY NEWS\002\] \002$title\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan insecure]} {
								puthelp "PRIVMSG $chan :\[\002INSECURE-SECURITY NEWS\002] \002$title\002 >> $link"
							}
						}
					}
				}
			}
		}
	}

	proc getData {minute hour day month year} {
		if {[incr ::insecure::uinterval2] >= $::insecure::uinterval} {
			foreach url {fd vw sn} type {fdata vdata ndata} {::http::geturl $::insecure::urls($url) -command "::insecure::callback $type" -timeout 60000}
			set ::insecure::uinterval2 0
		}
	}
	bind time - "* * * * *" ::insecure::getData

	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan insecure]} {return}
		switch -glob -- $text {
			ful* {set type fdata}
			vul* {set type vdata}
			new* {set type ndata}
			default {
				putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !insecure <fulldisclosure|vulnwatch|news>"; return
			}
		}
		putcmdlog "# $nick@$chan !insecure $text #"
		switch -- $::insecure::messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002INSECURE\002\] Error, unknown messagetarget specified in script!"; return}
		}
		set lineout 0
		foreach title [set ::insecure::[set type](titles)] link [set ::insecure::[set type](links)] desc [set ::insecure::[set type](descs)] {
			if {(![string equal {} $title]) && (![string equal {} $link]) && (![string equal {} $desc])} {
				puthelp "PRIVMSG $target :\002$title\002 >> $desc >> $link"
				if {[incr lineout] >= $::insecure::maxresults} {break}
			}
		}
	}
	bind pub - !insecure ::insecure::pubCmds
}
package provide insecure 1.0

## start init ##
foreach timer [utimers] {
	if {[string match {::insecure::getData*} [join [lindex $timer 1]]]} {
		killutimer [lindex $timer end]
	}
}
set ::insecure::uinterval2 $::insecure::uinterval; utimer 8 {::insecure::getData - - - - -}
## end init ##

putlog "insecurexml.tcl v1.0 by leprechau@EFNet loaded!"
