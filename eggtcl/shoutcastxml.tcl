## script to check/monitor shoutcast xml feeds
## public commands: !listeners !sinfo !streams !url !dj !song !playing !request !site !www !website
## message commands: !requeston !requestoff !requestshow !requeststatus
## dcc/partyline commands: .shoutcast
## channel flags: .chanset #channel +/-shoutcast
## to enable/disable announcements and public commands
##
## by leprechau@EFnet
##
## message commands and dcc/partyline commands are flag restricted
## see settings section below
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::shoutcast {

	## begin settings ##
	
	variable uinterval 15;
	## update interval in seconds (connection to shoutcast xml feed)
	variable dccflag "n";
	## required flag to access partyline commands...may be a custom flag
	variable msgflag "o";
	## required flag to access message commands...may be a custom flag
	variable messagetarget "notc";
	## public command target (must be "msg" or "notc" or "chan")
	variable streamurls; array set streamurls {
		A http://1.2.3.4:8000/admin.cgi?pass=password&mode=viewxml
		B http://2.3.4.5:8800/admin.cgi?pass=password&mode=viewxml
	}
	## streamurls..primary url must be A, first secondary B, second C, and so on (must be upper case)
	variable savefile "/home/blah/eggdrop/scripts/shoutcast.conf";
	## full path and filename of your desired settings file
	variable mainchan "#radio"
	## the proper name of your main channel (request status, etc... sent here)

	## end settings ##

	## init vars ##
	foreach url [lsort [array names ::shoutcast::streamurls]] {
			variable data[set url]; array set data[set url] [list]
			variable data[set url]2; array set data[set url]2 [list]
	}
	variable formats; array set formats [list announce "" sinfo "" totals "" url "" dj "" reqson "" reqsoff "" site "" chantopic ""]
	variable reqstats; array set reqstats [list]; if {$::shoutcast::uinterval < 5} {variable uinterval 5}
	
	## load settings ##
	if {[file isfile $::shoutcast::savefile]} {
		if {[catch {source $::shoutcast::savefile} Err] != 0} {
			putlog "Error loading shoutcast settings: $Err"
		} else {
			putlog "Loaded shoutcast settings!"
		}
	}

	## load http package ##
	package require http
	::http::config -useragent {SHOUTcast Song Status (Mozilla Compatible)}
	setudef flag shoutcast

	## map xml hex encoded entities ##
	proc mapEntities {xml} {
		if {[regexp -all -- {\&\#([^\#]*)\;} $xml]} {
			foreach {x y} [regexp -all -inline -- {\&\#([^\#]*)\;} $xml] {set xml [string map "$x [format %c 0$y]" $xml]}; return $xml
		} else {return $xml}
	}

	## keyed list assit proc ##
	proc lget {list text} {
		if {[set index [lsearch -exact $list $text]] != -1} {
			return [lindex $list [expr {$index +1}]]
		} else {return {}}
	}

	## create macro map ##
	proc createmap {url} {
		if {[info exists ::shoutcast::data[set url](head)]} {
			set ctotal 0; set ptotal 0; set mtotal 0; set rtotal 0
			foreach stream [lsort [array names ::shoutcast::streamurls]] {
				incr ctotal [::shoutcast::lget [set ::shoutcast::data[set stream](head)] CURRENTLISTENERS]
				incr ptotal [::shoutcast::lget [set ::shoutcast::data[set stream](head)] PEAKLISTENERS]
				incr mtotal [::shoutcast::lget [set ::shoutcast::data[set stream](head)] MAXLISTENERS]
				incr rtotal [::shoutcast::lget [set ::shoutcast::data[set stream](head)] REPORTEDLISTENERS]
			}
			lappend map %TOTALCURRENTLISTENERS% $ctotal; lappend map %TOTALPEAKLISTENERS% $ptotal
			lappend map %TOTALMAXLISTENERS% $mtotal; lappend map %TOTALREPORTEDLISTENERS% $rtotal
			foreach {x y} [set ::shoutcast::data[set url](head)] {lappend map \%$x\% $y }
			lappend map %STREAMLOCATION% [lindex [split [set ::shoutcast::streamurls([set url])] {/}] 2]
			if {![info exists ::shoutcast::reqstats([::shoutcast::lget $::shoutcast::dataA(head) SERVERTITLE])]} {
				set ::shoutcast::reqstats([::shoutcast::lget $::shoutcast::dataA(head) SERVERTITLE]) "OFF"
			}
			lappend map %SERVERSTATUS% [::shoutcast::lget [set ::shoutcast::data[set stream](head)] SERVERSTATUS]
			lappend map %REQUESTSTATUS% [lindex [split [set ::shoutcast::reqstats([::shoutcast::lget $::shoutcast::dataA(head) SERVERTITLE])]] 0]
			return $map
		} else {return}
	}

	## http callback ##
	proc callback {url token} {
		#putlog "in callback token $token || url $url"
		if {[catch {::http::status $token} status] != 0} {return}
		if {![string equal {ok} $status]} {
			switch -exact -- $status {
				reset {
					putlog "\[\002SHOUTCAST\002\] ERROR: Connection to server($url) was reset."
				}
				timeout {
					putlog "\[\002SHOUTCAST\002\] ERROR: Timeout ([expr {$::shoutcast::uinterval - 3}] seconds) on connection to server($url)."
				}
				default {
					putlog "\[\002SHOUTCAST\002\] ERROR: Unknown error occured, server($url) output of the error is as follows: $status"
				}
			}
			lappend ::shoutcast::data[set url](head) SERVERSTATUS DOWN; catch {::http::cleanup $token}; return
		}
		## clean up arrays
		array unset ::shoutcast::data[set url]2; array set ::shoutcast::data[set url]2 [array get ::shoutcast::data[set url]]; array unset ::shoutcast::data[set url]
		## mark stream as up
		lappend ::shoutcast::data[set url](head) SERVERSTATUS UP
		#putlog "parsing xml..."
		regexp -all -- {<SHOUTCASTSERVER>(.+?)<WEBDATA>} [::http::data $token] x data; catch {::http::cleanup $token}
		set xml {}; foreach line [split $data \n] {append xml [string trim $line]}
		foreach {x stag text etag} [regexp -all -inline -- {(<.+?>)([^<]*)(<.+?>)} $xml] {
			lappend ::shoutcast::data[set url](head) [string trim $stag {<>}] [::shoutcast::mapEntities $text]
		}
		if {![string equal $url A]} {return}
		foreach var {CURRENTLISTENERS PEAKLISTENERS MAXLISTENERS SERVERURL SERVERTITLE SONGTITLE} {
			set $var [::shoutcast::lget $::shoutcast::dataA(head) $var]
		}
		if {([array size ::shoutcast::dataA2] != 0) && (![string equal [::shoutcast::lget $::shoutcast::dataA2(head) SONGTITLE] $SONGTITLE])} {
			if {(![string equal [::shoutcast::lget $::shoutcast::dataA2(head) SERVERTITLE] $SERVERTITLE])} {
				set ::shoutcast::reqstats($SERVERTITLE) "OFF"
				puthelp "TOPIC $::shoutcast::mainchan :[string map [::shoutcast::createmap A] $::shoutcast::formats(chantopic)]"
			}
			foreach chan [channels] {
				if {[channel get $chan shoutcast]} {
					puthelp "PRIVMSG $chan :[string map [::shoutcast::createmap A] $::shoutcast::formats(announce)]"
				}
			}
		}
	}

	## iniate xml fetch ##
	proc fetchUrl {url} {
		#putlog "fetching xml url $url ( $::shoutcast::streamurls($url) )..."
		if {[catch {::http::geturl $::shoutcast::streamurls($url) -command "::shoutcast::callback $url" -timeout [expr {($::shoutcast::uinterval - 3) * 1000}]} httpError] != 0} {
			putlog "\[\002SHOUTCAST\002\] ERROR: The following error has occured: $httpError (retry in $::shoutcast::uinterval seconds)"
		}
	}

	proc getData {} {
		set x 0; set y 5
		foreach url [lsort [array names ::shoutcast::streamurls]] {utimer [incr x $y] "::shoutcast::fetchUrl $url"}
		utimer $::shoutcast::uinterval {::shoutcast::getData}
	}

	## pub commands ##
	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan shoutcast]} {return}
		putcmdlog "\#$nick@$chan\# $::lastbind"
		switch -- $::shoutcast::messagetarget {
			msg {set target "PRIVMSG $nick"}
			notc {set target "NOTICE $nick"}
			chan {set target "PRIVMSG $chan"}
			default {putlog "\[\002SHOUTCAST\002\] Error, unknown messagetarget specified in script!"; return}
		}
		switch -exact -- $::lastbind {
			!sinfo - !streams {
				foreach stream [lsort [array names ::shoutcast::streamurls]] {
					lappend outs "[string map [::shoutcast::createmap $stream] $::shoutcast::formats(sinfo)] ($stream)"
				}
				lappend outs "[string map [::shoutcast::createmap A] $::shoutcast::formats(totals)]"
			}
			!listeners {lappend outs "[string map [::shoutcast::createmap A] $::shoutcast::formats(totals)]"}
			!url {
				lappend outs [string map [::shoutcast::createmap A] $::shoutcast::formats(url)]
			}
			!dj {lappend outs [string map [::shoutcast::createmap A] $::shoutcast::formats(dj)]}
			!song - !playing {lappend outs [string map [::shoutcast::createmap A] $::shoutcast::formats(announce)]}
			!request {
				if {[info exists ::shoutcast::reqstats([set dj [::shoutcast::lget $::shoutcast::dataA(head) SERVERTITLE]])]} {
					switch -- [lindex [split [set ::shoutcast::reqstats([::shoutcast::lget $::shoutcast::dataA(head) SERVERTITLE])]] 0] {
						ON {
							lappend outs [string map [::shoutcast::createmap A] $::shoutcast::formats(reqson)]
							if {![string equal {} $text]} {
								putserv "PRIVMSG [lindex [split $::shoutcast::reqstats($dj)] end] :\[\002REQUEST\002\] \002$nick\002@\002$chan\002 has requested \002$text\002 @ [clock format [clock seconds]]"
							}
						}
						OFF {lappend outs [string map [::shoutcast::createmap A] $::shoutcast::formats(reqsoff)]}
						default {return}
					}
				} else {lappend outs [string map [::shoutcast::createmap A] $::shoutcast::formats(reqsoff)]}
			}
			!site - !www - !website {lappend outs [string map [::shoutcast::createmap A] $::shoutcast::formats(site)]}
			default {return}
		}
		if {[info exists outs]} {foreach line $outs {puthelp "$target :$line"}}
	}
	foreach cmd {listeners sinfo streams url dj song playing request site www website} {bind pub - !$cmd ::shoutcast::pubCmds}

	## save settings ##
	proc savesettings {} {
		if {[catch {puts [set fid [open $::shoutcast::savefile w]] "array set ::shoutcast::formats \{[array get ::shoutcast::formats]\}"; close $fid} Err] != 0} {
			putlog "Save Error: $Err"; return
		} else {putlog "Shoutcast settings saved!"; return}
	}

	## dcc commands ##
	proc dccCmds {hand idx text} {
		putcmdlog "\#$hand\# $::lastbind $text"
		if {![matchattr $hand $::shoutcast::dccflag]} {putdcc $idx  "What? You need '.help'"; return}
		switch -- [lindex [split $text] 0] {
			announce {set ::shoutcast::formats(announce) [join [lrange [split $text] 1 end]]}
			chantopic {set ::shoutcast::formats(chantopic) [join [lrange [split $text] 1 end]]}
			sinfo {set ::shoutcast::formats(sinfo) [join [lrange [split $text] 1 end]]}
			totals {set ::shoutcast::formats(totals) [join [lrange [split $text] 1 end]]}
			url {set ::shoutcast::formats(url) [join [lrange [split $text] 1 end]]}
			dj {set ::shoutcast::formats(dj) [join [lrange [split $text] 1 end]]}
			requeston - requestson - reqson {set ::shoutcast::formats(reqson) [join [lrange [split $text] 1 end]]}
			requestoff - requestsoff - reqsoff {set ::shoutcast::formats(reqsoff) [join [lrange [split $text] 1 end]]}
			site - www {set ::shoutcast::formats(site) [join [lrange [split $text] 1 end]]}
			default {
				foreach {x y} [::shoutcast::createmap A] {append outs "$x = $y\n"}
				foreach {x y} [array get ::shoutcast::formats] {append outs2 "\002$x\002: $y\n"}
				putdcc $idx "\002Usage\002: .shoutcast <announce|chantopic|sinfo|totals|url|dj|reqson|reqsoff|site> <text>\n\n\037Macros (values reflect primary stream)\037:\n$outs\n\037Current\037:\n$outs2\n"
				return
			}
		}
		::shoutcast::savesettings
	}
	bind dcc $::shoutcast::dccflag shoutcast ::shoutcast::dccCmds

	## msg commands ##
	proc msgCmds {nick uhost hand text} {
		putcmdlog "\($nick!$uhost\) !$hand! $::lastbind"
		if {![matchattr $hand $::shoutcast::msgflag]} {putlog "\002UNAUTHORIZED REQUEST\002"; return}
		if {[string equal {} $text]} {set text $nick}
		set dj [::shoutcast::lget $::shoutcast::dataA(head) SERVERTITLE]
		switch -exact -- $::lastbind {
			!requeston {set ::shoutcast::reqstats($dj) "ON $text"; putserv "PRIVMSG $::shoutcast::mainchan :[string map [::shoutcast::createmap A] $::shoutcast::formats(reqson)]"}
			!requestoff {set ::shoutcast::reqstats($dj) "OFF $text"; putserv "PRIVMSG $::shoutcast::mainchan :[string map [::shoutcast::createmap A] $::shoutcast::formats(reqsoff)]"}
			!requestshow - !requeststatus {putserv "PRIVMSG $nick :Requests for \002$dj\002 are currently \002[lindex [split $::shoutcast::reqstats($dj)] 0]\002!"}
			default {return}
		}
	}
	foreach cmd {requeston requestoff requestshow requeststatus} {bind msg - !$cmd ::shoutcast::msgCmds}

}

## provide package ##
package provide shoutcast 1.0

## init timers ##
foreach tid [utimers] {
	if {[string match {*::shoutcast::*} [join [lindex $tid 1]]]} {
		killutimer [lindex $tid end]
	}
}
utimer 8 {::shoutcast::getData}

putlog "shoutcastxml.tcl v1.0 by leprechau@EFNet loaded!"

## EOF ##