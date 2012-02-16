## example script for BoR0@Efnet
## by leprechau@EFnet 11.11.2004
## description:
## maintain an array of opped nicks with timestamps check
## stamps every 10 minutes and if expired, deop associated nick
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

## create the namespace for this script ##
namespace eval ::checkops {

	## skip checks on these flags
	variable eflags "bB"
	
	## set a custom flag to set op checking per channel
	setudef flag timedeop

	## init ops array ##
	variable ops; array set ops [list]

	## get current viable channel ops nicks and hosts ##
	proc getOps {chan} {
		foreach nick [chanlist $chan] {
			if {[isop $nick $chan]} {
				if {[validuser [set hand [nick2hand $nick]]] && [matchattr $hand $::checkops::eflags|$::checkops::eflags]} {continue}
				lappend ops [getchanhost $nick $chan] $nick
			}
		}
		return $ops
	}

	## bind raw on all modes ##
	checkModes {from keyword text} {
		set chan [lindex [split $text] 0]
		set modes [lindex [split $text 1]
		set targets [lrange [split $text] 2 end]
		if {[string match *+o* $modes]} {
			foreach nick $targets {
				if {[validuser [set hand [nick2hand $nick]]] && [matchattr $hand $::checkops::eflags|$::checkops::eflags]} {continue}
				array set ::checkops::ops [list [lindex [split $from {!}] end] [unixtime]]
			}
		}
	}
	bind raw - MODE ::checkops::checkModes

	## time bound proc..check array every 10 minutes for expired ops ##
	proc opCheck {min hour day month year} {
		foreach chan [channels] {
			if {[channel get $chan timedeop]} {
				foreach {host1 ts} [array get ::checkops::ops] {host2 nick} [::checkops::getOps $chan] {
					if {([string equal $host1 $host2]) && (round(([unixtime] - $ts) / 60.0) >= 10)} {
						putlog "\002Deopping $nick@$chan (10 minute op time expired)\002"; pushmode $chan -o $nick
					}
				}
				flushmode $chan
			}
		}
	}
	bind time - "*0 * * * *" ::checkops::opCheck
}
package provide checkops 0.1

putlog "checkops 0.1 by leprechau@EFnet loaded!"
