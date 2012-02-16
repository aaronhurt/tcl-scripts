## fastest raw mass deop possible + some really fast superbitch/mdop protect
## channel flags: .chanset #channel +takeover || .chanset #channel +keepit
## partyline commands: .take -> net mass deop || .massdeop -> single bot mass deop
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::tkeep {

	proc massraw {pm mode tgt arg} {
		foreach {1 2 3 4} $arg {
			append mlines "MODE $tgt ${pm}${mode}${mode}${mode}${mode} $1 $2 $3 $4\n"
		}
		if {[info exists mlines]} {putdccraw 0 [string length $mlines\n] $mlines\n}
	}

	proc doit {dchan dnicks dtype} {
		putlog "\[\002MASSDEOP\002\] Deopping \002[llength $dnicks]\002 non-op(s) on \002$dchan\002 using method $dtype ..."
		switch -- $dtype {
			3 {
				while {[llength $dnicks] > 1} {
					lappend tmp [lindex $dnicks [set half [expr {[llength $dnicks] / 2}]]]
					set dnicks [lreplace $dnicks $half $half]
				}
				lappend tmp [lindex $dnicks 0]; ::tkeep::massraw - o $dchan $tmp
			}
			2 {::tkeep::massraw - o $dchan [lsort -decreasing $dnicks]}
			1 {::tkeep::massraw - o $dchan [lsort -increasing $dnicks]}
			default {
				foreach x $dnicks {
					lappend mixed [lindex $dnicks [set rindex [rand [llength $dnicks]]]]
					set dnicks [lreplace $dnicks $rindex $rindex]
				}; if {[info exists mixed]} {::tkeep::massraw - o $dchan $mixed}
			}
		}
	}

	proc oplist {chan {flags {o}}} {
		foreach nick [chanlist $chan] {
			if {[isop $nick $chan] && ![matchattr [nick2hand $nick $chan] $flags|$flags $chan]} {lappend oplist $nick}
		}
		if {[info exists oplist]} {return $oplist} else {return {}}
	}

	proc massrawdeop {hand idx text} {
		if {![string length $text]} {putdcc $idx "\002Usage\002: $::lastbind <channel> ?type?"; return}
		if {![validchan [set dchan [lindex [split $text] 0]]]} {putdcc $idx "Unable to mass deop '$dchan' - invalid channel."; return}
		if {![botisop $dchan]} {putdcc $idx "Unable to mass deop '$dchan' - not opped."; return}
		if {[llength [set dnicks [::tkeep::oplist $dchan]]] < 1} {putdcc $idx "\002***\002 No action taken, noone to deop on \002$dchan\002."; return}
		if {[string length [lindex [split $text] 1]] && [string is integer [lindex [split $text] 1]]} {set dtype [lindex [split $text] 1]}
		if {(![info exists dtype]) || ($dtype > 3)} {set dtype 0}
		::tkeep::doit $dchan $dnicks $dtype
	}
	bind dcc n massdeop ::tkeep::massrawdeop

	proc netmassrawdeop {hand idx text} {
		if {![string length $text]} {putdcc $idx "\002Usage:\002 .take <channel> ?type?"; return}
		putallbots "netmassrawdeop [lindex [split $text] 0]"; ::tkeep::massrawdeop $hand $idx $text
	}
	bind dcc n take ::tkeep::netmassrawdeop

	proc botmassrawdeop {from command text} {
		foreach {chan nicks} $text {}
		if {(![validchan $chan]) || (![botisop $chan]) || ([llength $nicks] < 1)} {return}
		::tkeep::doit $chan $nicks [rand 4]
	}
	bind bot - netmassrawdeop ::tkeep::botmassrawdeop

	## out takevoer/protect flag :)
	setudef flag takeover; setudef flag keepit

	proc checkchannel {from keyword text} {
		foreach {nick uhost} [split $from !] {}
		foreach {chan modes v1 v2 v3 v4} [split $text] {}
		switch -glob -- $modes {
			+o* {
				if {[channel get $chan takeover]} {
					foreach vict {v1 v2 v3 v4} {
						if {[string equal -nocase $::botnick [set $vict]]} {
							::tkeep::doit $chan [set ops [::tkeep::oplist $chan]] [rand 4]; putallbots [list netmassrawdeop $chan $ops]; break
						}
					}
				}
				if {[channel get $chan keepit]} {
					foreach vict {v1 v2 v3 v4} {
						if {[string length [set $vict]] && ![matchattr [nick2hand [set $vict] $chan] o|o $chan]} {lappend bnicks [set $vict]}
					}
					if {[info exists bnicks]} {
						lappend bnicks $nick; ::tkeep::doit $chan $bnicks [rand 4]; putallbots [list netmassrawdeop $chan $bnicks]
					}
				}
			}
			-o* {
				if {[channel get $chan keepit] && ![matchattr [nick2hand $nick] b]} {
					## see if we need to reop anything...
					foreach vict {v1 v2 v3 v4} {
						if {[string length [set $vict]] && [matchattr [nick2hand [set $vict] $chan] o|o $chan]} {lappend reops [set $vict]}
					}; if {[info exists reops]} {::tkeep::massraw + o $chan $reops}
					## only massdeop in case of 3 or more -o
					if {[string match -nocase *ooo* $modes]} {
						::tkeep::doit $chan [set ops [concat [::tkeep::oplist $chan] $nick]] [rand 4]; putallbots [list netmassrawdeop $chan $ops]; return
					}
				}
			}
			default {return}
		}
	}
	bind raw - MODE ::tkeep::checkchannel
}
putlog "take&keep.tcl by leprechau@efnet loaded!"
