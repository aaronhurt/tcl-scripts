## massmode snippet
proc mass_mode { plusminus modeType queue channel nicknames } {
	global modes-per-line
	set count 0
	set nicks ""
	set numModes ""
	if {$queue != "putserv" && $queue != "puthelp"} { set queue "putquick" }
	set maxModes [llength [split $nicknames]]
	if {$maxModes < 1} { return }
	foreach 1nick $nicknames {
		incr count
		append nicks "$1nick "
		append numModes $modeType
		if {($count % ${modes-per-line}) == 0 || $count >= $maxModes} {
			$queue "MODE $channel $plusminus$numModes [string range $nicks 0 [expr [string length $nicks] - 2]]"
			set nicks ""
			set numModes ""
		}
	}
}
