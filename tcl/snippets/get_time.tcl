## duration (convert seconds to realtime)
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
proc duration {s} {
	foreach var {m hr d wk y} { set $var "" }
	if {$s >= 31536000} {
		set y "[expr {$s / 31536000}]"
		set s "[expr {$s - (31536000 * $y)}]"
	}
	if {$s >= 604800} {
		set w "[expr {$s / 604800}]"
		set s "[expr {$s - (604800 * $w)}]"
	}
	if {$s >= 86400} {
		set d "[expr {$s / 86400}]"
		set s "[expr {$s - (86400 * $d)}]"
	}
	if {$s >= 3600} {
		set h "[expr {$s / 3600}]"
		set s "[expr {$s - (3600 * $h)}]"
	}
	if {$s >= 60} {
		set m "[expr {$s / 60}]"
		set s "[expr {$s - (60 * $m)}]"
	}
	
	foreach var {yr wk d hr m s} {
		if {![string equal {} [set $var]]} { lappend returns "[set $var]$var" }
	}
	return [join $returns {, }]
}
