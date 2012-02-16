## simple random joke script
## initial version by leprechau@EFnet
## no documentation or support other than provided herein
##
## channel settings:
##
## .chanset #chan +jokes
## ^- toggle pub cmd (!joke) for this channel
##
## .chanset #chan flood-joke 15:60
## ^- set the joke flood for this channel
## to 15 jokes in 60 seconds (this is the default)
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::jokeStuff {
	variable jfiles [list scripts/misc/rjokes.txt]
	## any text file with the following format
	## question
	## punchline
	## <blank line>
	## question
	## punchline
	## <blank line>
	## etc...throughout the file
	
	## use my flood control script
	## http://woodstock.anbcs.com/scripts/floodcontrol.tcl
	package require floodcontrol
	
	## end settings ##
	
	## user defined flag for script control ##
	setudef flag jokes; setudef str flood-jokes
	
	## read in all our jokes just once per script load ##
	set xid 0; foreach jfile $::jokeStuff::jfiles {
		foreach {q a x} [split [read [set fid [open $jfile r]]] \n] {
			array set ::jokeStuff::jData [list [incr xid] [list $q $a]]
		}; close $fid
	}; unset xid



	proc pubJokes {nick uhost hand chan text} {
		## check our flood settings for this channel..grab from channel flag if set
		if {![string length [set flood [channel get $chan flood-jokes]]} {
			## set the default flood settings for the session called 'jokes' to 30 times in 60 seconds

			set ::floodcontrol::flimits(jokes) "15:60"
		} else {set ::floodcontrol::flimits(jokes) $flood}

		## check this channel and call our flood check for the 'jokes' session

		if {(![channel get $chan jokes]) || ([::floodcontrol::check jokes])} {return}
		## no flood...continue on...but record this call to this session name
		## the value passed after the session name is optional
		::floodcontrol::record jokes $uhost
		## now go on with the rest of the proc
		if {[set size [array size ::jokeStuff::jData]]} {
			foreach {q a} [lindex [array get ::jokeStuff::jData [expr {round(rand()*$size)}]] end] {break}
			puthelp "PRIVMSG $chan :$q"; utimer 4 [list puthelp "PRIVMSG $chan :$a"]
		}
	}
	bind pub - !ha ::jokeStuff::pubJokes
}
putlog "jokes.tcl v0.1 by leprechau@EFnet loaded!"