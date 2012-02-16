##################################################
## simple adbot version 1.1                     ##
## by leprechau@efnet for http://www.cheezy.com ##
## Friday, October 25, 2002                     ##
##################################################


##################################################
# User Defined Settings                          #
##################################################
set chanad_file "/home/cis/advertise/eggdrop/text/chanads.txt"
# the name and path of your chanad file
#
set chanad_prefix "\002\[Cheezy Internet Services\]\002"
# text to put before the advertisement in the channel
#
set chanad_exempt ""
# a comma seperated list of channels to skip
#
set tagit "0"
# set to 1 to enable appending the handle/date/time
# information to the end of the advertisement
#
set chanad_time "15"
# frequency in minutes that you wish to display ad
#
##################################################
##          DO NOT EDIT THIS SCRIPT             ##
##         DOING SO IS NOT SUPPORTED            ##
##################################################
set chanad_ver "1.1"


## Startup and Initialization
if {![file isfile $chanad_file]} {
	putlog "\[\002ERROR\002\] File '$chanad_file' does not exist!"
	putlog "   --- Creating empty file"
	if {[catch {exec touch $chanad_file} error] != 0} {
		putlog "\[\002ERROR\002\] Could not create new chanad file:  $error" ; return
	}
	putlog "Done! Continuing to load chanad.tcl ..."
}

# 2 small procs to aid in setting/resetting timers
proc kill_timer { text } {
	set timerID [lindex [split $text] 0]
	set killed 0
	foreach 1timer [timers] {
		if {[lindex $1timer 1] != $timerID} { continue }
		killtimer [lindex $1timer 2]
		set killed 1
	}
	return $killed
}

proc settimer { minutes command } {
	if {$minutes < 1} { set minutes 1 }
	kill_timer "$command"
	timer $minutes "$command"
}

## Init script...
if {![info exists chanad_currentad]} { set chanad_currentad 1 }
settimer $chanad_time chanad_display

## Small proc to remove blank lines from database
proc clean_chanad_file {} {
global chanad_file
	if {![file isfile $chanad_file]} {
		putlog "\[\002ERROR\002\] File '$chanad_file' does not exist!"
		putlog "   --- Creating empty file"
		if {[catch {exec touch $chanad_file} error] != 0} {
			putlog "\[\002ERROR\002\] Could not create new chanad file:  $error" ; return
		}
		putlog "Done!"
	}

	if {[catch {set file [open $chanad_file r]} open_error] != 0} {
		putlog "\[\002ERROR\002\] Could not open '$chanad_file' for reading:  $open_error" ; return
	}
	if {[catch {set tmpfile [open .chanad_file.tmp w 0600]} open_error] != 0} {
		putlog "\[\002ERROR\002\] Could not open temp file '.chanad_file.tmp' for writing:  $open_error" ; return
	}
	while {![eof $file]} {
		gets $file line
		if {![string equal {} $line]} {
			if {[catch { puts $tmpfile "$line" } write_error] != 0} {
				putlog "\[\002ERROR\002\] Could not write to temp file:  $write_error" ; return
			}
		}
	}
	if {[catch {close $file} close_error] != 0} {
		putlog "\[\002ERROR\002\] Error closing '$chanad_file' file:  $close_error" ; return
	}
	if {[catch {close $tmpfile} close_error] != 0} {
		putlog "\[\002ERROR\002\] Error closing temp file '.chanad_file.tmp':  $close_error" ; return
	}
	if {[catch {file rename -force .chanad_file.tmp $chanad_file} error] != 0} {
		putlog "\[\002ERROR\002\] Could not move chanad file from temp file:  $error" ; return
	}
	return
}
clean_chanad_file

# proc to get total lines from chanad file
proc chanad_total {} {
global chanad_file
	if {![file isfile $chanad_file]} {
		putlog "\[\002ERROR\002\] File '$chanad_file' does not exist!" ; return
	}
	if {[catch {set file [open $chanad_file r]} open_error] != 0} {
		putlog "\[\002ERROR\002\] Could not open '$chanad_file' for reading:  $open_error" ; return
	}
	set linecounter 0
	while {![eof $file]} {
		gets $file line
		if {![string equal {} $line]} { incr linecounter }
	}
	if {[catch {close $file} close_error] != 0} {
		putlog "\[\002ERROR\002\] Error closing $chanad_file:  $close_error"
	}
	return $linecounter
}

# proc to get random line from chanad file for display
proc chanad_getad {} {
global chanad_file chanad_currentad
	if {![file isfile $chanad_file]} {
		putlog "\[\002ERROR\002\] File '$chanad_file' does not exist!" ; return
	}
	if {[catch {set file [open $chanad_file r]} open_error] != 0} {
		putlog "\[\002ERROR\002\] Could not open '$chanad_file' for reading:  $open_error" ; return
	}
	set linecounter 0
	set totalads [chanad_total]
	if {$totalads == 0} { return NULL }
	if {$chanad_currentad > $totalads} { set chanad_currentad 1 }
	set displayline $chanad_currentad
		while {![eof $file]} {
		gets $file line
		if {![string equal {} $line]} { incr linecounter }
		if {$displayline == $linecounter} {
			set display_return "$line"
			if {[catch {close $file} close_error] != 0} {
				putlog "\[\002ERROR\002\] Error closing $chanad_file:  $close_error"
			}
		incr chanad_currentad
		return $display_return
		} 
	}
	return NULL
}

