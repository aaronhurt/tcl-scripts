## handle interaction with agentruby.com
## it's a nice cheap way to get AI in your application
##
## initial version...no documentation or support
## other than provided herein
##
## by leprechau@Efnet
##
## commands:
##
#### on first usage for a person...
## ::agentruby::connect <userid> ?-command [list procname arg1 arg2 ...]? ?-timeout miliseconds?
## ^-- returns session id for this user
##
#### on all consecutive communication for a user
## ::agentruby::converse <sessionid> <text> ?-command [list procname arg1 arg2 ...]? ?-timeout miliseconds?
## ^-- returns session id
##
## ::agentruby::config ?-agentname <agentname>?
## ^-- configure the defaul state array
##     options: -agentname
##     change the agent name...default is Ruby
##
## ::agentruby::status <sessionid>
## ^-- returns 'ok' or error message
##
## ::agentruby::reply <sessionid>
## ^-- returns last reply from website
##
## ::agentruby::cleanup <sessionid>
## ^-- cleans session id from state array
##     WARNING: this will destroy the site sessions
##     and site assigned user/pass information
##     effectively loosing access to any learned info
##     for the given session
##
## ::agentruby::sids
## ^-- returns a list of all current session ids
##
## ::agentruby::sessionsave <filename>
## ^-- save current sessions to a file
##     returns 1 on success
##     NOTE: this only needs to be done
##     after a new user session is started
##
## ::agentruby::sessionload <filename>
## ^-- loads sessions from file
##     returns 1 on success
##
#
namespace eval ::agentruby {
	## site url...this shouldn't change
	##agentruby.com is now defunct, but agentruby lives on below...
	variable url http://agentruby.sfmoma.org:2001/
	
	## our state array..everything we store is in here
	## don't 'overwrite' this info if it already exists
	if {(![array exists ::agentruby::state]) || (![array size ::agentruby::state])} {
		variable state; array set state [list sessidID 0 agentname Ruby]
	}

	## script version...
	variable version 0.01

	## we will be using my http package in here
	## make sure you have version 0.31+
	package require lephttp 0.31

	## we also need the base64 package from tcllib
	## we use this to format our save file
	package require base64
}

## create sessids
proc ::agentruby::getsid {uid} {
	## attempt to create unique sessids
	## use a constantly increasing var plus time
	set sessid ar::[set uid [string tolower $uid]]::[expr {[incr ::agentruby::state(sessidID)] + [clock seconds]}]
	array set ::agentruby::state [list $sessid,uid $uid $sessid,status ok]; return $sessid
}

## get options from text
proc ::agentruby::getOpt {opts key text} {
	## make sure only valid options are passed
	foreach {opt val} $text {
		if {[lsearch -exact $opts $opt] == -1} {
			return -code error "Unknown option '$opt', must be one of: [join $opts {, }]"
		}
	}
	## return selected option
	if {[set index [lsearch -exact $text $key]] != -1} {
		return [lindex $text [expr {$index +1}]]
	} else {return {}}
}

## handle our callback if we had one...otherwise we are done
proc ::agentruby::outIt {sessid} {
	if {[string length [set cmd [::agentruby::getOpt {-command -timeout} -command $::agentruby::state($sessid,args)]]]} {
		catch {eval [linsert [set cmd] end $sessid]}
	}
}

