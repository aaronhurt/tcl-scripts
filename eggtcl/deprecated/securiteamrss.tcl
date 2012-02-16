##
## DEPRECATED - NOT MAINTAINED - USE secwatch.tcl
##
## script to check/monitor securiteam.com rss feeds
## commands: !securiteam
## channel flags: .chanset #channel +/-securiteam
## to enable/disable announcements and public commands
## 
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::securiteam {

	## begin settings ##
	
	variable maxresults 10;
	## maximum results to display on public commands
	variable uinterval 10;
	## update interval in minutes (connection to securiteam.com)
	variable messagetarget "nick";
	## public command target (must be "nick" or "chan")
	variable url "http://www.securiteam.com/securiteam.rss"
	## url for securiteam.com rss feed

	## end settings ##

	variable data; array set data [list]
	variable data2; array set ndata2 [list]
	variable uinterval2 0

	package require http
	::http::config -useragent {Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)}
	setudef flag securiteam

	proc mapEntities {html} {
		return [string map "{&quot;} {\"} {&amp;} {\&} {&lt;} {\<} {&gt;} {\>} {&#39;} {\'}" $html]
	}
	proc unhtml {text} {regsub -all -- {(<.+?>)} $text {}}

	proc callback {token} {
		if {[catch {::http::status $token} status] != 0} {return}
		if {![string equal {ok} $status]} {
			switch -exact -- $status {
				reset {
					putlog "\[\002SECURITEAM\002\] Connection to server was reset."
				}
				timeout {
					putlog "\[\002SECURITEAM\002\] Timeout (60 seconds) on connection to server."
				}
				default {
					putlog "\[\002SECURITEAM\002\] Unknown error occured, server output of the error is as follows: $status"
				}
			}
			::http::cleanup $token; return
		}
		# clean out old arrays
		array unset ::securiteam::data2; array set ::securiteam::data2 [array get ::securiteam::data]; array unset ::securiteam::data
		# start the parsing :-)
		set rss {}; foreach line [split [::http::data $token] \n] {append rss [string trim $line]}; ::http::cleanup $token
		foreach {x y rest date subj} [regexp -all -inline -- {<item (.+?)>(.+?)<dc:date>(.+?)</dc:date><dc:subject>(.+?)</dc:subject></item>} $rss] {
			switch -glob -- $subj {
				{Security News} {set type ndata}
				{Tools} {set type tdata}
				{Unix Focus} {set type udata}
				{Windows*} {set type wdata}
				{Exploit} {set type xdata}
				{Security Reviews} {set type rdata}
			}
			if {[string equal {Tools} $subj]} {
				foreach {x title link} [regexp -all -inline -- {<title>(.+?)</title><link>(.+?)</link>} $rest] {}; set desc {NULL}
			} else {
				foreach {x title link desc} [regexp -all -inline -- {<title>(.+?)</title><link>(.+?)</link><description>(.+?)</description>} $rest] {}
			}
			lappend ::securiteam::data([string index $type 0]titles) [set title [::securiteam::unhtml [::securiteam::mapEntities $title]]]
			lappend ::securiteam::data([string index $type 0]links) $link
			lappend ::securiteam::data([string index $type 0]descs) [set desc [::securiteam::unhtml [::securiteam::mapEntities $desc]]]
			if {([array size ::securiteam::data2] != 0) && ([lsearch -exact [set ::securiteam::data2([string index $type 0]links)] $link] == -1)} {
				switch -exact -- $type {
					ndata {
						putlog "\[\002Security News\002\] \002$title\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan securiteam]} {
								puthelp "PRIVMSG $chan :\[\002Security News\002] \002$title\002 >> $link"
							}
						}
					}
					tdata {
						putlog "\[\002Security Tools\002\] \002$title\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan securiteam]} {
								puthelp "PRIVMSG $chan :\[\002Security Tools\002] \002$title\002 >> $link"
							}
						}
					}
					udata {
						putlog "\[\002Unix Focus\002\] \002$title\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan securiteam]} {
								puthelp "PRIVMSG $chan :\[\002Unix Focus\002] \002$title\002 >> $link"
							}
						}
					}
					wdata {
						putlog "\[\002Windows Focus\002\] \002$title\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan securiteam]} {
								puthelp "PRIVMSG $chan :\[\002Windows Focus\002] \002$title\002 >> $link"
							}
						}
					}
					xdata {
						putlog "\[\002Exploits\002\] \002$title\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan securiteam]} {
								puthelp "PRIVMSG $chan :\[\002Exploits\002] \002$title\002 >> $link"
							}
						}
					}
					rdata {
						putlog "\[\002Security Reviews\002\] \002$title\002 >> $link"
						foreach chan [channels] {
							if {[channel get $chan securiteam]} {
								puthelp "PRIVMSG $chan :\[\002Security Reviews\002] \002$title\002 >> $link"
							}
						}
					}
				}
			}
		}
	}

	proc getData {minute hour day month year} {
		if {[incr ::securiteam::uinterval2] >= $::securiteam::uinterval} {
			::http::geturl $::securiteam::url -command "::securiteam::callback" -timeout 60000
			set ::securiteam::uinterval2 0
		}
	}
	bind time - "* * * * *" ::securiteam::getData

	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan securiteam]} {return}
		if {[string match -nocase {-d*} [lindex [split [set text [string trim $text]]] 0]]} {
			set details 1; set text [lindex [split $text] 1]
		}
		switch -glob -- $text {
			new* {set type ndata}
			too* {set type tdata}
			uni* {set type udata}
			win* {set type wdata}
			exp* {set type xdata}
			rev* {set type rdata}
			default {
				putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !securiteam \[-details\] <news|tools|unix|windows|exploits|reviews>"; return
			}
		}
		putcmdlog "# $nick@$chan !securiteam $text #"
		switch -- $::securiteam::messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002SECURITEAM\002\] Error, unknown messagetarget specified in script!"; return}
		}
		set lineout 0
		foreach title $::securiteam::data([string index $type 0]titles) link $::securiteam::data([string index $type 0]links) desc $::securiteam::data([string index $type 0]descs) {
			if {([info exists details]) && (![string equal {tdata} $type])} {
				if {(![string equal {} $title]) && (![string equal {} $link])} {
					puthelp "PRIVMSG $target :\002$title\002 >> $desc >> $link"
					if {[incr lineout] >= $::securiteam::maxresults} {break}
				}
			} else {
				if {(![string equal {} $title]) && (![string equal {} $link])} {
					puthelp "PRIVMSG $target :\002$title\002 >> $link"
					if {[incr lineout] >= $::securiteam::maxresults} {break}
				}
			}
		}
	}
	bind pub - !securiteam ::securiteam::pubCmds
}
package provide securiteam 1.0

## start init ##
foreach timer [utimers] {
	if {[string match {::securiteam::getData*} [join [lindex $timer 1]]]} {
		killutimer [lindex $timer end]
	}
}
set ::securiteam::uinterval2 $::securiteam::uinterval; utimer 8 {::securiteam::getData - - - - -}
## end init ##

putlog "securiteamrss.tcl v1.0 by leprechau@EFNet loaded!"
