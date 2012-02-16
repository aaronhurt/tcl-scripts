## nforce.tcl v1.0
## by leprecau@EFnet
## no documentation or support other than provided herein
##
## to use: .chanset #chan +nforce
## command: !nforce
##
## NOTE: this script requires my http package
## you can get it from: http://woodstock.anbcs.com/scripts/tcl/lephttp.tcl
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
##
namespace eval ::nforce {

	## begin settings ##

	variable maxresults 5;
	## maximum results to display on public commands
	variable cexpire 60;
	## cache expire time in minutes (make this too long, and your searches could be outdated)
	variable messagetarget "msg";
	## public command target (must be "msg" or "notc" or "chan")
	variable url "http://nforce.nl/index.php?menu=quicknav&item=search"
	## there should be no need to change this unless you have a mirror site or something

	## end settings ##

	variable numver 1.0; variable cexpire2 0

	## get my http package from
	## http://woodstock.anbcs.com/scripts/tcl/lephttp.tcl
	package require lephttp
	## config it..
	::lephttp::config -useragent {Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)}
	setudef flag nforce

	proc checkCache {minute hour day month year} {
		if {[incr ::nforce::cexpire2] >= $::nforce::cexpire} {
			putlog "\[\002NFORCE\002\] Clearing cached searches (cache will clear again in $::nforce::cexpire minutes)."
			catch {array unset ::nforce::cache}; set ::nforce::cexpire2 0
		}
	}
	bind time - "* * * * *" ::nforce::checkCache

	proc callback {nick chan text token} {
		if {[catch {::lephttp::status $token} status] != 0} {return}
		if {![string equal {ok} [set status [string tolower $status]]]} {
			switch -exact -- $status {
				timeout {
					putlog "\[\002NFORCE\002\] Timeout (60 seconds) on connection to server."
				}
				default {
					putlog "\[\002NFORCE\002\] Unknown error occured, server output of the error is as follows: $status"
				}
			}
			::lephttp::cleanup $token; return
		}
		## make sure array empty
		catch {array unset ::nforce::data}
		## parse it out
		foreach {x name y dat} [regexp -all -nocase -inline {<td name=\"(.+?)\"(.+?)>(.+?)</td>} [::lephttp::data $token]] {
			set dat [::lephttp::map [::lephttp::strip $dat]]
			switch -exact -- $name {
				tdate {if {![string equal {DATE} $dat]} {lappend ::nforce::data(date) $dat}}
				tsection {if {![string equal {SECTION} $dat]} {lappend ::nforce::data(section) $dat}}
				trelease {if {![string equal {RELEASE NAME} $dat]} {lappend ::nforce::data(release) $dat}}
				tgroup {if {![string equal {GROUP} $dat]} {lappend ::nforce::data(group) $dat}}
				tsize {if {![string equal {SIZE} $dat]} {lappend ::nforce::data(size) $dat}}
				toptions {
					if {![string equal {OPTIONS} $dat]} {
						if {[regexp -all -nocase {nfoid=(.+?)\"} $x z nfoid]} {
							lappend ::nforce::data(nfoid) $nfoid
						}
					}
				}
				default {}
			}
		}; ::lephttp::cleanup $token
		## add search to our cache (lets not hammer nforce.nl if we don't have to)
		array set ::nforce::cache [list $text [array get ::nforce::data]]
		## display data
		switch -- $::nforce::messagetarget {
			msg {set target "PRIVMSG $nick"}
			notc {set target "NOTICE $nick"}
			chan {set target "PRIVMSG $chan"}
			default {putlog "\[\002NFORCE\002\] Error, unknown messagetarget specified in script!"; return}
		}
		if {[array size ::nforce::data]} {
			set num 0; foreach date $::nforce::data(date) section $::nforce::data(section) release $::nforce::data(release) \
			group $::nforce::data(group) size $::nforce::data(size) nfoid $::nforce::data(nfoid) {
				if {$num < $::nforce::maxresults} {
					puthelp "$target :$date | $section | $release | $group | $size | http://nforce.nl/savenfo.php?id=$nfoid"; incr num
				} else {return}
			}
		} else {
			puthelp "$target :$nick, Sorry no results returned for your search ($text)."; return
		}
}

	## pub commands ##
	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan nforce]} {return}
		putcmdlog "\#$nick@$chan\# !nforce $text"
		switch -- $::nforce::messagetarget {
			msg {set target "PRIVMSG $nick"}
			notc {set target "NOTICE $nick"}
			chan {set target "PRIVMSG $chan"}
			default {putlog "\[\002NFORCE\002\] Error, unknown messagetarget specified in script!"; return}
		}
		if {![string length $text]} {
			puthelp "$target :Usage: !nforce <-all|-pcgrip|-pcgiso|-pcgpat|-pcgdox|-pcgpat|-pciso|-dc|-ps|-ps2|-xbox|-xbox360|\
			-gba|-gc|-psp|-divx|-xvid|-vcd|-svcd|-anime|-xxx|-tv|-dvd> <search text>"
			puthelp "$target :For more information try: !nforce -help"; return
		}
		switch -- [lindex [split $text] 0] {
			-all {set sect ""}
			-pcgrip {set sect 1}
			-pcgiso {set sect 2}
			-pcgpat {set sect 4}
			-pcgdox {set sect 5}
			-pcgadd {set sect 3}
			-pciso {set sect 6}
			-dc {set sect 7}
			-ps {set sect 8}
			-ps2 {set sect 9}
			-xbox {set sect 11}
			-xbox360 {set sect 22}
			-gba {set sect 10}
			-gc {set sect 20}
			-psp {set sect 21}
			-divx {set sect 12}
			-xvid {set sect 13}
			-vcd {set sect 14}
			-svcd {set sect 15}
			-anime {set sect 16}
			-xxx {set sect 17}
			-tv {set sect 19}
			-dvd {set sect 18}
			-help {
				if {[string equal {chan} $::nforce::messagetarget]} {set target "PRIVMSG $nick"}
				puthelp "$target :nforce.tcl v$::nforce::numver by leprechau@EFnet"
				puthelp "$target :-all = All"
				puthelp "$target :-pcgrip = PC Game Rips"
				puthelp "$target :-pcgiso = PC Game ISOs"
				puthelp "$target :-pcgpat = PC Game Rip Patches"
				puthelp "$target :-pcgdox = PC Game Dox"
				puthelp "$target :-pcgadd = PC Game Addons"
				puthelp "$target :-pciso = PC App ISOs"
				puthelp "$target :-dc = DreamCast"
				puthelp "$target :-ps = PlayStation"
				puthelp "$target :-ps2 = PlayStation2"
				puthelp "$target :-xbox = Xbox"
				puthelp "$target :-xbox360 = Xbox 360"
				puthelp "$target :-gba = GameBoy Advance"
				puthelp "$target :-gc = GameCube"
				puthelp "$target :-psp = PSP"
				puthelp "$target :-divx = DivX"
				puthelp "$target :-xvid = XviD"
				puthelp "$target :-vcd = VCD"
				puthelp "$target :-svcd = SVCD"
				puthelp "$target :-anime = Anime"
				puthelp "$target :-xxx = XXX"
				puthelp "$target :-tv = TV-Rips"
				puthelp "$target :-dvd = DVD-R"
				puthelp "$target :-help = This help menu"; return
			}
			default {set sect ""; set text "-all $text"}
		}
		## let's check our local cache before hitting the website (it's SOOO SLOW)
		if {([array size ::nforce::cache]) && ([lsearch -exact [array names ::nforce::cache] $text] != -1)} {
			array set data $::nforce::cache($text); set num 0; foreach date $::nforce::data(date) section $::nforce::data(section) \
			release $::nforce::data(release) group $::nforce::data(group) size $::nforce::data(size) nfoid $::nforce::data(nfoid) {
				if {$num < $::nforce::maxresults} {
					puthelp "$target :$date | $section | $release | $group | $size | http://nforce.nl/savenfo.php?id=$nfoid"; incr num
				} else {return}
			}
			## there we go...got it from cache..nothing left to do
			return
		}
		## get the info
		::lephttp::geturl $::nforce::url -query [::lephttp::formatQuery search_name [join [lrange [split $text] 1 end]] search_group "" search_section $sect \
		search_from 1990-01-01 search_to [clock format [clock seconds] -format %Y-%m-%d] search_nukeopt 2 submit_search Search] \
		-command [list ::nforce::callback $nick $chan $text]
	}
	bind pub - !nforce ::nforce::pubCmds
}
package provide nforce $::nforce::numver

putlog "nforce.tcl v$::nforce::numver by leprechau@EFnet loaded!"
