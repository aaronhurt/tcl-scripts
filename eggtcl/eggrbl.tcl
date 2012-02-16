## eggdrop extension designed to work with rblchk above both by me (leprechau@EFnet)
## initial release no support or documentation other than provided herein
##
## flags:
## .chanset #chan +\-rblchk -> enable or disable checking per channel
## .chanset #chan +\-rblmsgadmin -> enable or disable admin messages per channel
## .chanset #chan +\-rblmsguser -> enable or disable user messages per channel
## .chanset #chan rblwarn 1.0 -> set warning score per channel*
## .chanset #chan rblkick 1.0 -> set kick score per channel*
## .chanset #chan rblkban 1.0 -> set kick ban score per channel*
## 
## * these chansets will override settings in the script itself
##
## other options/settings described below
##
## NOTE: this script requres my rblchk package
## available at http://woodstock.anbcs.com/scripts/rblchk.tcl
##

if {[namespace exists ::eggrbl]} {namespace delete ::eggrbl}
namespace eval ::eggrbl {

	## begin settings ##

	variable scores; array set scores {
		warn 1.0
		kick 4.0
		kban 5.0
	}
	## points required for warning/kick/kick ban

	variable warntype "privmsg";
	## warning methond (privmsg or notice)
	## warnings only sent if channel is set +rblmsguser

	variable adminname "#leprechau";
	## nick of admin (or channel name) to send details of rblchecks to
	## only works if channel is set +rblchk and +rblmsgadmin

	variable kickmsg "Please see notice/message for more information."
	## message for the kick reason used when a user
	## scores at or above kick/kickban

	variable usertxttrim "0";
	## setting to trim TXT records returned from RBL servers
	## 0 = do not trim
	## 1 = trim all before url
	## 2 = trim url from txt
	## 3 = do not display TXT field
	## There is no point in setting this to '2' for user notices

	variable admintxttrim "0";
	## same settings as 'usertxttrim' but applies to the admin notices

	variable exemptflags "fo|fo";
	## users with the above flags are exempt from checks
	## set to "" to disable exemptions

	##variable banstring "NICK!IDENT@HOST"
	##variable banstring "*!IDENT@HOST"
	variable banstring "*!*@HOST"
	## the format of the ban to set on hosts which match or exceed
	## the set ban score... strings are replaced with thier real values
	## available strings are: NICK IDENT HOST (must be uppercase)
	## all other characters are ignored and passed untouched

	## end settings ##

	## make sure rblchk.tcl is loaded
	package require rblchk 1.1

	## set udefs and vars
	setudef flag rblchk
	setudef flag rblmsgadmin
	setudef flag rblmsguser
	variable version 1.1

	## handle warning of users
	proc warn {details total uhost ip nick chan warn kick kban} {
		switch -exact -- $::eggrbl::warntype {
			privmsg {set type PRIVMSG}
			notice {set type NOTICE}
			default {set type PRIVMSG}
		}
		if {[channel get $chan rblmsguser]} {
			puthelp "$type $nick :[lindex [split $uhost {@}] end] \($ip\) appears in the following dns black list(s)."
			foreach line $details {
				foreach {score rbl desc txts} $line {
					set txt [lindex $txts 0]; switch -exact -- $::eggrbl::usertxttrim {
						1 {regsub -all -- {^.*http://} $txt {http://} txt}
						2 {regsub -all -- {http://.*$} $txt {} txt}
						3 {set txt {}}
					}
					puthelp "$type $nick :\002$score\002 $rbl \002$desc\002 $txt"
				}
			}
			puthelp "$type $nick :\002TOTAL\002: $total (warning $warn / kick $kick / kban $kban)"
		}
		if {[channel get $chan rblmsgadmin]} {
			puthelp "PRIVMSG $::eggrbl::adminname :RBL \002$nick!$uhost\002 \($ip\) in \002$chan\002 scored \002$total\002 point(s)."
			foreach line $details {
				foreach {score rbl desc txts} $line {
					set txt [lindex $txts 0]; switch -exact -- $::eggrbl::admintxttrim {
						1 {regsub -all -- {^.*http://} $txt {http://} txt}
						2 {regsub -all -- {http://.*$} $txt {} txt}
						3 {set txt {}}
					}
					puthelp "PRIVMSG $::eggrbl::adminname :\002$score\002 $rbl \002$desc\002 $txt"
				}
			}
		}
	}

	## check users score and take appropriate action
	proc getscore {uhost nick chan ip details total} {
		## load the script defaults
		foreach name [array names ::eggrbl::scores] { set [set name] $::eggrbl::scores($name) }
		## override if channel sets are present
		foreach x [list warn kick kban] {
			if {[string length [set cset [channel get $chan rbl$x]]]} {set [set x] $cset}
		}
		if {($total == 0) || ($total < $warn)} {return} elseif {($total >= $warn) && ($total < $kick)} {
			putlog "RBL \002$nick!$uhost\002 \($ip\) scored \002$total\002 points in \002$chan\002 \(warn $warn kick $kick kban $kban\)"
			::eggrbl::warn $details $total $uhost $ip $nick $chan $warn $kick $kban
		} elseif {($total >= $kick) && ($total < $kban)} {
			putlog "RBL \002$nick!$uhost\002 \($ip\) scored \002$total\002 points in \002$chan\002 \(warn $warn kick $kick kban $kban\)"
			if {[isop $::botnick $chan]} {
				putserv "KICK $chan $nick :(rblchk) $::eggrbl::kickmsg"
			} else {putlog "RBL Wanted to kick \002$nick!$uhost\002 on \002$chan\002 but I do not have ops there."}
			::eggrbl::warn $details $total $uhost $ip $nick $chan $warn $kick $kban
		} elseif {($total >= $kban)} {
			putlog "RBL \002$nick!$uhost\002 \($ip\) scored \002$total\002 points in \002$chan\002 \(warn $warn kick $kick kban $kban\)"
			if {[isop $::botnick $chan]} {
				foreach {ident host} [split $uhost {@}] {continue}
				putserv "MODE $chan +b [string map [subst -nocommands -nobackslashes {NICK $nick IDENT $ident HOST $host}] $::eggrbl::banstring]"
				putserv "KICK $chan $nick :(rblchk) $::eggrbl::kickmsg"
			} else {putlog "RBL Wanted to kickban \002$nick!$uhost\002 on \002$chan\002 but I do not have ops there."}
			::eggrbl::warn $details $total $uhost $ip $nick $chan $warn $kick $kban
		} else {putlog "RBL ERROR: Cannot determine proper action from total score \($total\)"; return}
	}

	## get users host on join and pass it off to be scanned and scored
	proc onjoin {nick uhost hand chan} {
		if {(![channel get $chan rblchk]) || ([string equal -nocase $nick $::botnick]) || \
		((![string equal {} $::eggrbl::exemptflags]) && ([matchattr $nick $::eggrbl::exemptflags $chan]))} {return}
		::rblchk::score [lindex [split $uhost {@}] end] -callback [list ::eggrbl::getscore $uhost $nick $chan]
	}
	bind join - {* *!*@*} ::eggrbl::onjoin
}
package provide eggrbl $::eggrbl::version

putlog "rblchk v$::rblchk::version + eggrbl v$::eggrbl::version by leprechau@EFnet loaded!"

## EOF ##
