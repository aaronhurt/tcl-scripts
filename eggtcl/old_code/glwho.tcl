##################################################
## glftpd public who script version 1.2         ##
## Wednesday, December 31, 2002                 ##
##################################################
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

## short name for your site
set glwho(sname) "site"

## character that designates a command
## prepended to site name (set to "" for none)
set glwho(cmdpre) "!site"

## complete path to sitewho
set glwho(binary) "/glftpd/bin/sitewho"

## restrict command to certain individuals
## 0 == no / 1 == only show to +flag set below
set glwho(restrict) 1

## flag to use in restrict above
set glwho(flag) o

##################################################
##          DO NOT EDIT THIS SCRIPT             ##
##         DOING SO IS NOT SUPPORTED            ##
##################################################
set glwho_ver "1.4"

proc glwho_dn { nick uhost hand chan text } {
global glwho alltools_loaded
	if {($glwho(restrict) == 1) && (![matchattr $hand $glwho(flag)|$glwho(flag) $chan])} {
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002DN\002\] \- Sorry, you do not have access to use this command." ; return
	}
	if {[catch {set who [open |$glwho(binary)]} open_error] != 0} {
		putlog "\[\002ERROR\002\] Error opening command pipe '$glwho(binary)'"
		putlog "\[\002ERROR\002\] $open_error"
		return
	}
	set displayed 0
	set dnlist {}
	while {![eof $who]} {
		gets $who line
		if {(![string equal {} $line]) && (![string equal {+} [string index $line 0]])} {
			set line [join [string map {\\ \\\\ \| {} \/ {}} $line]]
			if {[string equal {Dn:} [join [lindex [split $line] 2]]]} {
				lappend dnlist [join [lindex [split $line] 0]@[lindex [split $line] 1]([lindex [split $line] 3])]
				incr displayed
			}
		}
	}
	if {[catch {close $who} close_error] != 0} {
		putlog "\[\002ERROR\002\] Error closing command pipe '$glwho(binary)'"
		putlog "\[\002ERROR\002\] $close_error"
		return
	}
	if {![info exists alltools_loaded]} { set alltools_loaded 0 }
	if {$displayed == 0} {
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002DN\002\] \- No users currently leeching."
	} elseif {$alltools_loaded == 1} {
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002DN\002\] \- [join $dnlist]"
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002DN\002\] \- [number_to_number $displayed] user(s) currently leeching."
	} else {
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002DN\002\] \- $displayed user(s) currently leeching."
	}
}
bind pub - $glwho(cmdpre)\dn glwho_dn

proc glwho_up { nick uhost hand chan text } {
global glwho alltools_loaded
	if {($glwho(restrict) == 1) && (![matchattr $hand $glwho(flag)|$glwho(flag) $chan])} {
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002UP\002\] \- Sorry, you do not have access to use this command." ; return
	}
	if {[catch {set who [open |$glwho(binary)]} open_error] != 0} {
		putlog "\[\002ERROR\002\] Error opening command pipe '$glwho(binary)'"
		putlog "\[\002ERROR\002\] $open_error"
		return
	}
	set displayed 0
	set uplist {}
	while {![eof $who]} {
		gets $who line
		if {(![string equal {} $line]) && (![string equal {+} [string index $line 0]])} {
			set line [join [string map {\\ \\\\ \| {} \/ {}} $line]]
			if {[string equal {Up:} [join [lindex [split $line] 2]]]} {
				lappend uplist [join [lindex [split $line] 0]@[lindex [split $line] 1]([lindex [split $line] 3])]
				incr displayed
			}
		}
	}
	if {[catch {close $who} close_error] != 0} {
		putlog "\[\002ERROR\002\] Error closing command pipe '$glwho(binary)'"
		putlog "\[\002ERROR\002\] $close_error"
		return
	}
	if {![info exists alltools_loaded]} { set alltools_loaded 0 }
	if {$displayed == 0} {
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002UP\002\] \- No users currently contributing."
	} elseif {$alltools_loaded == 1} {
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002UP\002\] \- [join $uplist]"
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002UP\002\] \- [number_to_number $displayed] user(s) currently contributing."
	} else {
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002UP\002\] \- $displayed user(s) currently contributing."
	}
}
bind pub - $glwho(cmdpre)\up glwho_up

proc glwho_idle { nick uhost hand chan text } {
global glwho alltools_loaded
	if {($glwho(restrict) == 1) && (![matchattr $hand $glwho(flag)|$glwho(flag) $chan])} {
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002IDLE\002\] \- Sorry, you do not have access to use this command." ; return
	}
	if {[catch {set who [open |$glwho(binary)]} open_error] != 0} {
		putlog "\[\002ERROR\002\] Error opening command pipe '$glwho(binary)'"
		putlog "\[\002ERROR\002\] $open_error"
		return
	}
	set displayed 0
	set idlelist {}
	while {![eof $who]} {
		gets $who line
		if {(![string equal {} $line]) && (![string equal {+} [string index $line 0]])} {
			set line [join [string map {\\ \\\\ \| {} \/ {}} $line]]
			if {[string equal {Idle:} [join [lindex [split $line] 2]]]} {
				lappend idlelist [join [lindex [split $line] 0]@[lindex [split $line] 1]([lindex [split $line] 3])]
				incr displayed
			}
		}
	}
	if {[catch {close $who} close_error] != 0} {
		putlog "\[\002ERROR\002\] Error closing command pipe '$glwho(binary)'"
		putlog "\[\002ERROR\002\] $close_error"
		return
	}
	if {![info exists alltools_loaded]} { set alltools_loaded 0 }
	if {$displayed == 0} {
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002IDLE\002\] \- No users currently idling."
	} elseif {$alltools_loaded == 1} {
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002IDLE\002\] \- [join $idlelist]"
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002IDLE\002\] \- [number_to_number $displayed] user(s) currently idling."
	} else {
		putserv "PRIVMSG $chan :\-$glwho(sname)\- \[\002IDLE\002\] \- $displayed user(s) currently idling."
	}
}

bind pub - $glwho(cmdpre)\idle glwho_idle

proc glwho_all { nick uhost hand chan text } {
	putserv "PRIVMSG $chan :\[\002Contributers\002\]"
	glwho_up $nick $uhost $hand $chan $text
	putserv "PRIVMSG $chan :\[\002Leechers\002\]"
	glwho_dn $nick $uhost $hand $chan $text
	putserv "PRIVMSG $chan :\[\002Idlers\002\]"
	glwho_idle $nick $uhost $hand $chan $text
}

bind pub - $glwho(cmdpre)\who glwho_all

putlog "glwho.tcl v$glwho_ver by leprechau@efnet loaded."
