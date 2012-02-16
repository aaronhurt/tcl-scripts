##
## DEPRECATED - NOT MAINTAINED - USE secwatch.tcl
##
## script to check and monitor securityfocus.com xml feeds
## commands: !secfocus <vulnerabilities|bugtraq|news|infocus|columns>
## channel flags: .chanset #channel +/- secfocus
## to enable/disable announcements and public commands
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::secfocus {

	## begin settings #

	variable maxresults 10;
	## maximum results to display from public commands
	variable uinterval 10;
	## update interval in minutes (connection to securityfocus.com)
	variable messagetarget "nick";
	## destination target for public commands (nick or chan)

	## end settings ##

	variable urls; array set urls {
		vulns "http://www.securityfocus.com/rss/vulnerabilities.xml"
		news "http://www.securityfocus.com/rss/news.xml"
	}
	variable vdata; array set vdata [list]
	variable vdata2; array set vdata2 [list]
	variable ndata; array set ndata [list]
	variable ndata2; array set ndata2 [list]
	variable uinterval2 0

	package require http
	::http::config -useragent {Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)}
	setudef flag secfocus

	proc mapEntities {html} {
		return [string map "{&quot;} {\"} {&amp;} {\&} {&lt;} {\<} {&gt;} {\>} {&#39;} {\'}" $html]
	}

	proc callback {type token} {
		if {[catch {::http::status $token} status] != 0} {return}
		if {![string equal {ok} $status]} {
			switch -exact -- $status {
				reset {
					putlog "\[\002SECFOCUS\002\] Connection to server was reset."
				}
				timeout {
					putlog "\[\002SECFOCUS\002\] Timeout (60 seconds) on connection to server."
				}
				default {
					putlog "\[\002SECFOCUS\002\] Unknown error occured, server output of the error is as follows: $status"
				}
			}
			::http::cleanup $token; return
		}
		array unset ::secfocus::[set type]2; array set ::secfocus::[set type]2 [array get ::secfocus::[set type]]; array unset ::secfocus::[set type]
		# start the parsing :-)
		set xml {}; foreach line [split [::http::data $token] \n] {append xml [string trim $line]}; ::http::cleanup $token
		set xml [string map {{<![CDATA[} {} {]]>} {} {<pubDate></pubDate>} {<pubDate>NULL</pubDate>}} $xml]
		set regex {<item><title>(.+?)</title><link>(.+?)</link><description>(.+?)</description><pubDate>(.+?)</pubDate></item>}
		set vars {x title link desc pdate}
		foreach [set vars] [regexp -all -inline -- $regex $xml] {
			switch -glob -- [set kword [string tolower [lindex [split $title {:}] 0]]] {
				vul* - bug* - new* - inf* - col* - els* {
					lappend ::secfocus::[set type]([string index $kword 0]titles) [set title [::secfocus::mapEntities $title]]
					lappend ::secfocus::[set type]([string index $kword 0]links) $link
					if {![string equal {} [set tempDesc [lindex [regexp -all -inline -- (.+?)<br/> $desc] 1]]]} {set desc $tempDesc}
					lappend ::secfocus::[set type]([string index $kword 0]descs) [set desc [::secfocus::mapEntities $desc]]
					if {[string equal {NULL} $pdate]} {set pdate [clock format [clock seconds] -format %Y-%m-%d]}
					lappend ::secfocus::[set type]([string index $kword 0]pdates) [set pdate [::secfocus::mapEntities $pdate]]
				}
			}
			if {([array size ::secfocus::[set type]2] != 0) && ([lsearch -exact [set ::secfocus::[set type]2([string index $kword 0]links)] $link] == -1)} {
				switch -glob -- $kword {
					vul* {
						putlog "\[\002SEC-VULN\002\] (\002$pdate\002) \002[join [lrange [split $title {:}] 1 end] {:}]\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan secfocus]} {
								puthelp "PRIVMSG $chan :\[\002SEC-VULN\002] (\002$pdate\002) \002[join [lrange [split $title {:}] 1 end] {:}]\002 >> $link"
							}
						}
					}
					bug* {
						putlog "\[\002SEC-BUG\002\] (\002$pdate\002) \002[join [lrange [split $title {:}] 1 end] {:}]\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan secfocus]} {
								puthelp "PRIVMSG $chan :\[\002SEC-BUG\002] (\002$pdate\002) \002[join [lrange [split $title {:}] 1 end] {:}]\002 >> $link"
							}
						}
					}
					new* - inf* - col* - els* {
						putlog "\[\002SEC-NEWS\002\] (\002$pdate\002) \002[join [lrange [split $title {:}] 1 end] {:}]\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan secfocus]} {
								puthelp "PRIVMSG $chan :\[\002SEC-NEWS\002] (\002$pdate\002) \002[join [lrange [split $title {:}] 1 end] {:}]\002 >> $link"
							}
						}
					}
				}
			}
		}
	}
	proc getData {minute hour day month year} {
		if {[incr ::secfocus::uinterval2] >= $::secfocus::uinterval} {
			foreach url {vulns news} type {vdata ndata} {::http::geturl $::secfocus::urls($url) -command "::secfocus::callback $type" -timeout 60000}
			set ::secfocus::uinterval2 0
		}
	}
	bind time - "* * * * *" ::secfocus::getData

	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan secfocus]} {return}
		if {[string match -nocase {-d*} [lindex [split [set text [string trim $text]]] 0]]} {
			set details 1; set text [lindex [split $text] 1]
		}
		switch -glob -- $text {
			vul* {set type vdata; set kword vulns}
			bug* {set type vdata; set kword bugtraq}
			new* {set type ndata; set kword news}
			inf* {set type ndata; set kword infocus}
			col* {set type ndata; set kword columnists}
			els* {set type ndata; set kword elsewhere}
			default {
				putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !secfocus \[-details\] <vulns|bugtraq|news|infocus|columns|elsewhere>"; return
			}
		}
		putcmdlog "# $nick@$chan !secfocus $text #"
		switch -- $::secfocus::messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002SECFOCUS\002\] Error, unknown messagetarget specified in script!"; return}
		}
		set lineout 0
		foreach title [set ::secfocus::[set type]([string index $kword 0]titles)] link [set ::secfocus::[set type]([string index $kword 0]links)] desc [set ::secfocus::[set type]([string index $kword 0]descs)] pdate [set ::secfocus::[set type]([string index $kword 0]pdates)] {
			if {[info exists details]} {
				if {(![string equal {} $title]) && (![string equal {} $link]) && (![string equal {} $desc]) && (![string equal {} $pdate])} {
					puthelp "PRIVMSG $target :(\002$pdate\002) \002[join [lrange [split [::secfocus::mapEntities $title] {:}] 1 end] {:}]\002 >> $desc >> $link"
					if {[incr lineout] >= $::secfocus::maxresults} {break}
				}
			} else {
				if {(![string equal {} $title]) && (![string equal {} $link])} {
					puthelp "PRIVMSG $target :(\002$pdate\002) \002[join [lrange [split [::secfocus::mapEntities $title] {:}] 1 end] {:}]\002 >> $link"
					if {[incr lineout] >= $::secfocus::maxresults} {break}
				}
			}
		}
	}
	bind pub - !secfocus ::secfocus::pubCmds
}
package provide secfocus 1.0

## start init ##
foreach timer [utimers] {
	if {[string match {::secfocus::getData*} [join [lindex $timer 1]]]} {
		killutimer [lindex $timer end]
	}
}
set ::secfocus::uinterval2 $::secfocus::uinterval; utimer 8 {::secfocus::getData - - - - -}
## end init ##

putlog "secfocusxml.tcl v1.0 by leprechau@EFNet loaded!"
