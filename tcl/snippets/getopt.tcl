## little script snippets
## use at your own risk :)
##
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

## keyed list assit proc
proc lget {text key} {
	if {([llength $text] > 0) && ([set index [lsearch -exact $text $key]] != -1)} {
		return [lindex $text [expr {$index +1}]]
	} else {return {}}
}

## fetch ungrouped options from a string
proc getOpt {opts text} {
	foreach opt $opts {
		if {[set indx [lsearch -exact [split $text] $opt]] != -1} {

			array set map [list $indx $opt]
		} else {array set outs [list $opt ""]}

	}
	set tmp [lsort -integer -increasing [array names map]]

	for {set x 0} {$x < [array size map]} {incr x} {

		set index [lindex $tmp $x]; set index2 [lindex $tmp [expr {$x +1}]]

		if {![string length $index2]} {set index2 end} else {set index2 [expr {$index2 -1}]}

		array set outs [list $map($index) [join [lrange [split $text] [expr {$index +1}] $index2]]]

	}; return [array get outs]

}