###########################################################
# example eggdrop tcl for channel invite from txt file    #
# leprechau@Efnet 02.13.2004                              #
###########################################################
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::invite {

	### start settings ###

	variable idb "/home/bob/eggdrop/scripts/invite.db"
	# location and name of file to store password information
	
	variable icmd "!invite"
	# message command to use
	
	variable ichan "#testing123"
	# channel to invite people to

	### end settings ###

	variable DATA;array set DATA [list]
	if {![file isfile $idb]} {
		putlog "\[\002ERROR\002\] File '$idb' does not exist!"
		putlog "A new file will be created when you add your first user."
	} else {
		putlog "Sourcing invite database database $idb\...."
		source $idb
		putlog "Done, [array size DATA] logins found and loaded!"
	}

	proc addi {hand idx text} {
		variable idb;variable DATA
		if {[string equal {} $text]} {
			putdcc $idx "\[\002ERROR\002\] Syntax: .addinvite <username> <password>"; return
		}
		foreach {login pass} [split $text { }] {break}
		if {![string equal {} [array get DATA $login]]} {
			putdcc $idx "\[\002ERROR\002\] Error, the user you are trying to add already exists"; return
		}
		array set DATA [list $login [encpass $pass]]
		if {[catch {set file [open $idb w]} open_error] != 0} {
			putdcc $idx "\[\002ERROR\002\] Could not open '$idb' for writing:  $open_error"; return
		}
		if {[catch {puts $file "array set DATA \{[array get DATA]\}"} puts_error] != 0} {
				putdcc $idx "\[\002ERROR\002\] Could not write to idb database:  $puts_error"; return
		}
		if {[catch {close $file} close_error] != 0} {
			putdcc $idx "\[\002ERROR\002\] Error closing idb database:  $close_error"; return
		}
		putdcc $idx "Successfully added '$login' to invite database!"
	}
	bind dcc n addinvite ::invite::addi

	proc deletei {hand idx text} {
		variable idb;variable DATA
		if {[string equal {} [array get DATA [set login [lindex [split $text { }] 0]]]]} {
			putdcc $idx "\[\002ERROR\002\] The login '$login' was not found in the database, and therefore not deleted."; return
		}
		if {[catch {array unset DATA $login} catch_error] != 0} {
			putdcc $idx "\[\002\ERROR\002\] The login '$login' could not be deleted due to an unknown error."; return
		} else {
			if {[catch {set file [open $idb w]} open_error] != 0} {
				putdcc $idx "\[\002ERROR\002\] Could not open '$idb' for writing:  $open_error"; return
			}
			if {[catch {puts $file "array set DATA \{[array get DATA]\}"} puts_error] != 0} {
				putdcc $idx "\[\002ERROR\002\] Could not write to idb database:  $puts_error"; return
			}
			if {[catch {close $file} close_error] != 0} {
				putdcc $idx "\[\002ERROR\002\] Error closing idb database:  $close_error"; return
			}
			putdcc $idx "Successfully removed '$login' from invite database!"
		}
	}
	bind dcc n deleteinvite ::invite::deletei

	# okie...here it is, the actual invite proc
	proc doinvite {nick uhost hand text} {
		variable ichan;variable icmd;variable DATA
		if {[llength [split $text { }]] != 2} {
			putserv "PRIVMSG $nick :\[\002ERROR\002\] Syntax: /msg $::botnick $icmd <username> <password>"; return
		}
		set msguser [lindex [split $text { }] 0]
		set msgpass [lindex [split $text { }] 1]
		set dbuser [lindex [array get DATA $msguser] 0]
		set dbpass [lindex [array get DATA $msguser] 1]
		if {(![string equal {} $dbuser]) && (![string equal {} $dbpass])} {
			if {[string equal [encpass $msgpass] $dbpass]} {
				putserv "PRIVMSG $ichan :\[\002INVITE\002\] Inviting '$dbuser' with irc nick '$nick' to channel."
				putserv "INVITE $nick $ichan"
			} else {
				putlog "\[\002INVITE FAILED\002\] IRC nick '$nick' attempted to invite as '$dbuser' and failed!"
				putserv "PRIVMSG $ichan :\[\002INVITE FAILED\002\] IRC nick '$nick' attempted to invite as '$dbuser' and failed!"
				putserv "PRIVMSG $nick :\[\002ERROR\002\] Sorry, invalid username or password, please try again (attempt logged)"
				putserv "PRIVMSG $nick :\002*******\002 Remember, username and password are case sensitive."
				return
			}
		} else {
			putlog "\[\002INVITE FAILED\002\] IRC nick '$nick' attempted to invite as '$msguser' and failed!"
			putserv "PRIVMSG $nick :\[\002ERROR\002\] Syntax: /msg $::botnick $icmd <username> <password>"
			putserv "PRIVMSG $nick :*** Remember login and password are case sensitive."
		}
	}
	bind msg - $icmd ::invite::doinvite
}
package provide invite 0.1

#end script
putlog "public invite verion 0.1 by leprechau@EFNet loaded!"
