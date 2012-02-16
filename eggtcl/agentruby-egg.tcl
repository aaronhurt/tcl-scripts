## eggdrop tcl using my agentuby package
## initial version...no documentation or support
## other than provided herein
##
## options: .chanset #chan +/-agentruby
##
## by leprechau@EFnet
##
#
namespace eval ::eggar {
	## set to whatever you want your
	## agent to be named...
	variable agentname "lepster"

	## location of our session save file
	variable sfile "/home/ahurt/lepster/scripts/misc/agentruby.save"

	## this is our version info
	## don't change this
	variable version "0.02"

	## make sure agentruby is loaded
	## get it from: http://woodstock.anbcs.com/scripts/tcl/agentruby.tcl
	package require agentruby

	## set a control flag
	setudef flag agentruby

	## configure agentruby with our name
	::agentruby::config -agentname $agentname
}

## wrap text neatly..we will use this later for our responses
proc ::eggar::wrapit {text {len 80}} {
	if {[string length $text] > $len} {
		set list [split $text]
		set x 0; set y 0
		for {set i 0} {$i <= [llength $list]} {incr i} {
			if {[string length [set tmp [join [lrange $list $x $y]]]] < $len} {
				incr y
			} else {
				lappend outs $tmp; set x [incr y]
			}
		}
		if {[info exists outs]} {
			if {[string length $text] != [string length [join $outs]]} {
				lappend outs $tmp
			}; return $outs
		}
	} else {return [list $text]}
}

## return agent session id for this host
proc ::eggar::getsession {host} {
	foreach sid [::agentruby::sids] {
		if {[string match -nocase *\:\:$host\:\:* $sid]} {return $sid}
	}; return {}
}

## handle the agentruby data
proc ::eggar::callback {type nick uhost chan text sessid} {
	## check our status...if not ok..show error and stop...
	if {![string equal ok [set status [::agentruby::status $sessid]]]} {
		putlog "\[AgentRuby\] Error: $status"; return
	}
	## if this is a new user...we should save our sessions
	if {[string equal new $type]} {
		if {[set status [::agentruby::sessionsave $::eggar::sfile]] != 1} {
			putlog "\[AgentRuby\] Error: $status"; return
		}
		## let's skip the general 'hello there type to me' junk and just pass back a real answer...
		::eggar::talk $nick $uhost - $chan $text; return
	}
	## well we are still going...that's good...show em what we got...and make sure it will fit on irc...
	foreach line [::eggar::wrapit "$nick, [::agentruby::reply $sessid]" 300] {puthelp "PRIVMSG $chan :$line"}
}

## our channel talk handler
proc ::eggar::talk {nick uhost hand chan text} {
	## make sure we are active on this channel...
	if {![channel get $chan agentruby]} {return}
	## check if we already have an established session for this person...
	if {![string length [set sessid [::eggar::getsession [maskhost $uhost]]]]} {
		## no session found...let's introduce ourselves...
		## the string map oddness is to prevent possible array get glob expansion later on
		::agentruby::connect [string map {{[} {?} {]} {?}} $nick!$uhost] -timeout 50000 -command [list ::eggar::callback new $nick $uhost $chan $text]
	} else {
		## looks like they have talked to us before...let's continue the conversation..remove the botname from the text
		::agentruby::converse $sessid [string map -nocase [list $::eggar::agentname Ruby] $text] \
		-timeout 5000 -command [list ::eggar::callback old $nick $uhost $chan $text]
	}
}
bind pub - ${::eggar::agentname} ::eggar::talk
bind pub - ${::eggar::agentname}: ::eggar::talk
bind pub - ${::eggar::agentname}, ::eggar::talk

proc ::eggar::init {sfile} {
	if {[file isfile $sfile]} {
		if {[set status [::agentruby::sessionload $sfile]] != 1} {
			putlog "\[AgentRuby\] Error: '$sfile' could not be loaded: $status"
		} else {putlog "Successfully loaded [llength [::agentruby::sids]] sessions from: $sfile"}
	}
}
::eggar::init $::eggar::sfile

putlog "agentruby-egg.tcl v$::eggar::version by leprechau@EFnet loaded!"
