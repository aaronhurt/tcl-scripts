## chanlink.tcl v0.3 by leprechau@EFnet
## initial version...no documentation or support
## besides what is provided herein...this can be used
## to link channels on the same or different networks
## 
##
## channel settings:
## .chanset #channel +/-linkchan
## ^-- set #channel linking on or off
##
## .chanset #channel linktarget #channel@botname #channel2@botname
## ^-- multiple channels are optional...only one required...botname
## may be the same as current bot or any other linked bot
##
## .chanset #channel linktypes actions joins modes nicks kicks parts chats rejoins quits splits topics
## ^-- tell the script what to relay from given channel
## an empty string OR no setting defaults to all types
## 
##
## that's it...nothing to edit or configure 
##
## NOTE: if you want/need encrypted channel support
## check my encrypted_channels.tcl in this same webspace
## http://woodstock.anbcs.com/encrypted_channels.tcl
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::chanLink {
	## define our channel flags/strings
	setudef flag linkchan; setudef str linktarget; setudef str linktypes
	## do the relaying
	proc relayText {frm cmd txt} {
		foreach {net target text} $txt {break}
		## make sure we have network set in our eggdrop.conf
		if {![info exists ::network] || ![string length $::network]} {set ::network NULL}
		if {[validchan $target]} {
			## if this message came from a different network...let's tag it on the front of our text
			if {![string equal $net NULL] && ![string equal [string tolower $net] [string tolower $::network]]} {
				puthelp "PRIVMSG $target :\[$net\] $text"
			} else {puthelp "PRIVMSG $target :$text"}
		} else {putlog "\[\002ERROR\002\] Invalid channel \'$target\' ... cannot relay."; return}
	}
	bind bot - relayText ::chanLink::relayText

	## a bit of processing and a couple error checks
	proc getText {txt} {
		foreach {type chan text} $txt {break}
		if {([string length [set types [split [channel get $chan linktypes]]]]) && \
		([lsearch -glob $types $type] == -1)} {return}
		if {(![channel get $chan linkchan]) || (![string length [set targets [channel get $chan linktarget]]])} {return}
		foreach target $targets {
			foreach {Ltarget Lbot} [split $target {@}] {break}
			if {[string equal -nocase $Lbot ${::botnet-nick}]} {
				::chanLink::relayText - - [list $Ltarget $text]
			} elseif {[islinked $Lbot]} {
				## make sure we have network set in our eggdrop.conf
				if {![info exists ::network] || ![string length $::network]} {set ::network NULL}
				## send it to our relay bot...
				putbot $Lbot "relayText [list $::network $Ltarget $text]"
			} else {putlog "\[\002ERROR\002\] Relay from \'$Ltarget\' through \'$Lbot\' failed: \'$Lbot\' not found."; return}
		}
	}

	## pass actions
	proc bindAct {nick uhost hand dest keywd text} {
		::chanLink::getText [list act* $dest "* $nick $text"]
	}
	bind ctcp - "ACTION" ::chanLink::bindAct
	
	## pass joins
	proc bindJoin {nick uhost hand chan} {
		::chanLink::getText [list joi* $chan "*** $nick \($uhost\) has joined $chan"]
	}
	bind join - * ::chanLink::bindJoin

	## pass modes
	proc bindMode {nick uhost hand chan mode targ} {
		## handle server modes
		if {![string length $nick]} {set nick $uhost}
		## pass it on to get checked and relayed
		::chanLink::getText [list mod* $chan "*** $nick sets mode $mode $targ"]
	}
	bind mode - * ::chanLink::bindMode

	## pass nick changes
	proc bindNick {nick uhost hand chan new} {
		::chanLink::getText [list nic* $chan "*** $nick is now known as $new"]
	}
	bind nick - * ::chanLink::bindNick
	
	## pass kicks
	proc bindKick {nick uhost hand chan targ rsn} {
		::chanLink::getText [list kic* $chan "*** $targ was kicked by $nick \($rsn\)"]
	}
	bind kick - * ::chanLink::bindKick

	## pass parts
	proc bindPart {nick uhost hand chan {msg {}}} {
		if {![string length $msg]} {
			::chanLink::getText [list par* $chan "*** $nick \($uhost\) has left $chan \($msg\)"]
		} else {::chanLink::getText [list par* $chan "*** $nick \($uhost\) has left $chan"]}
	}
	bind part - * ::chanLink::bindPart

	## pass channel messages
	proc bindPubm {nick uhost hand chan text} {
		::chanLink::getText [list cha* $chan "\($nick\) $text"]
	}
	bind pubm - * ::chanLink::bindPubm

	## pass on rejoins (after splits)
	proc bindRejn {nick uhost hand chan} {
		::chanLink::getText [list rej* $chan "*** $nick has been found through the netsplit"]
	}
	bind rejn - * ::chanLink::bindRejn

	## pass signoffs
	proc bindSign {nick uhost hand chan rsn} {
		::chanLink::getText [list qui* $chan "*** $nick \($uhost\) Quit \($rsn\)"]
	}
	bind sign - * ::chanLink::bindSign

	## pass netsplits
	proc bindSplt {nick uhost hand chan} {
		::chanLink::getText [list spl* $chan "*** $nick was lost in a netsplit"]
	}
	bind splt - * ::chanLink::bindSplt

	## pass on topic changes
	proc bindTopc {nick uhost hand chan topic} {
		::chanLink::getText [list top* $chan "*** $nick changes topic on $chan to \'$topic\'"]
	}
	bind topc - * ::chanLink::bindTopc
}
putlog "chanlink.tcl v0.3 by leprechau@EFnet loaded."