## simple channel ad bot
##
## by leprechau@EFnet
##
## this script is a complete re-write
## of the much much older script of the same name
## that used to reside in this same webspace
##
## initial version...no documentation or support
## other than what is provided herein
##
## channel settings:
## 
## .chanset #channel +/-chanads
## ^- toggle advertisements to given channel
## 
## dcc/pub/msg commands:
##
## .chanad <add|del|list|say> ?text?
## ^- just typing '.chanad add' will give you more
## information on that specific function 
##
## no other settings / commands available
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::chanad {
	
	## user settings ##
	
	set datafile "/home/ahurt/lepster/text/chanads.db"
	# the name and path of your chanad file
	
	set tagit "0"
	# set to 1 to enable appending the nick/date/time
	# information to the end of the advertisement
	
	set uflag "o"
	## flag required to use the dcc/pub/msg commands
	## this is a global flag requirement with the exception
	## of the pub bind where it will accept channel flag also
	
	## end script settings ##
	
	## script version num
	variable version "0.1"
	
	## user defines
	setudef flag chanads
	
	## our data array...everything we do is stored here
	variable Data; array set Data [list]
	
	## startup and init
	if {![file isfile $::chanad::datafile]} {
		putlog "\[\002ERROR\002\] File '$::chanad::datafile' does not exist!"
		putlog "A new file will be created."
	} else {
		putlog "Loading chanad database..."
		source $::chanad::datafile
		putlog "Done, [array size ::chanad::Data] ad(s) loaded!"
	}
	
	## write data array to file
	proc writeData {} {
		if {[catch {set fid [open $::chanad::datafile w]} oError] != 0} {
			return -code error "Could not open '$::chanad::datafile' for writing:  $oError"
		}
		if {[catch {puts $fid "array set ::chanad::Data \{[array get ::chanad::Data]\}"} pError] != 0} {
			return -code error "Error writing to $::chanad::datafile\:  $pError"
		}
		if {[catch {close $fid} cError] != 0} {
			return -code error "Error closing $::chanad::datafile\:  $cError"
		}
	}
	
	## display ads for all channels when they are set to show
	proc doAds {min hr day mnt yr} {
		foreach chan [channels] {
			if {![channel get $chan chanads]} {continue}
			if {![string length [set ads [array get ::chanad::Data [string tolower $chan],*]]]} {continue}
			foreach {name value} $ads {
				foreach {chan uid delay} [split $name {,}] {break}
				if {[expr {[clock seconds] - [lindex $value 0]}] >= [expr {$delay * 60}]} {
					puthelp "PRIVMSG $chan :[set adtxt [lindex $value end]]"
					array set ::chanad::Data [list $name [list [clock seconds] $adtxt]]; continue
				}
			}
		}
	}
	bind time - "* * * * *" ::chanad::doAds

	## create new ads
	proc newAd {chan delay txt} {
		## generate a unique id for this ad
		set uid [join [regexp -all -inline -- {[A-Za-z]+} [encpass $chan\,$txt\,[clock seconds]]] {}]
		array set ::chanad::Data [list $chan,$uid,$delay [list [clock seconds] $txt]]; ::chanad::writeData
	}
	
	## remove ads
	proc remAd {uid} {
		array unset ::chanad::Data *,$uid,*; ::chanad::writeData
	}
	
	## user command handler (universal for all binds...no repeat code)
	proc userCmds {txt} {
		switch -glob -- [lindex [split [string tolower $txt]] 0] {
			ad* {
				## syntax checking
				if {([string length [set chan [string tolower [lindex [split $txt] 1]]]]) && (![validchan $chan])} {
					return [list "\002Error\002: I couldn't find any channel named \'$chan\' in my channel list."]
				} elseif {(![string length $chan]) || (![string length [set delay [lindex [split $txt] 2]]]) || \
				(![string is int $delay]) || (![string length [set adtxt [join [lrange [split $txt] 3 end]]]])} {
					return [list "\002Usage\002: .chanad add \<#chan\> \<delay\> \[channel advertisement text here\]" \
					"\002Example\002: .chanad add #blargs 15 If you wait 15 minutes you will see this again."]
				}
				## guess we passed..let's do it
				::chanad::newAd $chan $delay [subst -nocommands -novariables $adtxt]
				return [list "Advertisement for '$chan' added succesfully!"]
			}
			de* {
				## more syntax checking here
				if {(![string length [set uid [lindex [split $txt] 1 ]]])} {
					return [list "\002Usage\002: .chanad del \<id\>" \
					"\002Example\002: .chanad del eQNnzWpUf"]
				} elseif {(![string length [array get ::chanad::Data *,$uid,*]])} {
					return [list "\002Error\002: Sorry, I couldn't find that ad id \($uid\) in my database"]
				}
				## once again...we passed..weeeee
				::chanad::remAd $uid; return [list "Advertisement id '$uid' deleted succesfully!"]
			}
			li* {
				## cycle through our array and make the output pretty for the user
				foreach name [lsort -dictionary -increasing [array names ::chanad::Data]] {
					foreach {chan uid delay} [split $name {,}] {break}
					lappend outs "\002ID\002: $uid \002Chan\002: $chan \002Delay\002: $delay \
					\002Text\002: [lindex $::chanad::Data($name) end]"
				}; if [info exists outs] {return $outs} else {return [list "There are currently no ads to list."]}
			}
			sa* {
				## and syntax checking yet again for this command
				if {([string length [set chan [string tolower [lindex [split $txt] 1]]]]) && (![validchan $chan])} {
					return [list "\002Error\002: I couldn't find any channel named \'$chan\' in my channel list."]
				} elseif {(![string length $chan]) || (![string length [set adtxt [join [lrange [split $txt] 2 end]]]])} {
					return [list "\002Usage\002: .chanad say \<#chan\> \[channel advertisement text here\]" \
					"\002Example\002: .chanad say #blargs Say this text right now and do not store it"]
				}
				## alright...let's spit it out
				puthelp "PRIVMSG $chan :$adtxt"; return [list "Said \'$adtxt\' to \'$chan\'"]
			}
			default {return [list "\002Usage\002: .chanad <add|del|list|say> ?text?"]}
		}
	}
	
	## dcc command relay
	proc dccHandler {hand idx txt} {
		putcmdlog "\# $hand $::lastbind $txt \#"
		foreach line [::chanad::userCmds $txt] {
			putdcc $idx $line
		}
	}
	bind dcc $::chanad::uflag chanad ::chanad::dccHandler
	
	## msg command relay
	proc msgHandler {nick uhost hand txt} {
		putcmdlog "\# $nick $::lastbind $txt \#"
		foreach line [::chanad::userCmds $txt] {
			puthelp "PRIVMSG $nick :$line"
		}
	}
	bind msg $::chanad::uflag .chanad ::chanad::msgHandler

	## pub command relay
	proc pubHandler {nick uhost hand chan txt} {
		putcmdlog "\# $nick@$chan $::lastbind $txt \#"
		foreach line [::chanad::userCmds $txt] {
			puthelp "PRIVMSG $nick :$line"
		}
	}
	bind pub $::chanad::uflag\|$::chanad::uflag .chanad ::chanad::pubHandler
}
putlog "chanad.tcl v$::chanad::version by leprechau@efnet loaded."

## EOF ##