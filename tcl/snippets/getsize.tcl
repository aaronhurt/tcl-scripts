proc getsize {num {type {bytes}}} {
	switch -- [string tolower $type] {
		kb {set i 1}
		mb {set i 2}
		gb {set i 3}
		tb {set i 4}
		default {set i 0}
	}
	while {$num >= 1024} {
		set num "[expr {$num / 1024.0}]"; incr i
	}
	set num [format %0.2f $num]
	switch -- $i {
		0 {return "$num\BYTES"}
		1 {return "$num\KB"}
		2 {return "$num\MB"}
		3 {return "$num\GB"}
		4 {return "$num\TB"}
		default {return UNKNOWN}
	}
}