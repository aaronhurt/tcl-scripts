## possibly portable disk info script with some formatting utillities
## uses the output from 'df -k' ... tested on freebsd and osx
#

proc diskstats {} {
	## try and catch any errors...
	if {[catch {exec df -k} eOut] != 0} {
		return -code error "Error executing 'df -k' -> $eOut"
	}
	## start the parsing..
	foreach line [lrange [split $eOut \n] 1 end] {
		## assign values to each column
		foreach {fs size used avail cap mp} $line {break}
		## ignore anything that's not a device
		if {![string match /dev/* $fs]} {continue}
		## check if we have seen this disk before..if not create an array entry
		## also notice we strip the last char...the partition marker
		if {![string length [array get tmp [set disk [string range $fs 0 end-1]],*]]} {
			array set tmp [list $disk,size $size $disk,used $used $disk,avail $avail]
			## add an element that shows our disk names
			lappend tmp(disks) $disk
		} else {
			## we have seen this disk before...let's just increase the existing values
			foreach val {size used avail} {set tmp($disk,$val) [expr {$tmp($disk,$val) + [set $val]}]}
		}
	}
	## okay...that's done let's return our results
	return [array get tmp]
}

## get more human readable sizes
proc getsize {num {type {bytes}}} {
	## set our initial sart size..default to bytes
	switch -- [string tolower $type] {
		kb {set i 1}
		mb {set i 2}
		gb {set i 3}
		tb {set i 4}
		default {set i 0}
	}
	## keep dividing by 1024 and track divisions
	while {$num >= 1024} {
		set num "[expr {$num / 1024.0}]"; incr i
	}
	## truncate to 2 decimal places
	set num [format %0.2f $num]
	## this switch will assign a name to our
	## number of divisions we got above...
	switch -- $i {
		0 {return "$num\BYTES"}
		1 {return "$num\KB"}
		2 {return "$num\MB"}
		3 {return "$num\GB"}
		4 {return "$num\TB"}
		default {return UNKNOWN}
	}
}

## take our stuff from diskstats and run it through getsize
proc disks {} {
	## assign our output from diskstats to an array
	array set stats [diskstats]
	## loop through our disks..
	foreach disk $stats(disks) {
		## make pretty lines
		lappend outs "[set disk [lindex [split $disk {,}] 0]]: Total: [getsize $stats($disk,size) kb]\
		Used: [getsize $stats($disk,used) kb] Free: [getsize $stats($disk,avail) kb]\
		([format %0.2f [expr {([format %0.1f $stats($disk,avail)] / $stats($disk,size)) * 100}]]\%\)"
	}
	## return our results as lines
	return [join $outs \n]
}
