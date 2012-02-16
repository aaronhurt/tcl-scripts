## example cache code by leprehau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

proc cache:store {data} {
global cache_data
	# stick it in the cache...
	array set cache_data "[clock seconds] $data"
	# if we are over 500 elements, clean out 100 oldest ones
	if {[array size cache_data] >= 500} {
		foreach name [lrange [lsort -decreasing -inline [array names cache_data]] end-100 end] {
			array unset cache_data $name
		}
	}
}

proc cache:check {data} {
global cache_data
	# check if array exists..if empty stop
	if {![array exists cache_data]} { return 0 }
	# start searching the array
	set found 0; set sid [array startsearch cache_data]
	# search till no names left
	while {[array anymore cache_data $sid] != 0} {
		# if we find a match in cache, break the loop and finish the search
		if {[string equal -nocase $data [lindex [array get cache_data [array nextelement cache_data $sid]] end]]} {
			array donesearch cache_data $sid; set found 1; break
		}
	}
	# return 1 or 0
	return $found
}
