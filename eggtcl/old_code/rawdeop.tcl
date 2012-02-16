## fastest raw mass deop possible
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
proc rawmmode {prefix mode chan nicks} {
	set nicks [split $nicks]; while {[llength $nicks] >= 1} {
		if {[llength $nicks] >= 4} {set numModes 4} else {set numModes [llength $nicks]}
		lappend lines "MODE $chan $prefix[string repeat $mode $numModes] [lrange $nicks 0 3]"; set nicks [lreplace $nicks 0 3]
	}
	putdccraw 0 [string length [set lines "[join $lines \n]\n"]] $lines
	##putlog "SENT RAW: $lines"
}

proc chanoplist {chan {flags {o}}} {
	foreach nick [chanlist $chan] {
		if {[isop $nick $chan] && ![matchattr [nick2hand $nick $chan] $flags]} {lappend oplist $nick}
	}
	if {[info exists oplist]} {return $oplist} else {return {}}
}

proc mixit {list} {
	set x [llength $list]; for {set i 0} {$i < $x} {incr i} {
		set rindex [rand [llength $list]]
		lappend mixed [lindex $list $rindex]
		set list [lreplace $list $rindex $rindex]
	}
	return $mixed
}

proc realmassrawdeop {dchan dnicks dtype} {
	putlog "\[\002MASSDEOP\002\] Deopping \002[llength $dnicks]\002 non-op(s) on \002$dchan\002 using method $dtype ..."
	switch -- $dtype {
		3 {
			set dnicks [lsort $dnicks]
			while {[llength $dnicks] > 1} {
				set half [expr [llength $dnicks] / 2]
				lappend Dnicks [lindex $dnicks $half]
				set dnicks [lreplace $dnicks $half $half]
			}
			lappend Dnicks [lindex $dnicks 0]; rawmmode - o $dchan $Dnicks
		}
		2 {rawmmode - o $dchan [lsort -decreasing $dnicks]}
		1 {rawmmode - o $dchan [lsort -increasing $dnicks]}
		default {rawmmode - o $dchan [mixit $dnicks]}
	}
}

proc massrawdeop {hand idx text} {
	if {![string length $text]} {putdcc $idx "\002Usage\002: $::lastbind <channel>"; return}
	if {![validchan [set dchan [lindex [split $text] 0]]]} {putdcc $idx "Unable to mass deop '$dchan' - invalid channel."; return}
	if {![botisop $dchan]} {putdcc $idx "Unable to mass deop '$dchan' - not opped."; return}
	if {[llength [set dnicks [chanoplist $dchan]]] < 1} {putdcc $idx "\002***\002 No action taken, noone to deop on \002$dchan\002."; return}
	if {[string length [lindex [split $text] 1]] && [string is integer [lindex [split $text] 1]]} {set dtype [lindex [split $text] 1]}
	if {(![info exists dtype]) || ($dtype > 3)} {set dtype 0}
	realmassrawdeop $dchan $dnicks $dtype
}
bind dcc n massdeop massrawdeop

proc netmassrawdeop {hand idx text} {
	if {![string length $text]} {putdcc $idx "\002Usage:\002 .take <channel>"; return}
	putallbots "netmassrawdeop [lindex [split $text] 0]"; massrawdeop $hand $idx $text
}
bind dcc n take netmassrawdeop

proc botmassrawdeop {from command text} {
	if {(![botisop [set dchan [lindex [split $text] 0]]]) || (![validchan $dchan]) || ([llength [set dnicks [chanoplist $dchan]]] < 1)} {return}
	realmassrawdeop $dchan $dnicks [rand 4]
}
bind bot - netmassrawdeop botmassrawdeop

## out takevoer flag :)
setudef flag takeover

proc checkchannel {nick host hand chan mode victim} {
	switch -- [lindex [split $mode] 0] {
		+o {
			if {[channel get $chan takeover] && [string equal -nocase $victim $::botnick]} {
				realmassrawdeop $chan [chanoplist $chan] [rand 4]; putallbots "netmassrawdeop $chan";
			}
		}
		default {return}
	}
}
bind mode - * checkchannel

putlog "raw deop by leprechau@efnet loaded!"
