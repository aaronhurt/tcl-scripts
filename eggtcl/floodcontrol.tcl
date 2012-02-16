## universal simple flood control with basic session like array
## version 0.1 by leprechau@EFnet
## example below..read it and learn :)
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::floodcontrol {
	
	## our version
	variable version 0.1
	## set and initialize our arrays
	variable flimits; array set flimits [list]
	variable sessions; array set sessions [list]

	## proc to check the status...return 1 for flood...return 0 for okay
	proc check {session} {
		## make sure session is registered and that limits are set...if not return 0
		if {![info exists ::floodcontrol::sessions($session)] || ![info exists ::floodcontrol::flimits($session)]} {return 0}
		## seperate our flimit var into usable numbers
		foreach {max tl} [split $::floodcontrol::flimits($session) {:}] {break}
		## check if we are disabled in the eggdrop style 0:0
		if {($max == 0) && ($tl == 0)} {return 0}
		## cycle through our array..and set an initial zero count of items
		set temp [list]; set count 0; foreach {ts value} $::floodcontrol::sessions($session) {
			## kick out expired elements
			if {[expr {[clock seconds] - $ts}] < $tl} {
				lappend temp $ts $value; incr count
			}
		}
		## update the data for this session
		array set ::floodcontrol::sessions [list $session $temp]
		## check number of valid timespamps counted
		if {$count >= $max} {return 1} else {return 0}
	}

	## proc to call in script you are wanting to limit
	proc record {session {value {-}}} {
		if {[string equal {-} $value]} {set value [string trimleft [expr {rand()}] {0.}]}
		## make sure session is registered..if not initialize it
		if {![info exists ::floodcontrol::sessions($session)]} {
			set ::floodcontrol::sessions($session) [list]
		}
		lappend ::floodcontrol::sessions($session) [clock seconds] $value
	}
}
package provide floodcontrol $::floodcontrol::version

## example script using this namespace below ... read and learn ##
#
## this text can be safely removed if you choose ##
#
#set ::floodcontrol::flimits(floodTest) "3:60"
## set the flood settings for the session called 'floodTest' to 3 times in 60 seconds
##
## we can also take use of a channel string udef as shown in the proc below
##
#setudef flag flood-test
## set a user defined str for our flood setting..check it in the proc
##
#proc pubFloodTest {nick uhost hand chan text} {
#	## check our flood settings for this channel..grab from channel flag if set
#	if {![string length [set flood [channel get $chan flood-test]]} {
#		## the string is not set...let's set a default

#		set ::floodcontrol::flimits(floodTest) "3:60"
#	} else {set ::floodcontrol::flimits(floodTest) $flood}
#	## call our flood check for the 'floodTest' session
#	if {[::floodcontrol::check floodTest]} {
#		putlog "FLOOD CONTROL ACTIVATED"; return
#	}
#	## no flood...continue on...but record this call to this session name
#	## the value passed after the session name is optional
#	::floodcontrol::record floodTest $uhost
#	## now go on with the rest of the proc
#	putserv "PRIVMSG $chan :Hello there!"
#}
#bind pub - !hello pubFloodTest
