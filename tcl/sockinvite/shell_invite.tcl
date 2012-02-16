#!/bin/tclsh
#^-set to exact path of tclsh

## settings ##
set inv(sitecmd) "PINVITE"
set inv(sitename) "NA"
set inv(userpath) "/ftp-data/users"
set inv(invitechan) "#pre"
set inv(botip) "81.7.135.22"
set inv(inviteport) "63550"
set inv(authkey) "L4elGPu52152Zc2vkeuQ"
set inv(bencrypt) "/bin/bencrypt"

## end settings ## begin script ## end settings ##

proc inv:get_group { user } {
global inv
	if {[catch {set userfile_channel [open $inv(userpath)/$user r]} open_error] != 0} {
		puts "\[\002ERROR\002\] Could not open '$inv(userpath)/$user' for reading:  $open_error"
		return
	}
	set glgroup ""
	while {![eof $userfile_channel]} {
	gets $userfile_channel line
		if {[string equal [lindex [split $line] 0] "GROUP"]} {
			set glgroup [lindex [split $line] 1] ; break
		}
	}
	if {[catch {close $userfile_channel} close_error] != 0} {
		puts "\[\002ERROR\002\] Error closing '$inv(userpath)/$user':  $close_error"
		return
	}
	if {![string equal {} $glgroup]} {
		return "$glgroup"
	} else { return "UNKNOWN" }
}

proc do:invite { ircnick } {
global inv env
	set gluser $env(USER)
	set glgroup [inv:get_group $gluser]
	puts "-=+ Inviting '$ircnick' to $inv(invitechan) +=-"
	set sock [socket $inv(botip) $inv(inviteport)]
	fconfigure $sock -buffering line
	fileevent $sock readable { set connected 1 }
	vwait connected
	set cryptstring [exec $inv(bencrypt) "5uZ3nU6NI" "$inv(authkey) $ircnick $gluser $glgroup $inv(sitename)"]
	puts $sock "$cryptstring"
}

if {$argc < 1} {
	puts "Syntax: SITE $inv(sitecmd) <ircnick>"
	return
} else { do:invite [lindex [split $argv] 0] }
