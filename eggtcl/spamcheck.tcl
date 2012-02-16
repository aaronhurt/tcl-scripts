## spam prevention/bad words type script
## initial version no documentation or support
## other than provided herein
##
## by leprechau@EFnet
##
## channel settings: .chanset #chan +/-spamcheck
## ^- toggle checking of user text
##
## other settings detailed below
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::spamCheck {

	## begin settings ##

	variable scores; array set scores {
		warn 1.0
		kick 4.0
		kban 5.0
	}
	## points required for warning/kick/kick ban

	variable wordlist; array set wordlist {
		b??tb?x 4.0
		r?pe 4.0
		#* 4.0
		f??k 4.0
		j?in 1.0
		s?x 4.0
		f?ee 2.0
		xxx 5.0
	}
	## word list and values associated with each word
	## use lowercase...wildcards (* and ?) accepted

	variable warntype "privmsg";
	## warning method (privmsg or notice)

	variable adminname "#leprechau"
	## message admin with script actions
	## may be a channel name or irc nick
	## set to "" to disable admin messages

	variable exemptflags "fo";
	## users with the above flags are exempt from checks
	## set to "" to disable exemptions
	## setting is: global flags|channel flags

	##variable banstring "NICK!IDENT@HOST"
	##variable banstring "*!IDENT@HOST"
	variable banstring "*!*@HOST"
	## the format of the ban to set on hosts which match or exceed
	## the set ban score... strings are replaced with thier real values
	## available strings are: NICK IDENT HOST (must be uppercase)
	## all other characters are ignored and passed untouched

	## end settings ##

	setudef flag spamcheck
	variable version 0.1

	proc warn {nick uhost chan utext total details} {
		switch -exact -- $::spamCheck::warntype {
			privmsg {set type PRIVMSG}
			notice {set type NOTICE}
			default {set type PRIVMSG}
		}
		## shorten our var names for easy coding
		foreach name [array names ::spamCheck::scores] {set [set name] $::spamCheck::scores($name)}
		## warn em
		puthelp "$type $nick :\[SPAMCHECK\]: Your last text scored \002$total\002 total points. (warning $warn kick $kick kban $kban\)"
		## if are are messaging our admin also...let's do it
		if {[string length $::spamCheck::adminname]} {
			puthelp "PRIVMSG $::spamCheck::adminname :\[SPAMCHECK\] \002$nick!$uhost\002 in \002$chan\002 scored \002$total\002 point(s)."
			puthelp "PRIVMSG $::spamCheck::adminname :\[SPAMCHECK\] User text: $utext"
			foreach {word score} $details {puthelp "PRIVMSG $::spamCheck::adminname :\[SPAMCHECK\] Word: \002$word\002 Score: \002$score\002"}
		}; return
	}

	proc getScore {nick uhost chan utext} {
		## assign our values to shorter varnames
		foreach name [array names ::spamCheck::scores] {set [set name] $::spamCheck::scores($name)}
		## set a temptext that is sripped and lowered (make case insensitive)
		set tmpTxt [split [string tolower [stripcodes bcruag $utext]]]
		## cycle through the users text and compute the score
		set total 0; foreach word [array names ::spamCheck::wordlist] {
			if {[lsearch -glob $tmpTxt *[string tolower $word]*] != -1} {
				set total [expr {$total + $::spamCheck::wordlist($word)}]
				lappend details $word $::spamCheck::wordlist($word)
			}
		}
		if {($total == 0) || ($total < $warn)} {return} elseif {($total >= $warn) && ($total < $kick)} {
			putlog "\[SPAMCHECK\] \002$nick!$uhost\002 scored \002$total\002 points in \002$chan\002 \(warn $warn kick $kick kban $kban\)"
			::spamCheck::warn $nick $uhost $chan $utext $total $details
		} elseif {($total >= $kick) && ($total < $kban)} {
			putlog "\[SPAMCHECK\] \002$nick!$uhost\002 scored \002$total\002 points in \002$chan\002 \(warn $warn kick $kick kban $kban\)"
			if {[isop $::botnick $chan]} {
				putserv "KICK $chan $nick :(spamcheck) See notice/message for more information."
			} else {putlog "\[SPAMCHECK\] Wanted to kick \002$nick!$uhost\002 on \002$chan\002 but I do not have ops there."}
			::spamCheck::warn $nick $uhost $chan $utext $total $details
		} elseif {($total >= $kban)} {
			putlog "\[SPAMCHECK\] \002$nick!$uhost\002 scored \002$total\002 points in \002$chan\002 \(warn $warn kick $kick kban $kban\)"
			if {[isop $::botnick $chan]} {
				foreach {ident host} [split $uhost {@}] {continue}
				putserv "MODE $chan +b [string map [subst -nocommands -nobackslashes {NICK $nick IDENT $ident HOST $host}] $::spamCheck::banstring]"
				putserv "KICK $chan $nick :spamcheck v$::spamCheck::version"
			} else {putlog "\[SPAMCHECK\] Wanted to kickban \002$nick!$uhost\002 on \002$chan\002 but I do not have ops there."}
			::spamCheck::warn $nick $uhost $chan $utext $total $details
		} else {putlog "\[SPAMCHECK\] ERROR: Cannot determine proper action from total score \($total\)"; return}
	}

	proc onText {nick uhost hand chan text} {
		if {(![channel get $chan spamcheck]) || ([string equal -nocase $nick $::botnick]) || \
		((![string equal {} $::spamCheck::exemptflags]) && ([matchattr $hand $::spamCheck::exemptflags $chan]))} {return}
		::spamCheck::getScore $nick $uhost $chan $text
	}
	bind pubm - * ::spamCheck::onText
}

putlog "spamcheck v$::spamCheck::version by leprechau@EFnet loaded!"

## EOF ##