## handle our web returns
proc ::agentruby::getIt {sessid token} {
	if {[catch {::lephttp::status $token} status] != 0} {return}
	if {![string equal -nocase {ok} $status]} {
		::lephttp::cleanup $token; switch -exact -- [string tolower $status] {
			timeout {
				array set ::agentruby::state [list $sessid,satus "Connection to $::agentruby::url timed out."]
			}
			default {
				array set ::agentruby::state [list $sessid,satus "Unknown error occured, server output of the error is as follows: $status"]
			}
		}; ::agentruby::outIt $sessid; return
	}
	## did we get cookies....if so store them...store these cookies...
	if {[string length [set cookies [::lephttp::header $token Set-Cookie:]]]} {
		if {[info exists ::agentruby::state($sessid,cookies)]} {
			concat ::agentruby::state($sessid,cookies) $cookies
		} else {array set ::agentruby::state [list $sessid,cookies $cookies]}
	}
	set data [split [::lephttp::data $token] \n]; ::lephttp::cleanup $token
	## do a little re-arranging...
	foreach line $data {append html [string trim $line]}
	if {![regexp -all -- {parent\.logo\.OnSpeakIt\(\"\s(.+?)\"\)\;} $html x reply]} {
		array set ::agentruby::state [list $sessid,satus "Unable to find correct reply text in website return"]
		::agentruby::outIt $sessid; return
	}
	## strip and cleanup our reply...also apply our agent name map
	set reply [string map -nocase [list Ruby $::agentruby::state(agentname)] [::lephttp::map [::lephttp::strip $reply]]]
	## remove the 'mood' lines that are in some of the webreplies
	regsub -all -- {\sbot_mood=\"(.+?)\"\;} $reply {} reply
	## store our reply in the state array...
	array set ::agentruby::state [list $sessid,reply [string trim $reply]]
	## call outIt for our callback..
	::agentruby::outIt $sessid; return
}

## come on...we are talking here...
proc ::agentruby::converse {sessid text args} {
	## make sure we have what we need before we get started
	if {![string length [array get ::agentruby::state $sessid,cookies]]} {
		array set ::agentruby::state [list $sessid,satus "Cannot continue...no cookies for session $sessid"]
		::agentruby::outIt $sessid; return
	}
	## store our args...incase we have anything in there
	array set ::agentruby::state [list $sessid,args $args]
	## continue on..check our args for timeout value...default to 10 secs
	if {![string length [set timeout [::agentruby::getOpt {-command -timeout} -timeout $args]]]} {
		set timeout 10000
	}
	## let's do it...build our cookie headers
	foreach ck $::agentruby::state($sessid,cookies) {lappend cookies Cookie: $ck}
	## connect and continue our conversation...
	::lephttp::geturl $::agentruby::url -timeout $timeout -query [::lephttp::formatQuery text $text] -headers $cookies -command [list ::agentruby::getIt $sessid]
	## return our sessid
	return $sessid
}

## the start of it all...
proc ::agentruby::connect {uid args} {
	set sessid [::agentruby::getsid $uid]
	## check for timeout value...default to 10 secs
	if {![string length [set timeout [::agentruby::getOpt {-command -timeout} -timeout $args]]]} {
		set timeout 10000
	}
	## store our args...incase we have anything in there
	array set ::agentruby::state [list $sessid,args $args]
	## do our initial connect to the site...
	::lephttp::fetch $::agentruby::url -timeout $timeout -command [list ::agentruby::getIt $sessid]
	## return our sessid
	return $sessid
}

## return website reply status
proc ::agentruby::status {sessid} {
	if {![string length [set status [array get ::agentruby::state $sessid,status]]]} {
		return -code error "Invalid sesion id '$sessid' specified"
	}; return [string tolower [lindex $status end]]
}

## return website reply
proc ::agentruby::reply {sessid} {
	if {![string length [set reply [array get ::agentruby::state $sessid,reply]]]} {
		return -code error "Invalid session id '$sessid' specified"
	}; return [lindex $reply end]
}

## cleanup session arrays...once it's cleaned it's GONE!!
proc ::agentruby::cleanup {sessid} {
	catch {array unset ::agentruby::state $sessid,*}
}

## configure the default state array
proc ::agentruby::config {args} {
	if {[llength $args]} {
		if {[string length [set agentname [::agentruby::getOpt {-agentname} -agentname $args]]]} {
			array set ::agentruby::state [list agentname $agentname]
		}
	} else {return [array get ::agentruby::state agentname]}
}

## list current session ids
proc ::agentruby::sids {} {
	if {[llength [set sids [array names ::agentruby::state ar::*]]]} {
		foreach sid $sids {lappend sessids [lindex [split $sid {,}] 0]}
		return [lsort -decreasing -dictionary -unique $sessids]
	} else {return {}}
}

## write current sessions to file
proc ::agentruby::sessionsave {fname} {
	if {[catch {set fid [open $fname w]} oError] != 0} {
		return -code error "could not open '$fname' for writing:  $oError"
	}
	puts $fid [::base64::encode [array get ::agentruby::state]]
	if {[catch {close $fid} cError] != 0} {
		return -code error "error closing channel $fid:  $cError"
	}; return 1
}

## load saved sessions from file
proc ::agentruby::sessionload {fname} {
	if {![file isfile $fname]} {return -code error "file '$fname' does not exist"}
	if {[catch {set fid [open $fname r]} oError] != 0} {
		return -code error "could not open '$fname' for reading:  $oError"
	}
	array set ::agentruby::state [::base64::decode [read $fid]]
	if {[catch {close $fid} cError] != 0} {
		return -code error "error closing channel $fid:  $cError"
	}; return 1
}

package provide agentruby $::agentruby::version
