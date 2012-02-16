## user/pass userfile accounting
## example code space
## leprechau@EFnet
##
## create a user: ::usertools::ulist add username pass
##
## delete a user: ::usertools::ulist del username
##
## save the user file: ::usertools::save filename
## ^-- returns 0 on normal exit
##
## auth a user: ::usertools::chkpass username pass
## ^-- returns 1 or 0
##
## generate random strings for passwords: ::usertools::rands length
## ^-- returns random strings of given length
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::usertools {
	## generate semi random strings
	proc rands {len {pool {0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ}}} {
		for {set i 0} {$i < $len} {incr i} {
			set x [expr {int(rand()*[string length $pool])}]
			append rs [string index $pool $x]
		}
		if {[info exists rs]} {return $rs} else {return}
	}

	## check user pass..return 1 or 0
	proc chkpass {user pass} {
		if {[string equal $::usertools::userRecords([string tolower $user]) [md5 $pass]]} {return 1} else {return 0}
	}
	
	## write user records array (to file provided)
	proc save {ufile} {
		if {[catch {set fid [open $ufile w]} oError] != 0} {
			return -code error "Could not open '$ufile' for writing:  $oError"
		}
		if {[catch {puts $fid "array set ::usertools::userRecords \{[array get ::usertools::userRecords]\}"} pError] != 0} {
			return -code error "Error writing to $file:  $pError"
		}
		if {[catch {close $fid} cError] != 0} {
			return -code error "Error closing $file:  $cError"
		}; return 0
	}
	
	## handle adding/deliting users from the array
	## remember to call ::userlist::save after modification
	proc ulist {action user {pass {}}} {
		switch -exact -- [string tolower $action] {
			del {
				if {![string equal {} [array get ::usertools::userRecords [string tolower $user]]]} {
					array unset ::usertools::userRecords [string tolower $user]
				} else {return -code error "Username not found."}
			}
			add {
				if {[string equal {} [array get ::usertools::userRecords [string tolower $user]]]} {
					array set ::usertools::userRecords [list [string tolower $user] [md5 $pass]]
				}
			}
		}
	}
}