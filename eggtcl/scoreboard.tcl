## espn.com scoreboard script
## includes all scoreboards as of this writing
##
## MLB - NFL - NBA - NHL - NCF - NCB
##
## initial version...no documentation or support
## other than provided herein
##
## chansets:
##  .chanset #chan +/-scoreboard
##  ^-- enable or disable pub commands on given channel
##
##  .chanset #chan autoscores nfl nhl ncf
##  ^-- can list one or more of: MLB NFL NBA NHL NCF NCB
##
## usage: !scores <sport> ?team? ?date/week?"
##
## by leprechau@EFnet
##
#
namespace eval ::espn {

	## begin user settings ##

	## maximum lines to show in channel...any output over this number will be sent
	## completely via privmsg to user
	variable maxnum 5

	## ammount of time in minutes to check for score updates
	## this only affects the auto announce...pub commands are always up to date
	variable uinterval 3

	## time of day to start scanning espn.com for autoscores
	## this should be in 24 hour time format (EST)
	variable start 1200

	## time of day to stop scanning espn.com for autoscores
	## this is also 24 hour time format (EST)
	variable stop 0200

	## end user settings ##

	## our url templates for each sport
	variable urls; array set urls [list\
	mlb http://mobileapp.espn.go.com/mlb/mp/html/scoreboard?date=%DATE%&dvc=1\
	nfl http://mobileapp.espn.go.com/nfl/mp/html/scoreboard?year=%YEAR%&season=2&week=%WEEK%&dvc=1\
	nba http://mobileapp.espn.go.com/nba/mp/html/scoreboard?date=%DATE%&dvc=1\
	nhl http://mobileapp.espn.go.com/nhl/mp/html/scoreboard?date=%DATE%&dvc=1\
	ncf http://mobileapp.espn.go.com/ncf/mp/html/scoreboard?year=%YEAR%&season=2&week=%WEEK%&dvc=1\
	ncb http://mobileapp.espn.go.com/ncb/mp/html/scoreboard?date=%DATE%&dvc=1]

	## setup a udef to enable/disable per channel
	setudef flag scoreboard

	## setup a udef to customize channel announces
	setudef str autoscores

	## we will use my http package ##
	package require lephttp

	## our state array...everything we store goes here
	variable state; array set state [list]

	## our time tracker variable..do not change this
	variable uinterval2 0

	## format our start/stop times into clock seconds
	variable starttime [clock scan "${::espn::start} EST" -base\
	[clock scan [clock format [clock seconds] -format %Y%m%d]]]
	variable stoptime [clock scan "${::espn::stop} EST" -base\
	[clock scan [expr {[clock format [clock seconds] -format %Y%m%d]+1}]]]

}

## pub command output...
proc ::espn::outit {ename title cts nick chan ptrn} {
	## show em what we got...
	if {[info exists ::espn::state($ename,scores)] && [llength $::espn::state($ename,scores)] >= 1} {
		## set our target based on length of output...
		if {[set count [llength [lsearch -all -glob [string tolower $::espn::state($ename,scores)] [string tolower $ptrn]]]] >= $::espn::maxnum} {
			set target $nick} else {set target $chan}
		## nothing matched thier pattern..let them know...
		if {$count == 0} {puthelp "PRIVMSG $target :Sorry, no scores matching $ptrn were found."; return}
		## otherwise...let's continue on...
		set lts 0; foreach stat $::espn::state($ename,stats) score $::espn::state($ename,scores) ts $::espn::state($ename,times) {
			if {[string match -nocase $ptrn $score]} {
				## show our date header if we haven't yet or if it has changed...
				if {($ts != $cts) && ($ts != $lts)} {
					puthelp "PRIVMSG $target :\[\002[clock format $ts -format {%A, %B %d %Y}]\002\]"
				}; set lts $ts
				## format our numbers and times as bold..
				regsub -all -- {[[:digit:]:]+} $score \002&\002 score
				puthelp "PRIVMSG $target :$title :: $score \(\002$stat\002\)"
			}
		}
	} else {puthelp "PRIVMSG $target :Sorry, no scores found."; return}
}

## our callback handler
proc ::espn::doit {type vars token} {
putlog "in doit - $type | $vars | $token"
	if {![string equal -nocase {ok} [set status [::lephttp::status $token]]] && [::lephttp::ncode $token] != 200} {
		::lephttp::cleanup $token; return -code error "Error processing url: $status"
	}
	## set our current 'day' timestamp
	set cts [clock scan [clock format [clock seconds] -format %Y%m%d]]
	## get some info about our calling url from the state array this is really only needed
	## for the pub commands when someone wants future or past information
	switch -exact -- $type {
		nfl - ncf {
			if {[regexp -all -- {week=(\d+)} $::lephttp::state($token,path) x rtime]} {
				set rtime week$rtime
			} else {set rtime $cts}
		}
		mlb - nba - nhl - ncb {
			if {![regexp -all -- {date=(\d+)} $::lephttp::state($token,path) x rtime]} {set rtime $cts}
		}
		default {continue}
	}
	## set data..cleanup token...
	regsub -all -- {^.*<hr>} [::lephttp::data $token] {} html; ::lephttp::cleanup $token
	## keep our arrays neat and tidy when handling pub and auto callbacks
	if {[llength $vars] == 1} {
		array unset ::espn::state $type,old,*; array set ::espn::state [string map {,cur, ,old,} [array get ::espn::state $type,cur,*]]
		array unset ::espn::state $type,cur,*; set ename $type,cur
	} else {array unset ::espn::state $type,$rtime,*; set ename $type,$rtime}
	## split up our page and make it really easy to parse...
	set text [string trim [::lephttp::strip [string map [list <b> DATE| <br> \n &nbsp\; {}] $html]]]
	## check for no games message...and stop
	set nogames 0; if {![string match -nocase {*no games scheduled*} $text]} {
		## continue on...parse it out and show it off...
		set switcher 0; foreach line [split $text \n] {
			if {[string match DATE|* $line]} {set ts [clock scan [lindex [split $line |] end]]; continue}
			set line [string trim $line]; switch -exact -- $switcher {
				0 {
					## fix a bug in espn game stats for NBA ... they show Overtime instead of 4th period
					if {[string equal $type nba] && [string equal [lindex [split $line] end] Overtime]} {
						lappend ::espn::state($ename,stats) [string map [list Overtime 4th] $line]
					} else {lappend ::espn::state($ename,stats) $line}
					lappend ::espn::state($ename,times) $ts; set switcher 1
				}
				1 {lappend ::espn::state($ename,scores) $line; set switcher 0}
			}
		}
	} else {set nogames 1}
	## get the full name of our type...helps make things not blend together so well during busy times on auto scores
	switch -exact -- $type {
		mlb {set title "\002M\002ajor \002L\002eague \002B\002aseball (MLB)"}
		nfl {set title "\002N\002ational \002F\002ootball \002L\002eague (NFL)"}
		nba {set title "\002N\002ational \002B\002asketball \002A\002ssociation (NBA)"}
		nhl {set title "\002N\002ational \002H\002ockey \002L\002eague (NHL)"}
		ncf {set title "\002N\002ational \002C\002ollege \002F\002ootball (NCF)"}
		ncb {set title "\002N\002ational \002C\002ollege \002B\002asketball (NCB)"}
	}
	## what are we doing..were we called by the time bind or a pub bind...
	if {[llength $vars] == 1} {
putlog "DOING AUTO CALL - $type ...."
		if {[info exists ::espn::state($type,cur,scores)] && [llength $::espn::state($type,cur,scores)] >= 1 &&\
		[info exists ::espn::state($type,old,scores)] && [llength $::espn::state($type,old,scores)]} {
			foreach stat $::espn::state($type,cur,stats) score $::espn::state($type,cur,scores) score2 $::espn::state($type,old,scores) {
				if {[string length $score] && ![string equal -nocase $score $score2]} {
putlog "CHANGE: $score != $score2"
					## format our numbers and times as bold..
					regsub -all -- {[[:digit:]:]+} $score \002&\002 score
					foreach chan [channels] {
						if {[lsearch -exact [split [string tolower [channel get $chan autoscores]]] $type] != -1} {
							puthelp "PRIVMSG $chan :$title :: $score \(\002$stat\002\)"
						}
					}
				}
			}
		}
	} else {
		## get our actual values out of 'vars'
		foreach {nick chan ptrn} $vars {break}
		## check if nogames was set during our parsing loop...
		if {[info exists nogames] && $nogames == 1} {puthelp "PRIVMSG $chan :Sorry, no games scheduled."; return}
		## well we are still here..let's hit the output proc
		::espn::outit $ename $title $cts $nick $chan $ptrn
	}
}

## time bound proc for auto score updates...
proc ::espn::auto {minute hour day month year} {
	## has it been long enough??
	if {[incr ::espn::uinterval2] >= $::espn::uinterval} {
		## make sure we are within our hours of operation...
		if {[set secs [clock seconds]] < $espn::starttime || $secs > $::espn::stoptime} {
			set ::espn::uinterval2 0; return
		}
		## build a list of our enabled channels...
		set strings [list]; foreach chan [channels] {
			if {[string length [set text [channel get $chan autoscores]]]} {
				set strings [concat $strings [split [string tolower $text]]]
			}
		}; set strings [lsort -unique [split $strings]]
putlog "strings == '$strings'"
		## continue on...
		foreach {type url} [array get ::espn::urls] {
			## only continue if this type is in our enabled list
			if {[lsearch -exact $strings $type] != -1} {
				## make sure we have active games before hitting any url
				## if our cur data is empty...let's fill it before we start checking times
				if {[string length [array get ::espn::state $type,cur,times]]} {
					set cts [clock scan [clock format [clock seconds] -format %Y%m%d]]; set current 0
					foreach ts $::espn::state($type,cur,times) stat $::espn::state($type,cur,stats) {
						## check if the ts is today and our stat is a future time
						if {$cts == $ts && [string match {*:* ?? ??} $stat]} {
							lappend temps [clock scan [string map {ET EST} $stat]]
						} elseif {$cts == $ts && ![string match -nocase final* $stat]} {
							putlog "current stat $stat"; set current 1; break
						}
					}
					if {[info exists temps]} {
putlog "$type temps == $temps"
						## see if any of our stat times are here or passed...
						foreach temp [lsort -increasing -integer $temps] {
							if {$temp <= [clock seconds]} {putlog "current time $temp [clock format $temp]"; set current 1; break}
						}; unset temps
					}
				} else {set current 1}
				## well nothing current going on..skip this type and continue to the next...
				if {$current == 0} {putlog "no current $type"; continue}
				## well guess we have a current game...we made it this far...set our url and go...
				switch -exact -- $type {
					nfl - ncf {set url [regsub -- {year(.+?)K%&} $url {}]}
					mlb - nba - nhl - ncb {set url [regsub -- {date(.+?)E%&} $url {}]}
					default {continue}
				}
				::lephttp::geturl $url -timeout 5000 -command [list ::espn::doit $type AUTO]
			}
		}; set ::espn::uinterval2 0
	}
}
bind time - "* * * * *" ::espn::auto

## fix the timestamps for a new day at 0600 (6am) every day
## also reset cur and old arrays for new data....
proc ::espn::fixtimes {minute hour day month year} {
	## format our start/stop times into clock seconds
	set ::espn::starttime [clock scan ${::espn::start}EST]
	set ::espn::stoptime [clock scan ${::espn::stop}EST -base [clock scan tomorrow]]
	## cleanup cached data from state array
	array unset ::espn::state *,*,*
}
bind time - "06 00 * * *" ::espn::fixtimes

## pub cmd handler..
proc ::espn::pubs {nick uhost hand chan text} {
	## make sure we are enabled here...
	if {![channel get $chan scoreboard]} {return}
	putcmdlog "$nick\@$chan $::lastbind $text"
	## get our arguments all parsed out from the crap users send us
	if {[set arglen [llength [split $text]]] == 2} {
			if {[string is integer [lindex [split $text] 1]]} {
				set tm [lindex [split $text] 1]
putlog "tm == $tm"
			} else {set ptrn *[join [lrange [split $text] 1 end]]*}
	} elseif {$arglen >= 3} {
		if {[string is alpha [lindex [split $text] 1]]} {
			if {[string is integer [lindex [split $text] end]]} {
				set tm [lindex [split $text] end]
putlog "tm == $tm"
				set ptrn *[join [lrange [split $text] 1 end-1]]*
			} else {set ptrn *[join [lrange [split $text] 1 end]]*}
		}
	}
	if {![info exists ptrn]} {set ptrn *}
putlog "ptrn == $ptrn"
	## continue on...
	switch -exact -- [set type [string tolower [lindex [split $text] 0]]] {
		nfl - ncf {
			if {[info exists tm]} {
				set url [string map [list %YEAR% [clock format [set secs [clock seconds]] -format %Y] %WEEK% $tm] $::espn::urls($type)]
				set rtime week$tm
			} else {set url [regsub -- {year(.+?)K%&} $::espn::urls($type) {}]}
		}
		mlb - nba - nhl - ncb {
			if {[info exists tm]} {
				set url [string map [list %DATE% $tm] $::espn::urls($type)]; set rtime $tm
			} else {set url [regsub -- {date(.+?)E%&} $::espn::urls($type) {}]}
		}
		default {
			puthelp "PRIVMSG $chan :Usage: $::lastbind <sport> ?team? ?date/week?"
			puthelp "PRIVMSG $chan :Example: $::lastbind nba [expr {[clock format [clock seconds] -format %Y%m%d]+1}]"
			puthelp "PRIVMSG $chan :Sports: mlb, nfl, nba, nhl, ncf, ncb"; return
		}
	}
putlog "type == $type"
	## check our state array...if this is a past or future request
	## we may have it cached already and not have to hit the web...
	if {[info exists rtime] && [info exists ::espn::state($type,$rtime,scores)]} {
		::espn::outit $type,$rtime [clock scan [clock format [clock seconds] -format %Y%m%d]] $nick $chan $ptrn; return
	}
	## well...no luck in the cache..and hey we made it this far...let's do it...
	::lephttp::geturl $url -timeout 5000 -command [list ::espn::doit $type [list $nick $chan $ptrn]]
}
bind pub - !scores ::espn::pubs

putlog "espn.com scoreboard script by leprechau@EFnet loaded!"

## EOF ##
