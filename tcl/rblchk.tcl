## rbl check via dig with scoring system by leprechau@EFnet
## initial release no support or documentation other than provided herein
##
## commands provided:
##
## ::rblchk::score <host> ?-callback <command and arguments>?
##   proc structure for callback: proc <name> {<ip> <details> <score>} {}
##   additional arguments passed to callback are prepended
##
## NOTE:
## if you are interested in the eggdrop code that works with this script
## please look at http://woodstock.anbcs.com/scripts/eggrbl.tcl
##

if {[namespace exists ::rblchk]} {namespace delete ::rblchk}
namespace eval ::rblchk {
	namespace export dig check score

	## begin settings ##

	variable digbin [lindex [split [exec which dig]] 0]
	## location of dig binary including path (default should work on most systems)

	variable rbls; array set rbls {
		ircbl.ahbl.org {{Abusive Hosts} +2.0}
		sbl-xbl.spamhaus.org {{Spamhaus combined zone} +3.0}
		rbl.efnetrbl.org {{Undesirable clients} +3.0}
		dul.dnsbl.sorbs.net {{Dynamic IPs} -1.0}
	}
	## array of rbls, descriptions, and a score for each
	## format: rblname {{description to show offenders} score}
	## scores must be numeric, but can be either + or - and whole or decimal numbes

	## end settings ##
	variable version 1.1

	## option fetcher
	proc getOpt {opts key text} {
		## make sure only valid options are passed
		foreach {opt val} $text {
			if {[lsearch -exact $opts $opt] == -1} {
				return -code error "Unknown option '$opt', must be one of: [join $opts {, }]"
			}
		}
		## return selected option
		if {[set index [lsearch -exact $text $key]] != -1} {
			return [lindex $text [expr {$index +1}]]
		} else {return {}}
	}

	## exec dig and parse the output
	proc dig {host args} {
		## filter out some options
		set type [::rblchk::getOpt {-ns -type -callback} -type $args]; if {![string length $type]} {set type A}
		set ns [::rblchk::getOpt {-ns -type -callback} -ns $args]; if {[string length $ns]} {set ns "@$ns "}
		## do our lookup...call our digbin...
		if {[catch {set lookup [eval exec $::rblchk::digbin +time=1 $ns$host $type]} xError] != 0} {
			## handle error codes properly and cleanup xError if possible
			switch -exact -- [lindex [split $::errorCode] end] {
				1 {set xError "Usage error"}
				8 {set xError "Couldn't open batch file"}
				9 {set xError "No reply from server"}
				10 {set xError "Internal error"}
			}
			return -code error "Error calling dig: ($::rblchk::digbin $ns$host $type): $xError"
		}
		## parse out our info from dig output
		foreach line [split [string trim [regsub -all {;(.+?)\n} $lookup {}]] \n] {
			if {![string length $line]} {continue}
			foreach {x y z rec} $line {break}
			switch -exact -- $rec {
				A {lappend ips [join [lindex [split $line] end]]}
				TXT {lappend txts [join [lindex [split $line {"}] 1]]}
				default {continue}
			}
		}
		## make sure we got everything we needed
		foreach var {ips txts} {if {![info exists [set var]]} {set [set var] NULL}}
		## check for callback...execute if you got one...otherwise just return our results
		if {[string length [set cmd [::rblchk::getOpt {-ns -type -callback} -callback $args]]]} {
			switch -- $type {
				A {eval [linsert [set cmd] end $host $ips]}
				TXT {eval [linsert [set cmd] end $host $txts]}
				ANY {eval [linsert [set cmd] end $host $ips $txts]}
			}
		} else {
			switch -- $type {
				A {return [list $host $ips]}
				TXT {return [list $host $txts]}
				ANY {return [list $host $ips $txts]}
			}
		}
	}

	## prepare our information to pass off to dig proc
	proc check {host rbl args} {
		## check for ipv4 decimal host...if not we need to resolve it
		if {![regexp {^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$} $host]} {
			set host [lindex [lindex [::rblchk::dig $host] 1] 0]
			## make sure we got a valid return....if not let's return all nulls
			if {[string equal {NULL} $host]} {
				## do a callback?...if not just return em
				if {[string length [set cmd [::rblchk::getOpt {-ns -type -callback} -callback $args]]]} {
					eval [set cmd] NULL NULL NULL NULL NULL
				} else {return "NULL NULL NULL NULL NULL"}
			}
		}
		## reverse the ip...
		for {set i 0} {$i < 4} {incr i} {lappend rip [lindex [split $host {.}] end-$i]}; set rip [join $rip {.}]
		## do the lookup
		foreach {xhost ips txts} [::rblchk::dig $rip\.$rbl -type ANY] {}
		## do a callback?...if not just return the results
		if {[string length [set cmd [::rblchk::getOpt {-ns -type -callback} -callback $args]]]} {
			eval [linsert [set cmd] end $host $xhost $ips $txts]
		} else {return [list $host $xhost $ips $txts]}
	}

	## compute our score and pass off to callback if provided
	proc score {host args} {
		set total 0; set details [list]
		foreach rbl [array names ::rblchk::rbls] {
			if {![string equal {NULL} [lindex [set check [::rblchk::check $host $rbl]] 2]]} {
				set total [expr [subst {$total [set score [lindex $::rblchk::rbls($rbl) end]]}]]
				if {![string equal {NULL} [lindex $check 3]]} {
					lappend details [list $score $rbl [lindex $::rblchk::rbls($rbl) 0] [lindex $check 3]]
				} else { lappend details [list $score $rbl [lindex $::rblchk::rbls($rbl) 0] {}] }
			}
		}; if {![string length $details]} {set details NULL}
		if {[string length [set cmd [::rblchk::getOpt {-ns -type -callback} -callback $args]]]} {
			eval [linsert [set cmd] end [lindex $check 0] $details $total]
		} else {return [list [lindex $check 0] $details $total]}
	}
}
package provide rblchk $::rblchk::version

## EOF ##
