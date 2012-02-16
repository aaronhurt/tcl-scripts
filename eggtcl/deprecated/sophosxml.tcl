##
## DEPRECATED - NOT MAINTAINED - USE secwatch.tcl
##
## script to check and monitor securityfocus.com xml feeds
## commands: !sophos <vulnerabilities|bugtraq|news|infocus|columns>
## channel flags: .chanset #channel +/- sophos
## to enable/disable announcements and public commands
##
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::sophos {

	## begin settings #

	variable maxresults 10;
	## maximum results to display from public commands
	variable uinterval 10;
	## update interval in minutes (connection to securityfocus.com)
	variable messagetarget "nick";
	## destination target for public commands (nick or chan)

	## end settings ##

	variable urls; array set urls {
		alerts "http://www.sophos.com/virusinfo/infofeed/tenalerts.xml"
		hoaxes "http://www.sophos.com/virusinfo/infofeed/hoax.xml"
	}
	variable adata; array set adata [list]
	variable adata2; array set adata2 [list]
	variable hdata; array set hdata [list]
	variable hdata2; array set hdata2 [list]
	variable uinterval2 0

	package require http
	::http::config -useragent {Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)}
	setudef flag sophos

	proc callback {type token} {
		if {[catch {::http::status $token} status] != 0} {return}
		if {![string equal {ok} $status]} {
			switch -exact -- $status {
				reset {
					putlog "\[\002SOPHOS\002\] Connection to server was reset."
				}
				timeout {
					putlog "\[\002SOPHOS\002\] Timeout (60 seconds) on connection to server."
				}
				default {
					putlog "\[\002SOPHOS\002\] Unknown error occured, server output of the error is as follows: $status"
				}
			}
			::http::cleanup $token; return
		}
		array unset ::sophos::[set type]2; array set ::sophos::[set type]2 [array get ::sophos::[set type]]; array unset ::sophos::[set type]
		# start the parsing :-)
		set xml {}; foreach line [split [::http::data $token] \n] {append xml [string trim $line]}; ::http::cleanup $token
		foreach {x y title link z} [regexp -all -inline -- {<item (.+?)><title>(.+?)</title><link>(.+?)</link>(.+?)</item>} $xml] {
			lappend ::sophos::[set type](titles) $title
			lappend ::sophos::[set type](links) $link
			if {([array size ::sophos::[set type]2] != 0) && ([lsearch -exact [set ::sophos::[set type]2(links)] $link] == -1)} {
				switch -exact -- $type {
					adata {
						putlog "\[\002Sophos Alert\002\] \002$title\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan sophos]} {
								puthelp "PRIVMSG $chan :\[\002Sophos Alert\002] \002$title\002 >> $link"
							}
						}
					}
					hdata {
						putlog "\[\002Sophos Hoax\002\] \002$title\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan sophos]} {
								puthelp "PRIVMSG $chan :\[\002Sophos Hoax\002] \002$title\002 >> $link"
							}
						}
					}
				}
			}
		}
	}

	proc getData {minute hour day month year} {
		if {[incr ::sophos::uinterval2] >= $::sophos::uinterval} {
			foreach url {alerts hoaxes} type {adata hdata} {::http::geturl $::sophos::urls($url) -command "::sophos::callback $type" -timeout 60000}
			set ::sophos::uinterval2 0
		}
	}
	bind time - "* * * * *" ::sophos::getData

	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan sophos]} {return}
		switch -glob -- $text {
			al* {set type adata}
			ho* {set type hdata}
			default {
				putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !sophos <alerts|hoaxes>"; return
			}
		}
		putcmdlog "# $nick@$chan !sophos $text #"
		switch -- $::sophos::messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002SOPHOS\002\] Error, unknown messagetarget specified in script!"; return}
		}
		set lineout 0
		foreach title [set ::sophos::[set type](titles)] link [set ::sophos::[set type](links)] {
			if {(![string equal {} $title]) && (![string equal {} $link])} {
				puthelp "PRIVMSG $target :\002$title\002 >> $link"
				if {[incr lineout] >= $::sophos::maxresults} {break}
			}
		}
	}
	bind pub - !sophos ::sophos::pubCmds
}
package provide sophos 1.0

## start init ##
foreach timer [utimers] {
	if {[string match {::sophos::getData*} [join [lindex $timer 1]]]} {
		killutimer [lindex $timer end]
	}
}
set ::sophos::uinterval2 $::sophos::uinterval; utimer 8 {::sophos::getData - - - - -}
## end init ##

putlog "sophosxml.tcl v1.0 by leprechau@EFNet loaded!"