# display next ad from chanad file
proc chanad_display {} {
global chanad_time chanad_exempt chanad_prefix
	set displayad "[chanad_getad]"
	if {[string equal NULL $displayad]} { return }
	foreach 1channel [channels] {
		if {![string match *$1channel* [join [split $chanad_exempt ,]]]} {
			puthelp "PRIVMSG $1channel :$chanad_prefix $displayad"
		}
	}
	settimer $chanad_time chanad_display
}

## DCC Commands
proc dcc_chanad_add {handle idx text} {
global chanad_file tagit
	set ad $text
	if {[string equal {} $text]} { putdcc $idx "\002Usage\002: .+chanad  <advertisement>" ; return }
	if {![file isfile $chanad_file]} {
		putdcc $idx "\[\002ERROR\002\] File '$chanad_file' does not exist!" ; return
	}
	if {[catch {set file [open $chanad_file a 0600]} open_error] != 0} {
		putdcc $idx "\[\002ERROR\002\] Could not open file '$chanad_file' for writing:  $open_error" ; return
	}
	if {$tagit == 1} {
		if { [catch { puts $file "$ad --added by [hand2nick $handle] @ [time] on [date]" } write_error] != 0} {
			putlog "\[\002ERROR\002\] Could not write to file '$chanad_file':  $write_error"
		}
	} else {
		if { [catch { puts $file "$ad" } write_error] != 0} {
			putlog "\[\002ERROR\002\] Could not write to file '$chanad_file':  $write_error"
		}
	}
	if {[catch {close $file} close_error] != 0} {
		putlog "\[\002ERROR\002\] Error closing file '$chanad_file':  $close_error"
	}
	putdcc $idx "\[\002New Ad\002\] $ad"
	clean_chanad_file
	return
}
bind dcc m +chanad dcc_chanad_add

proc dcc_chanad_del {handle idx text} {
global chanad_file
	if {([string equal {} $text]) || (![isnumber $text]) } {
		putdcc $idx "\002Usage\002: .-chanad <number>"
		dcc_chanads $handle $idx ""
		return
	}

	if {![file isfile $chanad_file]} { 
		putdcc $idx "\[\002ERROR\002\] File '$chanad_file' does not exist!" ; return
	}
	if {[catch {set file [open $chanad_file r]} open_error] != 0} {
		putdcc $idx "\[\002ERROR\002\] Could not open '$chanad_file' for reading:  $open_error" ; return
	}
	if {[catch {set tmpfile [open .chanad_file.tmp w 0600]} open_error] != 0} {
		putdcc $idx "\[\002ERROR\002\] Could not open '$chanad_file' for writing:  $open_error" ; return
	}
	set linecounter 0
	set deleted 0
	while {![eof $file]} {
		gets $file line
		if {![string equal {} $line]} { incr linecounter }
		if {$text == $linecounter} { set deleted 1 }
		if {$text != $linecounter} {
			if {[catch { puts $tmpfile "$line" } write_error] != 0} {
				putdcc $idx "\[\002ERROR\002\] Could not write to temp file '.chanad_file.tmp':  $write_error" ; return
			}
		}
	}
	if {[catch {close $file} close_error] != 0} { 
		putdcc $idx "\[\002ERROR\002\] Error closing file '$chanad_file':  $close_error" ; return
	}
	if {[catch {close $tmpfile} close_error] != 0} { 
		putdcc $idx "\[\002ERROR\002\] Error closing temp file:  $close_error" ; return
	}
	if {$deleted == 0} { putdcc $idx "\[\002ERROR\002\] The ad number specified was not found in the database, and therefore not deleted." ; return }
	if {[catch {file rename -force ".chanad_file.tmp" $chanad_file} error] != 0} {
		putdcc $idx "\[\002ERROR\002\] Could not move list from temp file:  $error" ; return
	}
	putdcc $idx "\[\002Del Chanad\002\] Chanad \002#$text\002 successfully removed from the database"
	clean_chanad_file
	return
}
bind dcc m -chanad dcc_chanad_del

proc dcc_chanads {handle idx text} {
global chanad_file
	if {![file isfile $chanad_file]} {
		putdcc $idx "\[\002ERROR\002\] File '$chanad_file' does not exist!" ; return
	}
	if {[catch {set file [open $chanad_file r]} open_error] != 0} {
		putdcc $idx "\[\002ERROR\002\] Could not open '$chanad_file' for reading:  $open_error" ; return
	}
	putdcc $idx "\[\002Current Chanad Listing\002\]"
	set linecounter 0
	while {![eof $file]} {
		gets $file line
		if {![string equal {} $line]} { incr linecounter ; putdcc $idx "\[\002#$linecounter\002\]\: $line" }
	}
	if {$linecounter == 0} { putdcc $idx "" ; putdcc $idx "\002--- database currently empty ---\002" ; putdcc $idx "" }
	if {[catch {close $file} close_error] != 0} {
		putdcc $idx "\[\002ERROR\002\] Error closing file '$chanad_file':  $close_error" ; return
	}
	return
}
bind dcc m chanads dcc_chanads

proc dcc_chanad_help {handle idx text} {
global chanad_ver
	putdcc $idx "\[\002Chanads.tcl v$chanad_ver Help\002\]"
	putdcc $idx "\002.+chanad\002 <advertisement>"
	putdcc $idx "\002.-chanad\002 <number>"
	putdcc $idx "\002.chanads\002 list current ads"
	putdcc $idx "\002.chanadhelp\002 displays this help menu"
	putdcc $idx ""
}
bind dcc m chanadhelp dcc_chanad_help

putlog "chanad.tcl v$chanad_ver by leprechau@efnet loaded."