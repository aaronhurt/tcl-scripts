## custom script for rodb@EFNet
## 02.25.04

namespace eval ::chantools {
	variable notnick "rodb"
	## nickname to send notices to
	variable pubcmd ".unban"
	## public/message command to remove last ban
	variable pubcmd2 ".autoop"
	## public/message command to set +/-autoop +/-autovoice +/-autohalfop
	variable btime "300"
	## maximum age of ban that will be removed in seconds
	variable uflags "o|o"
	## flags needed to use public unban
	variable cshost "ChanServ!Services@Outsiderz.Com"
	## chanserv hostmask (must be in nick!ident@host format)
	variable csmodes "+o +v +h"
	## modes to watch chanserv for (space seperated list)

	proc modeWatch {nick uhost hand chan mode vict} {
		variable cshost;variable notnick
		if {![string match -nocase $cshost $nick!$uhost]} {return}
		if {(![validuser $vict]) && (![validuser $hand])} {
			putserv "NOTICE $notnick :\[\002INFO\002\] $nick!$uhost gave $vict $mode on $chan, but $vict is not in my userlist."
			return
		} elseif {(![validuser $vict]) && ([validuser $hand])} {
			putserv "NOTICE $notnick :\[\002INFO\002\] $nick!$uhost gave $vict $mode on $chan, but $vict is known to me as $hand."
			if {![matchattr $hand $mode|$mode $chan]} {
				putserv "NOTICE $notnick :\[\002INFO\002\] $nick!$uhost gave $vict ($hand) $mode on $chan, but $vict ($hand) is not $mode in my userlist."
			}
			return
		}
		set vhost $vict![getchanhost $vict $chan]
		foreach x [getuser $vict HOSTS] {
			if {[string match -nocase $x $vhost]} {return}
		}
		addhost $vict $vhost
		putlog "\[\002ADD HOST\002\] Added host '$vhost' to '$vict' on $chan"
		if {![matchattr $vict $mode|$mode $chan]} {
			putserv "NOTICE $notnick :\[\002INFO\002\] $nick!$uhost gave $vict $mode on $chan, but $vict is not $mode in my userlist."
		}
	}
	foreach m $csmodes {bind mode - "* $m" ::chantools::modeWatch}

	proc pubClearBan {nick uhost hand chan text} {
		variable btime
		foreach ban [chanbans $chan] {lappend blist [list [lindex $ban end] [lindex $ban 0]]}
		foreach ban [banlist $chan] {lappend blist [list [expr {[unixtime] - [lindex $ban 3]}] [lindex $ban 0]]}
		if {([info exists blist]) && ([lindex [set ban [lindex [lsort -dictionary $blist] 0]] 0] <= $btime)} {
			putserv "MODE $chan -b [lindex $ban end]"
			catch {killchanban $chan [lindex $ban end]}
			putlog "\[\002CLEAR BAN\002\] Cleared ban [lindex $ban end] from $chan by request of $nick on $chan"
		}
	}
	bind pub $uflags $pubcmd ::chantools::pubClearBan

	proc msgClearBan {nick uhost hand text} {
		variable pubcmd
		if {(![string equal {} $text]) && (![string equal "\#" [string index $text 0]])} {set text \#$text}
		if {([string equal {} $text]) || (![validchan $text])} {
			putserv "NOTICE $nick :\[\002ERROR\]\002 You must specify a channel name: /msg $::botnick $pubcmd #channel"
			return
		}
		::chantools::pubClearBan $nick $uhost $hand $text -
	}
	bind msg $uflags $pubcmd ::chantools::msgClearBan

	proc pubCheckAutoModes {nick uhost hand chan text} {
		variable notnick
		foreach mode {autoop autovoice autohalfop} {
			if {[channel get $chan $mode]} {
				channel set $chan -$mode;lappend modelist -$mode
			} else {
				channel set $chan +$mode;lappend modelist +$mode
			}
		}
		putlog "\[\002MODE CHANGE\002\] Changed modes on $chan to [join $modelist] by request of $nick on $chan"
		putserv "NOTICE $nick :\[\002INFO\002\] Modes for $chan now [join $modelist]"
		if {![string equal -nocase $nick $notnick]} {
			putserv "NOTICE $notnick :\[\002INFO\002\] Modes for $chan now [join $modelist]"
		}
	}
	bind pub $uflags $pubcmd2 ::chantools::pubCheckAutoModes

	proc msgCheckAutoModes {nick uhost hand text} {
		variable pubcmd2
		if {(![string equal {} $text]) && (![string equal "\#" [string index $text 0]])} {set text \#$text}
		if {([string equal {} $text]) || (![validchan $text])} {
			putserv "NOTICE $nick :\[\002ERROR\]\002 You must specify a channel name: /msg $::botnick $pubcmd2 #channel"
			return
		}
		::chantools::pubCheckAutoModes $nick $uhost $hand $text -
	}
	bind msg $uflags $pubcmd2 ::chantools::msgCheckAutoModes

}
putlog "Simple channel tools v0.2 loaded"
