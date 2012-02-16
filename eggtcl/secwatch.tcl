## unified security script
## version: 1.28
## last update: 02.05.2009
## by ahurt (leprechau@efnet)
##
#### NOTE: This script uses my http package
#### get it from: http://woodstock.anbcs.com/scripts/lephttp.tcl
#### and source it before this script in your eggdrop config
##
## dcc commands:
## .secwatch help -> show's this help menu
## .secwatch destroy [email] -> permanently destroy the account with given email address
## .secwatch users [pattern] -> show all user accounts matching given pattern
## .secwatch cleanup -> cleanup accounts with empty keyword lists
##
## message commands:
## /msg bot secwatch help -> show's this help menu
## /msg bot secwatch register [email password] -> register with the bot
## /msg bot secwatch unregister [email password] -> unregister from bot and destroy profile
## /msg bot secwatch getpass [email] -> send a new password to given email address
## /msg bot secwatch setpass [email oldpass newpass] -> set a new password for given email address
## /msg bot secwatch list [email password] -> show items associated with given email
## /msg bot secwatch add [email password item 1, item 2] -> add given items to watch list
## /msg bot secwatch remove [email password item 1, item 2] -> remove given items from watch list
##
## public commands:
## !symantec, !sophos, !sectrack, !packetstorm, !securiteam, !insecure, !secfocus !secunia
##
## additional commands:
## .chanset #channel +\-symantec +\-sophos +\-sectrack +\-packetstorm +\-securiteam +\-insecure +\-secfocus +\-secunia
##
## This script is a compilation and enhancement of the following standalone scripts below.
## These scripts are no longer maintained and should be considered deprecated.
## This script contains several enhancements and additional news sources than the scripts available below.
##
## insecurexml.tcl
## netsysrss.tcl (now defunct..support removed)
## packetstormxml.tcl
## secfocusxml.tcl
## securiteamrss.tcl
## sophosxml.tcl
## symantec.tcl
##

namespace eval ::secwatch {

	## begin user settings ##

	variable maxresults 5;
	## maximum results to display from public commands
	variable uinterval 15;
	## update interval in minutes (connection to remote urls)
	variable messagetarget "nick";
	## destination target for public commands ("nick" or "chan")
	variable filterreps 0;
	## do not post reply messages (0 == no 1 == yes)
	## this is only applied to the lists (insecure, secfocus, sectrack, securiteam)
	variable userprofiles 1;
	## allow users to create profiles (0 == no 1 == yes)
	variable userFile "/home/ahurt/secwatch/scripts/misc/secwatch-efnet.users";
	## complete path to userfile (only required if 'userprofiles' above is 1)
	variable mailer "sendmail";
	## outgoing email method ("smtp", "sendmail" or "none" (required if using 'userprofiles' above))
	variable sendmailpath "/usr/sbin/sendmail"
	## complete path to your sendmail binary (only required if using 'sendmail' above)
	variable smtphost ""
	## the ip:port of your smtp server (only required if using 'smtp' above)
	variable mailFrom "Security.Bot@Security.Bot"
	## the email address that should be used to send outgoing user alerts
	variable desctrim 150;
	## trim descriptions to this many characters for channel announcements (0 disables)
	variable components; array set components {
		insecure 1
		packetstorm 1
		secfocus 1
		sectrack 1
		secunia 1
		securiteam 1
		sophos 1
		symantec 1
	}
	## component array (0 == disabled 1 == enabled)
	## you should probably restart your bot to remove any stale binds
	## if you are changing these while the bot is running
	variable urls; array set urls {
		insecure-fdata "http://seclists.org/rss/fulldisclosure.rss"
		insecure-vdata "http://seclists.org/rss/vulnwatch.rss"
		insecure-ndata "http://www.infosecnews.org/isn.rss"
		packetstorm-data "http://packetstorm.linuxsecurity.com/whatsnew20.xml"
		secfocus-vdata "http://www.securityfocus.com/rss/vulnerabilities.xml"
		secfocus-ndata "http://www.securityfocus.com/rss/news.xml"
		sectrack-data "http://news.securitytracker.com/server/affiliate?6E905322AD64E004"
		secunia-adata "http://secunia.com/information_partner/vulnerabilities.rss"
		secunia-bdata "http://secunia.com/blog_rss/blog.rss"
		securiteam-data "http://www.securiteam.com/securiteam.rss"
		sophos-vdata "http://feeds.sophos.com/en/rss2_0-sophos-latest-viruses.xml"
		sophos-pdata "http://feeds.sophos.com/en/rss2_0-sophos-latest-puas.xml"
		symantec-vdata "http://securityresponse.symantec.com/avcenter/js/vir.js"
		symantec-tdata "http://securityresponse.symantec.com/avcenter/js/tools.js"
		symantec-adata "http://securityresponse.symantec.com/avcenter/js/advis.js"
	}
	## array of all urls used in this script...you may leave urls you are not using blank
	## NOTE: be sure to include your affiliate ID number for the RSS(04) feed at securitytracker.com

	## end user settings ##

	## get my http package from
	## http://woodstock.anbcs.com/scripts/lephttp.tcl
	package require lephttp

	## set version numbers
	variable numver 0128; variable comver 1.28
	## init our timer variable
	variable uinterval2 0
	## setup user profile storage arrays/files
	if {$::secwatch::userprofiles == 1} {
		variable userRecords; array set userRecords [list]
		variable userData; array set userData [list]
		if {![file isfile $::secwatch::userFile]} {
			putlog "\[\002ERROR\002\] File '$::secwatch::userFile' does not exist!"
			putlog "A new file will be created."
		} else {
			putlog "Loading secwatch user databse..."
			source $::secwatch::userFile
			putlog "Done, [array size ::secwatch::userRecords] users loaded!"
		}
	}
	## get our loaded components
	if {[info exists ::secwatch::LoadedComps]} {unset ::secwatch::LoadedComps}
	foreach {name value} [array get ::secwatch::components] {
		if {$value ==1} {lappend ::secwatch::LoadedComps "$name"}
	}; set ::secwatch::LoadedComps [lsort -increasing -dictionary $::secwatch::LoadedComps]

	## wrap text neatly
	proc wrapit {text {len 80}} {
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

	## generate semi random strings
	proc rands {len {pool {0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ}}} {
		for {set i 0} {$i < $len} {incr i} {
			set x [expr {int(rand()*[string length $pool])}]
			append rs [string index $pool $x]
		}
		if {[info exists rs]} {return $rs} else {return}
	}

	## check user pass
	proc authUsers {user pass} {
		if {[string equal $::secwatch::userRecords([string tolower $user]) [md5 $pass]]} {
			return {TRUE}
		} else {
			return {FALSE}
		}
	}

	## get users with matching records
	proc checkUsers {title link {desc {}}} {
		foreach {1email items} [array get ::secwatch::userData] {
			if {![string equal {} $desc]} {
				foreach 1item $items {
					if {[string match -nocase *[set 1item]* $title] || [string match -nocase *[set 1item]* $desc]} {
						lappend found $1email
					}
				}
			} else {
				foreach 1item $items {
					if {[string match -nocase *[set 1item]* $title]} {
						lappend found $1email
					}
				}
			}
		}
		if {[info exists found] && [llength $found]} {
			foreach 1email [lsort -unique $found] {
				set msgtxt {
					"[lindex [split $1email {@}] 0],"
					""
					"$title"
					"\t$desc"
					"\t>> $link <<"
					""
					"--SecurityBot"
				}
				foreach 1line $msgtxt {lappend msg [subst $1line]}
				::secwatch::doMail $1email [lindex [split $1email {@}] 0] $title $msg
			}
		}
	}

	## write user profile arrays
	proc writeUsers {} {
		if {[catch {set file [open $::secwatch::userFile w]} oError] != 0} {
			putlog "\[\002ERROR\002\] Could not open '$::secwatch::userFile' for writing:  $oError"; return
		}
		if {[catch {puts $file "array set ::secwatch::userRecords \{[array get ::secwatch::userRecords]\}"} pError] != 0} {
			putlog "\[\002ERROR\002\] Error writing to $file:  $pError"; return
		}
		if {[catch {puts $file "array set ::secwatch::userData \{[array get ::secwatch::userData]\}"} pError] != 0} {
			putlog "\[\002ERROR\002\] Error writing to $file:  $pError"; return
		}
		if {[catch {close $file} cError] != 0} {
			putlog "\[\002ERROR\002\] Error closing $file:  $cError"; return
		}
	}

	## handle smtp outbound socket
	proc smtpWrite {rcpt rcptfn subj msg header sock} {
		fileevent $sock writable {}; fconfigure $sock -buffering line
		if {[catch {puts $sock "mail from: $::secwatch::mailFrom\nrcpt to: $rcpt\ndata"} pError] != 0} {
			putlog "\[\002SecWatch\002\] Error writing to smtp socket($sock): $pError"; catch {close $sock}; return
		}
		if {[catch {puts $sock [join [concat $header $msg] \n]} pError] != 0} {
			putlog "\[\002SecWatch\002\] Error writing to command pipe: $pError"; catch {close $sock}; return
		}
		if {[catch {puts $sock ".\n\nquit\n"} pError] != 0} {
			putlog "\[\002SecWatch\002\] Error writing to smtp socket($sock): $pError"; catch {close $sock}; return
		}
		if {[catch {close $sock} cError] != 0} {
			putlog "\[\002SecWatch\002\] Error closing socket($sock): $cError"; catch {close $sock}; return
		}
	}
	## handle outgoing email
	proc doMail {rcpt rcptfn subj msg} {
		set headertxt {
			"From: \"Security Bot\" \<$::secwatch::mailFrom\>"
			"To: \"$rcptfn\" \<$rcpt\>"
			"Subject: $subj"
			"Date: [clock format [clock seconds] -format {%a, %d %b %Y %H:%M:%S -0000} -gmt 1]"
			"Mime-Version: 1.0"
			"Content-Type: text/plain; format=flowed"
			"X-Generator: secwatch.tcl v$::secwatch::comver ($::secwatch::numver) by leprechau@EFnet"
			""
		}
		foreach 1line $headertxt {lappend header [subst $1line]}
		switch -exact -- $::secwatch::mailer {
			sendmail {
				if {[catch {set fid [open "|$::secwatch::sendmailpath $rcpt" w+]} oError] != 0} {
					putlog "\[\002SecWatch\002\] Error opening command pipe: $oError"; catch {close $fid}; return
				}
				if {[catch {puts $fid [join [concat $header $msg] \n]} pError] != 0} {
					putlog "\[\002SecWatch\002\] Error writing to command pipe: $pError"; catch {close $fid}; return
				}
				if {[catch {close $fid} cError] != 0} {
					putlog "\[\002SecWatch\002\] Error closing command pipe: $cError"; catch {close $fid}; return
				}
			}
			smtp {
				foreach {host port} [split $::secwatch::smtphost {:}] {}
				if {[catch {set sock [socket -myaddr localhost -async $host $port]} oError] != 0} {
					putlog "\[\002SecWatch\002\] Error opening smtp socket: $oError"; catch {close $sock}; return
				}
				fileevent $sock writable [list ::secwatch::smtpWrite $rcpt $rcptfn $subj $msg $header $sock]
			}
			default {return}
		}
	}

	## user profile dcc commands
	proc secwatchDccCmds {hand idx text} {
		if {$::secwatch::userprofiles != 1} {
			putdcc $idx "Sorry, user profiles have been disabled on this bot.  Please enable them in the script and rehash the bot."; return
		}
		putcmdlog "# $hand $::lastbind [lindex [split $text] 0] #"
		switch -exact -- [string tolower [lindex [split $text] 0]] {
			help {
				set helptext [list \
					"\002secwatch.tcl v$::secwatch::comver ($::secwatch::numver) by leprechau@EFnet\002" \
					"\002DCC Commands:\002" \
					"\002.secwatch \002help\002  -> show's this help menu" \
					"\002.secwatch \002destroy \[email\]\002  -> permanently destroy the account with given email address" \
					"\002.secwatch \002users \[pattern\]\002  -> show all user accounts matching given pattern" \
					"\002.secwatch \002cleanup\002  -> cleanup accounts with empty keyword lists" \
					"\002Loaded Modules:\002 [join $::secwatch::LoadedComps {, }]"]
				foreach line $helptext {putdcc $idx $line}; return
			}
			destroy {
				if {![string equal {} [set email [lindex [split $text] 1]]]} {
					if {[string equal {} [array get ::secwatch::userRecords [string tolower $email]]]} {
						putdcc $idx "Sorry, I couldn't find any user record for '$email' ... no records destroyed."; return
					} else {
						array unset ::secwatch::userRecords [string tolower $email]
						array unset ::secwatch::userData [string tolower $email]; ::secwatch::writeUsers
						putdcc $idx "The email address '$email' was removed and the profile destroyed."; return
					}
				} else {putdcc $idx "Usage: .secwatch destroy <email>"; return}

			}
			users {
				if {[string equal {} [set mpat [lindex [split $text] 1]]]} {set mpat {*}}
				set i 0; foreach user [lsort -dictionary -increasing [array names ::secwatch::userRecords]] {
					putdcc $idx "[incr i]\) $user"
				}; return
			}
			cleanup {
				foreach user [lsort -dictionary -increasing [array names ::secwatch::userRecords]] {
					if {[string equal {} [array get ::secwatch::userData $user]]} {
						lappend removed $user; array unset ::secwatch::userRecords $user
						catch {array unset ::secwatch::userData $user}; ::secwatch::writeUsers
					}
				}
				if {[info exists removed]} {
					putdcc $idx "Successfully cleaned up [llength $removed] users: [join $removed {, }]"; return
				} else {putdcc $idx "Zero records cleaned, no users with empty keyword lists found."; return}
			}
			default {
				putdcc $idx "Usage: .secwatch <help|destroy|users|cleanup>"; return
			}
		}
	}
	bind dcc n secwatch ::secwatch::secwatchDccCmds

	## user profile message commands
	proc secwatchMsgCmds {nick uhost hand text} {
		if {$::secwatch::userprofiles != 1} {
			putserv "PRIVMSG $nick :Sorry, user profiles have been disabled on this bot.  Please ask a bot owner to enable them."; return
		}
		putcmdlog "# $nick $::lastbind [lindex [split $text] 0] #"
		switch -exact -- [string tolower [lindex [split $text] 0]] {
			help {
				set helptext {
					"\002secwatch.tcl v$::secwatch::comver ($::secwatch::numver) by leprechau@EFnet\002"
					"\002Message Commands:\002"
					"\002/msg $::botnick secwatch help\002  -> show's this help menu"
					"\002/msg $::botnick secwatch register \[email password\]\002  -> register with the bot"
					"\002/msg $::botnick secwatch unregister \[email password\]\002  -> unregister from bot and destroy profile"
					"\002/msg $::botnick secwatch getpass \[email\]\002  -> send a new password to given email address"
					"\002/msg $::botnick secwatch setpass \[email oldpass newpass\]\002  -> set a new password for given email address"
					"\002/msg $::botnick secwatch list \[email password\]\002  -> show items associated with given email"
					"\002/msg $::botnick secwatch add \[email password item 1, item 2\]\002  -> add given items to watch list"
					"\002/msg $::botnick secwatch remove \[email password item 1, item 2\]\002  -> remove given items from watch list"
					"\002Public Commands:\002"
				}
				foreach {name value} [array get ::secwatch::components] {
					if {$value ==1} {lappend tempComps "!$name"}
				}
				if {[info exists tempComps]} {lappend helptext "\002[join $tempComps {, }]\002"}
				foreach line $helptext {putserv "PRIVMSG $nick :[subst -nocommands $line]"}
			}
			register {
				if {![string equal {} [set email [lindex [split $text] 1]]] && ![string equal {} [set pass [lindex [split $text] 2]]]} {
					if {![string equal {} [array get ::secwatch::userRecords [string tolower $email]]]} {
						putserv "PRIVMSG $nick :Sorry, someone has already registered that email"
						putserv "PRIVMSG $nick :If you forgot your password try: /msg $::botnick secwatch getpass"; return
					}
					array set ::secwatch::userRecords [list [string tolower $email] [md5 $pass]]; ::secwatch::writeUsers
					putserv "PRIVMSG $nick :You are now registered under the following email/pass: $email/$pass"
				} else {
					putserv "PRIVMSG $nick :Usage: /msg $::botnick secwatch register <email> <pass>"
				}
			}
			unregister {
				if {![string equal {} [set email [lindex [split $text] 1]]] && ![string equal {} [set pass [lindex [split $text] 2]]]} {
					if {![string equal {} [array get ::secwatch::userRecords [string tolower $email]]]} {
						switch -exact -- [::secwatch::authUsers $email $pass] {
							TRUE {
								array unset ::secwatch::userRecords [string tolower $email]
								array unset ::secwatch::userData [string tolower $email]; ::secwatch::writeUsers
								putserv "PRIVMSG $nick :The email address '$email' was removed and the profile destroyed."; return
							}
							FALSE {
								putserv "PRIVMSG $nick :Sorry the given email/password combination does not match."
								putserv "PRIVMSG $nick :If you forgot your password try: /msg $::botnick secwatch getpass"; return
							}
						}
					} else {
						putserv "PRIVMSG $nick :Sorry, I could not find this email in my user database."
						putserv "PRIVMSG $nick :If this is your email you can register by doing: /msg $::botnick secwatch register <email> <pass>"; return
					}
				} else {
					putserv "PRIVMSG $nick :Usage: /msg $::botnick secwatch unregister <email> <pass>"
				}
			}
			getpass {
				if {![string equal {} [set email [lindex [split $text] 1]]]} {
					if {![string equal {} [array get ::secwatch::userRecords [string tolower $email]]]} {
						set newPass [::secwatch::rands 8]
						set msgtxt {
							"$nick,"
							""
							"Passwords are never stored in plain text so I cannot retrieve your original password.  However, I can reset it to a new random string."
							"Your new password will be: $newPass"
							"You may change it later by doing the following from IRC:"
							"		/msg $::botnick secwatch setpass <email> <old pass> <new pass>"
							""
							"--SecurityBot"
						}
						foreach 1line $msgtxt {lappend msg [subst -nocommands $1line]}
						::secwatch::doMail $email $nick "Password Reset Request" $msg
						array set ::secwatch::userRecords [list [string tolower $email] [md5 $newPass]]; ::secwatch::writeUsers
						putserv "PRIVMSG $nick :Your new password has been sent to '$email' please look for it shortly."; return
					} else {
						putserv "PRIVMSG $nick :Sorry, I could not find this email in my user database."
						putserv "PRIVMSG $nick :If this is your email you can register by doing: /msg $::botnick secwatch register <email> <pass>"; return
					}
				} else {
					putserv "PRIVMSG $nick :Usage: /msg $::botnick secwatch unregister <email> <pass>"
				}
			}
			setpass {
				if {![string equal {} [set email [lindex [split $text] 1]]] && ![string equal {} [set opass [lindex [split $text] 2]]] \
				&& ![string equal {} [set npass [lindex [split $text] 3]]]} {
					if {![string equal {} [array get ::secwatch::userRecords [string tolower $email]]]} {
						switch -exact -- [::secwatch::authUsers $email $opass] {
							TRUE {
								array set ::secwatch::userRecords [list [string tolower $email] [md5 $npass]]; ::secwatch::writeUsers
								putserv "PRIVMSG $nick :The password for '$email' has been chanced.  Please do not forget your password."; return
							}
							FALSE {
								putserv "PRIVMSG $nick :Sorry the given email/password combination does not match."
								putserv "PRIVMSG $nick :If you forgot your password try: /msg $::botnick secwatch getpass"; return
							}
						}
					} else {
						putserv "PRIVMSG $nick :Sorry, I could not find this email in my user database."
						putserv "PRIVMSG $nick :If this is your email you can register by doing: /msg $::botnick secwatch register <email> <pass>"; return
					}
				} else {
					putserv "PRIVMSG $nick :Usage: /msg $::botnick secwatch setpass <email> <old pass> <new pass>"
				}
			}
			list {
				if {![string equal {} [set email [lindex [split $text] 1]]] && ![string equal {} [set pass [lindex [split $text] 2]]]} {
					if {![string equal {} [array get ::secwatch::userRecords [string tolower $email]]]} {
						switch -exact -- [::secwatch::authUsers $email $pass] {
							TRUE {
								putserv "PRIVMSG $nick :The following keywords have been associated with $email: \
								[join [lindex [array get ::secwatch::userData [string tolower $email]] end] {, }]"; return
							}
							FALSE {
								putserv "PRIVMSG $nick :Sorry the given email/password combination does not match."
								putserv "PRIVMSG $nick :If you forgot your password try: /msg $::botnick secwatch getpass"; return
							}
						}
					} else {
						putserv "PRIVMSG $nick :Sorry, I could not find this email in my user database."
						putserv "PRIVMSG $nick :If this is your email you can register by doing: /msg $::botnick secwatch register <email> <pass>"; return
					}
				} else {
					putserv "PRIVMSG $nick :Usage: /msg $::botnick secwatch list <email> <pass>"
				}
			}
			add {
				if {![string equal {} [set email [lindex [split $text] 1]]] && ![string equal {} [set pass [lindex [split $text] 2]]] \
				&& ![string equal {} [set items [lrange [split $text] 3 end]]]} {
					if {![string equal {} [array get ::secwatch::userRecords [string tolower $email]]]} {
						switch -exact -- [::secwatch::authUsers $email $pass] {
							TRUE {
								foreach 1item [split $items {,}] {lappend newItems $1item; lappend ::secwatch::userData([string tolower $email]) [join $1item]}
								::secwatch::writeUsers; putserv "PRIVMSG $nick :The following keywords have been added to $email: [join $newItems {, }]"; return
							}
							FALSE {
								putserv "PRIVMSG $nick :Sorry the given email/password combination does not match."
								putserv "PRIVMSG $nick :If you forgot your password try: /msg $::botnick secwatch getpass"; return
							}
						}
					} else {
						putserv "PRIVMSG $nick :Sorry, I could not find this email in my user database."
						putserv "PRIVMSG $nick :If this is your email you can register by doing: /msg $::botnick secwatch register <email> <pass>"; return
					}
				} else {
					putserv "PRIVMSG $nick :Usage: /msg $::botnick secwatch add <email> <pass> item 1, item 2, item 3"
				}
			}
			remove {
				if {![string equal {} [set email [lindex [split $text] 1]]] && ![string equal {} [set pass [lindex [split $text] 2]]] \
				&& ![string equal {} [set items [lrange [split $text] 3 end]]]} {
					if {![string equal {} [array get ::secwatch::userRecords [string tolower $email]]]} {
						switch -exact -- [::secwatch::authUsers $email $pass] {
							TRUE {
								foreach 1item [split $items {,}] {
									set curItems [lsort -unique [lindex [array get ::secwatch::userData [string tolower $email]] end]]
									set index [lsearch -exact $curItems [join $1item]]
									array set ::secwatch::userData [list [string tolower $email] [lreplace $curItems $index $index]]
									lappend remItems $1item
								}
								::secwatch::writeUsers; putserv "PRIVMSG $nick :The following keywords have been removed from $email: [join $remItems {, }]"; return
							}
							FALSE {
								putserv "PRIVMSG $nick :Sorry the given email/password combination does not match."
								putserv "PRIVMSG $nick :If you forgot your password try: /msg $::botnick secwatch getpass"; return
							}
						}
					} else {
						putserv "PRIVMSG $nick :Sorry, I could not find this email in my user database."
						putserv "PRIVMSG $nick :If this is your email you can register by doing: /msg $::botnick secwatch register <email> <pass>"; return
					}
				} else {
					putserv "PRIVMSG $nick :Usage: /msg $::botnick secwatch remove <email> <pass> item 1, item 2, item 3"
				}
			}
			default {
				putserv "PRIVMSG $nick :Usage: /msg $::botnick secwatch <help|register|unregister|getpass|setpass|list|add|remove>"; return
			}
		}
	}
	bind msg - secwatch ::secwatch::secwatchMsgCmds

	## insecure specifics
	if {$::secwatch::components(insecure)} {
		setudef flag insecure

		variable insecure-fdata; array set insecure-fdata [list]
		variable insecure-fdata2; array set insecure-fdata2 [list]
		variable insecure-vdata; array set insecure-vdata [list]
		variable insecure-vdata2; array set insecure-vdata2 [list]
		variable insecure-ndata; array set insecure-ndata [list]
		variable insecure-ndata2; array set insecure-ndata2 [list]

		proc insecureCallback {type token} {
			if {[catch {::lephttp::status $token} status] != 0} {return}
			if {![string equal -nocase {ok} $status]} {
				switch -exact -- $status {
					timeout {
						putlog "\[\002INSECURE\002\] Timeout (60 seconds) on connection to server."
					}
					default {
						putlog "\[\002INSECURE\002\] Unknown error occured, server output of the error is as follows: $status"
					}
				}
				::lephttp::cleanup $token; return
			}
			array unset ::secwatch::[set type]2; array set ::secwatch::[set type]2 [array get ::secwatch::[set type]]; array unset ::secwatch::[set type]
			# start the parsing :-)
			set xml {}; foreach line [split [::lephttp::data $token] \n] {append xml [string trim $line]}; ::lephttp::cleanup $token
			## set our regex according to our url
			switch -exact -- $type {
				insecure-fdata - insecure-vdata {
					set regex {<item><title>(.+?)</title><description>(.+?)</description><link>(.+?)</link>(.+?)</item>}
					set vars {x title desc link y}
				}
				insecure-ndata {
					set regex {<item><title>(.+?)</title><link>(.+?)</link><description>(.+?)</description></item>}
					set vars {x title link desc}
				}
			}
			foreach [set vars] [regexp -all -inline -- $regex $xml] {
				lappend ::secwatch::[set type](titles) [set title [::lephttp::map $title]]
				lappend ::secwatch::[set type](descs) [set desc [::lephttp::strip [string map {{<br />} { }} [::lephttp::map [string map {{&amp;} {&}} $desc]]]]]
				lappend ::secwatch::[set type](links) $link
				## is message a reply...if so and we are filtering them, let's stop here
				if {($::secwatch::filterreps == 1) && ([string match -nocase {re:*} [lindex [split $title] 0]])} {continue}
				if {([array size ::secwatch::[set type]2] != 0) && ([lsearch -exact [set ::secwatch::[set type]2(links)] $link] == -1)} {
					## check user profiles and send email if appropriate
					if {$::secwatch::userprofiles != 0} {::secwatch::checkUsers $title $link $desc}
					## display output in channels
					switch -- [lindex [split $type {-}] end] {
						fdata {
							putlog "\[\002INSECURE-FULL DISCLOSURE\002\] \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan insecure]} {
									puthelp "PRIVMSG $chan :\[\002INSECURE-FULL DISCLOSURE\002] \002$title\002 >> $link"
								}
							}
						}
						vdata {
							putlog "\[\002INSECURE-VULNWATCH\002\] \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan insecure]} {
									puthelp "PRIVMSG $chan :\[\002INSECURE-VULNWATCH\002] \002$title\002 >> $link"
								}
							}
						}
						ndata {
							putlog "\[\002INSECURE-SECURITY NEWS\002\] \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan insecure]} {
									puthelp "PRIVMSG $chan :\[\002INSECURE-SECURITY NEWS\002] \002$title\002 >> $link"
								}
							}
						}
					}
				}
			}
		}

		proc insecurePubCmds {nick uhost hand chan text} {
			if {![channel get $chan insecure]} {return}
			switch -glob -- $text {
				ful* {set type insecure-fdata}
				vul* {set type insecure-vdata}
				new* {set type insecure-ndata}
				default {
					putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !insecure <fulldisclosure|vulnwatch|news>"; return
				}
			}
			putcmdlog "# $nick@$chan !insecure $text #"
			switch -- $::secwatch::messagetarget {
				nick {set target $nick}
				chan {set target $chan}
				default {putlog "\[\002INSECURE\002\] Error, unknown messagetarget specified in script!"; return}
			}
			set lineout 0
			foreach title [set ::secwatch::[set type](titles)] desc [set ::secwatch::[set type](descs)] link [set ::secwatch::[set type](links)] {
				## is message a reply...if so and we are filtering them, let's stop here
				if {($::secwatch::filterreps == 1) && ([string match -nocase {re:*} [lindex [split $title] 0]])} {continue}
				if {(![string equal {} $title]) && (![string equal {} $desc]) && (![string equal {} $link])} {
					if {($::secwatch::desctrim != 0) && ([string length $desc] > $::secwatch::desctrim)} {
						set desc "[string range $desc 0 $::secwatch::desctrim]..."
					}
					foreach line [::secwatch::wrapit "\002$title\002 >> $desc >> $link" 300] {
						puthelp "PRIVMSG $target :$line"
					}
					if {[incr lineout] >= $::secwatch::maxresults} {break}
				}
			}
		}
		bind pub - !insecure ::secwatch::insecurePubCmds
	}

	## packetstorm specifics
	if {$::secwatch::components(packetstorm)} {
		setudef flag packetstorm

		variable packetstorm-data; array set packetstorm-data [list]
		variable packetstorm-data2; array set packetstorm-data2 [list]

		proc packetstormCallback {type token} {
			if {[catch {::lephttp::status $token} status] != 0} {return}
			if {![string equal -nocase {ok} $status]} {
				switch -exact -- $status {
					timeout {
						putlog "\[\002PACKETSTORM\002\] Timeout (60 seconds) on connection to server."
					}
					default {
						putlog "\[\002PACKETSTORM\002\] Unknown error occured, server output of the error is as follows: $status"
					}
				}
				::lephttp::cleanup $token; return
			}
			array unset ::secwatch::packetstorm-data2; array set ::secwatch::packetstorm-data2 [array get ::secwatch::packetstorm-data]; array unset ::secwatch::packetstorm-data
			# start the parsing :-)
			set xml {}; foreach line [split [::lephttp::data $token] \n] {append xml [string trim $line]}; ::lephttp::cleanup $token
			foreach {x title link desc} [regexp -all -inline -- {<item><title>(.+?)</title><link>(.+?)</link><description>(.+?)</description></item>} $xml] {
				lappend {::secwatch::packetstorm-data(titles)} [set title [::lephttp::map $title]]
				lappend {::secwatch::packetstorm-data(links)} $link
				lappend {::secwatch::packetstorm-data(descs)} [set desc [::lephttp::map $desc]]
				if {([array size ::secwatch::packetstorm-data2] != 0) && ([lsearch -exact ${::secwatch::packetstorm-data2(links)} $link] == -1)} {
					## check user profiles and send email if appropriate
					if {$::secwatch::userprofiles != 0} {::secwatch::checkUsers $title $link $desc}
					## display output in channels
					if {($::secwatch::desctrim != 0) && ([string length $desc] > $::secwatch::desctrim)} {
						set desc "[string range $desc 0 $::secwatch::desctrim]..."
					}
					foreach line [::secwatch::wrapit "\[\002PACKETSTORM\002\] \002$title\002 >> $desc >> \002$link\002" 300] {
						putlog $line;
						foreach chan [channels] {
							if {[channel get $chan packetstorm]} {puthelp "PRIVMSG $chan :$line"}
						}
					}
				}
			}
		}

		proc packetstormPubCmds {nick uhost hand chan text} {
			if {![channel get $chan packetstorm]} {return}
			putcmdlog "# $nick@$chan !packetstorm #"
			switch -- $::secwatch::messagetarget {
				nick {set target $nick}
				chan {set target $chan}
				default {putlog "\[\002PACKETSTORM\002\] Error, unknown messagetarget specified in script!"; return}
			}
			set lineout 0
			foreach title ${::secwatch::packetstorm-data(titles)} link ${::secwatch::packetstorm-data(links)} desc ${::secwatch::packetstorm-data(descs)} {
				if {(![string equal {} $title]) && (![string equal {} $link]) && (![string equal {} $desc])} {
					foreach line [::secwatch::wrapit "\002$title\002 >> $desc >> \002$link\002" 300] {
						puthelp "PRIVMSG $target :$line"
					}
				}
				if {[incr lineout] >= $::secwatch::maxresults} {break}
			}
		}
		bind pub - !packetstorm ::secwatch::packetstormPubCmds
	}

	## secfocus specifics
	if {$::secwatch::components(secfocus)} {
		setudef flag secfocus

		variable secfocus-vdata; array set secfocus-vdata [list]
		variable secfocus-vdata2; array set secfocus-vdata2 [list]
		variable secfocus-ndata; array set secfocus-ndata [list]
		variable secfocus-ndata2; array set secfocus-ndata2 [list]

		proc secfocusCallback {type token} {
			if {[catch {::lephttp::status $token} status] != 0} {return}
			if {![string equal -nocase {ok} $status]} {
				switch -exact -- $status {
					timeout {
						putlog "\[\002SECFOCUS\002\] Timeout (60 seconds) on connection to server."
					}
					default {
						putlog "\[\002SECFOCUS\002\] Unknown error occured, server output of the error is as follows: $status"
					}
				}
				::lephttp::cleanup $token; return
			}
			array unset ::secwatch::[set type]2; array set ::secwatch::[set type]2 [array get ::secwatch::[set type]]; array unset ::secwatch::[set type]
			# start the parsing :-)
			set xml {}; foreach line [split [::lephttp::data $token] \n] {append xml [string trim $line]}; ::lephttp::cleanup $token
			set xml [string map {{<![CDATA[} {} {]]>} {} {<pubDate></pubDate>} {<pubDate>NULL</pubDate>} {<description></description>} {<description>NULL</description>}} $xml]
			set regex {<item><title>(.+?)</title><link>(.+?)</link><description>(.+?)</description><pubDate>(.+?)</pubDate></item>}
			set vars {x title link desc pdate}
			foreach [set vars] [regexp -all -inline -- $regex $xml] {
				if {([llength [set kword [string tolower [lindex [split $title {:}] 0]]]] > 1) && ([string match *columnist* $link])} {set kword columnists}
				switch -glob -- $kword {
					vul* - bug* - new* - inf* - bri* - col* {
						lappend ::secwatch::[set type]([string index $kword 0]titles) [set title [::lephttp::map $title]]
						lappend ::secwatch::[set type]([string index $kword 0]links) $link
						if {![string equal {} [set tempDesc [lindex [regexp -all -inline -- (.+?)<br/> $desc] 1]]]} {set desc $tempDesc}
						if {[string equal {NULL} $desc]} {set desc "No Description"}
						lappend ::secwatch::[set type]([string index $kword 0]descs) [set desc [::lephttp::map $desc]]
						if {[string equal {NULL} $pdate]} {set pdate [clock format [clock seconds] -format %Y-%m-%d]}
						lappend ::secwatch::[set type]([string index $kword 0]pdates) [set pdate [::lephttp::map $pdate]]
					}
				}
				if {($::secwatch::filterreps == 1) && ([string match -nocase {re:*} [lindex [split $title] 0]])} {continue}
				if {([array size ::secwatch::[set type]2] != 0) && ([lsearch -exact [set ::secwatch::[set type]2([string index $kword 0]links)] $link] == -1)} {
					## check user profiles and send email if appropriate
					if {$::secwatch::userprofiles != 0} {::secwatch::checkUsers $title $link $desc}
					## display output in channels
					switch -glob -- $kword {
						vul* {
							putlog "\[\002SEC-VULN\002\] (\002$pdate\002) \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan secfocus]} {
									puthelp "PRIVMSG $chan :\[\002SEC-VULN\002] (\002$pdate\002) \002$title\002 >> $link"
								}
							}
						}
						bug* {
							putlog "\[\002SEC-BUG\002\] (\002$pdate\002) \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan secfocus]} {
									puthelp "PRIVMSG $chan :\[\002SEC-BUG\002] (\002$pdate\002) \002$title\002 >> $link"
								}
							}
						}
						new* - inf* - bri* - col* {
							putlog "\[\002SEC-NEWS\002\] (\002$pdate\002) \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan secfocus]} {
									puthelp "PRIVMSG $chan :\[\002SEC-NEWS\002] (\002$pdate\002) \002$title\002 >> $link"
								}
							}
						}
					}
				}
			}
		}

		proc secfocusPubCmds {nick uhost hand chan text} {
			if {![channel get $chan secfocus]} {return}
			if {[string match -nocase {-d*} [lindex [split [set text [string trim $text]]] 0]]} {
				set details 1; set text [lindex [split $text] 1]
			}
			switch -glob -- $text {
				vul* {set type secfocus-vdata; set kword vulns}
				bug* {set type secfocus-vdata; set kword bugtraq}
				new* {set type secfocus-ndata; set kword news}
				inf* {set type secfocus-ndata; set kword infocus}
				bri* {set type secfocus-ndata; set kword briefs}
				col* {set type secfocus-ndata; set kword columnists}
				default {
					putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !secfocus \[-details\] <vulns|bugtraq|news|infocus|briefs|columns>"; return
				}
			}
			putcmdlog "# $nick@$chan !secfocus $text #"
			switch -- $::secwatch::messagetarget {
				nick {set target $nick}
				chan {set target $chan}
				default {putlog "\[\002SECFOCUS\002\] Error, unknown messagetarget specified in script!"; return}
			}
			set lineout 0
			foreach title [set ::secwatch::[set type]([string index $kword 0]titles)] link [set ::secwatch::[set type]([string index $kword 0]links)] \
			desc [set ::secwatch::[set type]([string index $kword 0]descs)] pdate [set ::secwatch::[set type]([string index $kword 0]pdates)] {
				if {($::secwatch::filterreps == 1) && ([string match -nocase {re:*} [lindex [split $title] 0]])} {continue}
				if {[info exists details]} {
					if {(![string equal {} $title]) && (![string equal {} $link]) && (![string equal {} $desc]) && (![string equal {} $pdate])} {
						foreach line [::secwatch::wrapit "(\002$pdate\002) \002$title\002 >> $desc >> $link" 300] {
							puthelp "PRIVMSG $target :$line"
						}
						if {[incr lineout] >= $::secwatch::maxresults} {break}
					}
				} else {
					if {(![string equal {} $title]) && (![string equal {} $link])} {
						foreach line [::secwatch::wrapit "(\002$pdate\002) \002$title\002 >> $link" 300] {
							puthelp "PRIVMSG $target :$line"
						}
						if {[incr lineout] >= $::secwatch::maxresults} {break}
					}
				}
			}
		}
		bind pub - !secfocus ::secwatch::secfocusPubCmds
	}

	## sectrack specifics
	if {$::secwatch::components(sectrack)} {
		setudef flag sectrack

		variable sectrack-data; array set sectrack-data [list]
		variable sectrack-data2; array set sectrack-data2 [list]

		proc sectrackCallback {type token} {
			if {[catch {::lephttp::status $token} status] != 0} {return}
			if {![string equal -nocase {ok} $status]} {
				switch -exact -- $status {
					timeout {
						putlog "\[\002SECTRACK\002\] Timeout (60 seconds) on connection to server."
					}
					default {
						putlog "\[\002SECTRACK\002\] Unknown error occured, server output of the error is as follows: $status"
					}
				}
				::lephttp::cleanup $token; return
			}
			array unset ::secwatch::[set type]2; array set ::secwatch::[set type]2 [array get ::secwatch::[set type]]; array unset ::secwatch::[set type]
			# start the parsing :-)
			set xml {}; foreach line [split [::lephttp::data $token] \n] {append xml [string trim $line]}; ::lephttp::cleanup $token
			foreach {x title link} [regexp -all -inline -- {<item><title>([^<]*)</title><link>([^<]*)</link></item>} $xml] {
				lappend ::secwatch::[set type](titles) [set title [::lephttp::map $title]]
				lappend ::secwatch::[set type](links) $link
				## is message a reply...if so and we are filtering them, let's stop here
				if {($::secwatch::filterreps == 1) && ([string match -nocase {re:*} [lindex [split $title] 0]])} {continue}
				## check if post is new...
				if {([array size ::secwatch::[set type]2] != 0) && ([lsearch -exact [set ::secwatch::[set type]2(links)] $link] == -1)} {
					## check user profiles and send email if appropriate
					if {$::secwatch::userprofiles != 0} {::secwatch::checkUsers $title $link}
					## display output in channels
					putlog "\[\002SECTRACK\002\] \002$title\002 >> $link"
					foreach chan [channels] {
						if {[channel get $chan sectrack]} {
							puthelp "PRIVMSG $chan :\[\002SECTRACK\002] \002$title\002 >> $link"
						}
					}
				}
			}
		}

		proc sectrackPubCmds {nick uhost hand chan text} {
			if {![channel get $chan sectrack]} {return}
			putcmdlog "# $nick@$chan !sectrack #"
			switch -- $::secwatch::messagetarget {
				nick {set target $nick}
				chan {set target $chan}
				default {putlog "\[\002SECTRACK\002\] Error, unknown messagetarget specified in script!"; return}
			}
			set lineout 0
			foreach title ${::secwatch::sectrack-data(titles)} link ${::secwatch::sectrack-data(links)} {
				## is message a reply...if so and we are filtering them, let's stop here
				if {($::secwatch::filterreps == 1) && ([string match -nocase {re:*} [lindex [split $title] 0]])} {continue}
				if {(![string equal {} $title]) && (![string equal {} $link])} {
					foreach line [::secwatch::wrapit "\002$title\002 >> $link" 300] {
						puthelp "PRIVMSG $target :$line"
					}
					if {[incr lineout] >= $::secwatch::maxresults} {break}
				}
			}
		}
		bind pub - !sectrack ::secwatch::sectrackPubCmds
	}

	## secunia specifics
	if {$::secwatch::components(secunia)} {
		setudef flag secunia

		variable secunia-adata; array set secunia-adata [list]
		variable secunia-adata2; array set secunia-adata2 [list]
		variable secunia-bdata; array set secunia-bdata [list]
		variable secunia-bdata2; array set secunia-bdata2 [list]

		proc secuniaCallback {type token} {
			if {[catch {::lephttp::status $token} status] != 0} {return}
			if {![string equal -nocase {ok} $status]} {
				switch -exact -- $status {
					timeout {
						putlog "\[\002SECUNIA\002\] Timeout (60 seconds) on connection to server."
					}
					default {
						putlog "\[\002SECUNIA\002\] Unknown error occured, server output of the error is as follows: $status"
					}
				}
				::lephttp::cleanup $token; return
			}
			array unset ::secwatch::[set type]2; array set ::secwatch::[set type]2 [array get ::secwatch::[set type]]; array unset ::secwatch::[set type]
			# start the parsing :-)
			set rss {}; foreach line [split [::lephttp::data $token] \n] {append rss [string trim $line]}; ::lephttp::cleanup $token
			set rss [string map {{<![CDATA[} {} {]]>} {} {<description></description>} {<description>NULL</description>}} $rss]
			foreach {x rdf title link desc} [regexp -all -inline -- \
			{<item rdf:about=\"(.+?)\"><title>(.+?)</title><link>(.+?)</link><description>(.+?)</description></item>} $rss] {
				lappend ::secwatch::[set type](titles) [set title [::lephttp::map [string trim $title]]]
				lappend ::secwatch::[set type](links) [string trim $link]
				## secunia has added a nice little NOTE: advertisement to the descripton on some of the feeds...lets's remove it
				regsub -all -- {<br />.*$} [::lephttp::map [string trim $desc]] {} desc
				## add the cleaned up desc to the array...
				lappend ::secwatch::[set type](descs) $desc
				if {($::secwatch::filterreps == 1) && ([string match -nocase {re:*} [lindex [split $title] 0]])} {continue}
				if {([array size ::secwatch::[set type]2] != 0) && ([lsearch -exact [set ::secwatch::[set type]2(links)] $link] == -1)} {
					## check user profiles and send email if appropriate
					if {$::secwatch::userprofiles != 0} {::secwatch::checkUsers $title $link $desc}
					## display output in channels
					switch -exact -- [lindex [split $type {-}] end] {
						adata {
							putlog "\[\002SECUNIA-ADVISORY\002\] \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan secunia]} {
									puthelp "PRIVMSG $chan :\[\002SECUNIA-ADVISORY\002] \002$title\002 >> $link"
								}
							}
						}
						bdata {
							putlog "\[\002SECUNIA-VIRUS\002\] \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan secunia]} {
									puthelp "PRIVMSG $chan :\[\002SECUNIA-VIRUS\002] \002$title\002 >> $link"
								}
							}
						}
					}
				}
			}
		}

		proc secuniaPubCmds {nick uhost hand chan text} {
			if {![channel get $chan secunia]} {return}
			if {[string match -nocase {-d*} [lindex [split [set text [string trim $text]]] 0]]} {
				set details 1; set text [lindex [split $text] 1]
			}
			switch -glob -- $text {
				adv* {set type secunia-adata}
				blo* {set type secunia-bdata}
				default {
					putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !secunia \[-details\] <advisories|blog>"; return
				}
			}
			putcmdlog "# $nick@$chan !secunia $text #"
			switch -- $::secwatch::messagetarget {
				nick {set target $nick}
				chan {set target $chan}
				default {putlog "\[\002SECUNIA\002\] Error, unknown messagetarget specified in script!"; return}
			}
			set lineout 0
			foreach title [set ::secwatch::[set type](titles)] link [set ::secwatch::[set type](links)] desc [set ::secwatch::[set type](descs)] {
				if {($::secwatch::filterreps == 1) && ([string match -nocase {re:*} [lindex [split $title] 0]])} {continue}
				if {[info exists details]} {
					if {(![string equal {} $title]) && (![string equal {} $link]) && (![string equal {} $desc])} {
						foreach line [::secwatch::wrapit "\002$title\002 >> $desc >> $link" 300] {
							puthelp "PRIVMSG $target :$line"
						}
						if {[incr lineout] >= $::secwatch::maxresults} {break}
					}
				} else {
					if {(![string equal {} $title]) && (![string equal {} $link])} {
						foreach line [::secwatch::wrapit "\002$title\002 >> $link" 300] {
							puthelp "PRIVMSG $target :$line"
						}
						if {[incr lineout] >= $::secwatch::maxresults} {break}
					}
				}
			}
		}
		bind pub - !secunia ::secwatch::secuniaPubCmds
	}

	## securiteam specifics
	if {$::secwatch::components(securiteam)} {
		setudef flag securiteam

		variable securiteam-data; array set securiteam-data [list]
		variable securiteam-data2; array set securiteam-data2 [list]

		proc securiteamCallback {type token} {
			if {[catch {::lephttp::status $token} status] != 0} {return}
			if {![string equal -nocase {ok} $status]} {
				switch -exact -- $status {
					timeout {
						putlog "\[\002SECURITEAM\002\] Timeout (60 seconds) on connection to server."
					}
					default {
						putlog "\[\002SECURITEAM\002\] Unknown error occured, server output of the error is as follows: $status"
					}
				}
				::lephttp::cleanup $token; return
			}
			# clean out old arrays
			array unset ::secwatch::[set type]2; array set ::secwatch::[set type]2 [array get ::secwatch::[set type]]; array unset ::secwatch::[set type]
			# start the parsing :-)
			set rss {}; foreach line [split [::lephttp::data $token] \n] {append rss [string trim $line]}; ::lephttp::cleanup $token
			set rss [string map {{<![CDATA[} {} {]]>} {} {<description></description>} {<description>NULL</description>}} $rss]
			foreach {x title link desc y pdate} \
			[regexp -all -inline -- {<item><title>(.+?)</title><link>(.+?)</link><description>(.+?)</description>(.+?)<pubDate>(.+?)</pubDate></item>} $rss] {
				switch -glob -- [string tolower $link] {
					{*/securitynews/*} {set dtype ndata}
					{*/tools/*} {set dtype tdata}
					{*/unixfocus/*} {set dtype udata}
					{*/windows*focus/*} {set dtype wdata}
					{*/exploits/*} {set dtype xdata}
					{*/securityreviews/*} {set dtype rdata}
					default {continue}
				}
				lappend ::secwatch::[set type]([string index $dtype 0]titles) [set title [::lephttp::strip [::lephttp::map $title]]]
				lappend ::secwatch::[set type]([string index $dtype 0]links) $link
				lappend ::secwatch::[set type]([string index $dtype 0]descs) [set desc [::lephttp::strip [::lephttp::map $desc]]]
				lappend ::secwatch::[set type]([string index $dtype 0]pdates) $pdate
				## is message a reply...if so and we are filtering them, let's stop here
				if {($::secwatch::filterreps == 1) && ([string match -nocase {re:*} [lindex [split $title] 0]])} {continue}
				if {([array size ::secwatch::[set type]2] != 0) && ([lsearch -exact [set ::secwatch::[set type]2([string index $dtype 0]links)] $link] == -1)} {
					## check user profiles and send email if appropriate
					if {$::secwatch::userprofiles != 0} {::secwatch::checkUsers $title $link $desc}
					## display output in channels
					switch -exact -- $dtype {
						ndata {
							putlog "\[\002Security News\002\] (\002$pdate\002) \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan securiteam]} {
									puthelp "PRIVMSG $chan :\[\002Security News\002] (\002$pdate\002) \002$title\002 >> $link"
								}
							}
						}
						tdata {
							putlog "\[\002Security Tools\002\] (\002$pdate\002) \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan securiteam]} {
									puthelp "PRIVMSG $chan :\[\002Security Tools\002] (\002$pdate\002) \002$title\002 >> $link"
								}
							}
						}
						udata {
							putlog "\[\002Unix Focus\002\] (\002$pdate\002) \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan securiteam]} {
									puthelp "PRIVMSG $chan :\[\002Unix Focus\002] (\002$pdate\002) \002$title\002 >> $link"
								}
							}
						}
						wdata {
							putlog "\[\002Windows Focus\002\] (\002$pdate\002) \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan securiteam]} {
									puthelp "PRIVMSG $chan :\[\002Windows Focus\002] (\002$pdate\002) \002$title\002 >> $link"
								}
							}
						}
						xdata {
							putlog "\[\002Exploits\002\] (\002$pdate\002) \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan securiteam]} {
									puthelp "PRIVMSG $chan :\[\002Exploits\002] (\002$pdate\002) \002$title\002 >> $link"
								}
							}
						}
						rdata {
							putlog "\[\002Security Reviews\002\] (\002$pdate\002) \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan securiteam]} {
									puthelp "PRIVMSG $chan :\[\002Security Reviews\002] (\002$pdate\002) \002$title\002 >> $link"
								}
							}
						}
					}
				}
			}
		}

		proc securiteamPubCmds {nick uhost hand chan text} {
			if {![channel get $chan securiteam]} {return}
			if {[string match -nocase {-d*} [lindex [split [set text [string trim $text]]] 0]]} {
				set details 1; set text [lindex [split $text] 1]
			}
			switch -glob -- $text {
				new* {set dtype ndata}
				too* {set dtype tdata}
				uni* {set dtype udata}
				win* {set dtype wdata}
				exp* {set dtype xdata}
				rev* {set dtype rdata}
				default {
					putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !securiteam \[-details\] <news|tools|unix|windows|exploits|reviews>"; return
				}
			}
			putcmdlog "# $nick@$chan !securiteam $text #"
			switch -- $::secwatch::messagetarget {
				nick {set target $nick}
				chan {set target $chan}
				default {putlog "\[\002SECURITEAM\002\] Error, unknown messagetarget specified in script!"; return}
			}
			set type "securiteam-data"; set lineout 0
			foreach title [set ::secwatch::[set type]([string index $dtype 0]titles)] link [set ::secwatch::[set type]([string index $dtype 0]links)] \
			desc [set ::secwatch::[set type]([string index $dtype 0]descs)] pdate [set ::secwatch::[set type]([string index $dtype 0]pdates)] {
				## is message a reply...if so and we are filtering them, let's stop here
				if {($::secwatch::filterreps == 1) && ([string match -nocase {re:*} [lindex [split $title] 0]])} {continue}
				if {([info exists details]) && (![string equal {tdata} $dtype])} {
					if {(![string equal {} $title]) && (![string equal {} $link])} {
						foreach line [::secwatch::wrapit "(\002$pdate\002) \002$title\002 >> $desc >> $link" 300] {
							puthelp "PRIVMSG $target :$line"
						}
						if {[incr lineout] >= $::secwatch::maxresults} {break}
					}
				} else {
					if {(![string equal {} $title]) && (![string equal {} $link])} {
						foreach line [::secwatch::wrapit "(\002$pdate\002) \002$title\002 >> $link" 300] {
							puthelp "PRIVMSG $target :$line"
						}
						if {[incr lineout] >= $::secwatch::maxresults} {break}
					}
				}
			}
		}
		bind pub - !securiteam ::secwatch::securiteamPubCmds
	}

	## sophos specifics
	if {$::secwatch::components(sophos)} {
		setudef flag sophos
		
		variable sophos-vdata; array set sophos-vdata [list]
		variable sophos-vdata2; array set sophos-vdata2 [list]
		variable sophos-pdata; array set sophos-pdata [list]
		variable sophos-pdata2; array set sophos-pdata2 [list]
		
		proc sophosCallback {type token} {
			if {[catch {::lephttp::status $token} status] != 0} {return}
			if {![string equal -nocase {ok} $status]} {
				switch -exact -- $status {
					timeout {
						putlog "\[\002SOPHOS\002\] Timeout (60 seconds) on connection to server."
					}
					default {
						putlog "\[\002SOPHOS\002\] Unknown error occured, server output of the error is as follows: $status"
					}
				}
				::lephttp::cleanup $token; return
			}
			array unset ::secwatch::[set type]2; array set ::secwatch::[set type]2 [array get ::secwatch::[set type]]; array unset ::secwatch::[set type]
			# start the parsing :-)
			set xml {}; foreach line [split [::lephttp::data $token] \n] {append xml [string trim $line]}; ::lephttp::cleanup $token
			foreach {x title link guid pdate} [regexp -all -inline -- {<item><title>(.+?)</title><link>(.+?)</link><guid>(.+?)</guid><pubDate>(.+?)</pubDate></item>} $xml] {
				lappend ::secwatch::[set type](titles) [::lephttp::map $title]
				lappend ::secwatch::[set type](links) $link
				lappend ::secwatch::[set type](pdates) $pdate
				if {([array size ::secwatch::[set type]2] != 0) && ([lsearch -exact [set ::secwatch::[set type]2(links)] $link] == -1)} {
					## check user profiles and send email if appropriate
					if {$::secwatch::userprofiles != 0} {::secwatch::checkUsers $title $link}
					## display output in channels
					switch -exact -- [lindex [split $type {-}] end] {
						vdata {
							putlog "\[\002Sophos Alert\002\] (\002$pdate\002) \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan sophos]} {
									puthelp "PRIVMSG $chan :\[\002Sophos Alert\002] (\002$pdate\002) \002$title\002 >> $link"
								}
							}
						}
						pdata {
							putlog "\[\002Sophos Hoax\002\] (\002$pdate\002) \002$title\002 >> $link"
							foreach chan [channels] {
								if {[channel get $chan sophos]} {
									puthelp "PRIVMSG $chan :\[\002Sophos Hoax\002] (\002$pdate\002) \002$title\002 >> $link"
								}
							}
						}
					}
				}
			}
		}

		proc sophosPubCmds {nick uhost hand chan text} {
			if {![channel get $chan sophos]} {return}
			switch -glob -- $text {
				al* {set type sophos-vdata}
				pu* {set type sophos-pdata}
				default {
					putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !sophos <alerts|puas>"; return
				}
			}
			putcmdlog "# $nick@$chan !sophos $text #"
			switch -- $::secwatch::messagetarget {
				nick {set target $nick}
				chan {set target $chan}
				default {putlog "\[\002SOPHOS\002\] Error, unknown messagetarget specified in script!"; return}
			}
			set lineout 0
			foreach title [set ::secwatch::[set type](titles)] link [set ::secwatch::[set type](links)] pdate [set ::secwatch::[set type](pdates)] {
				if {(![string equal {} $title]) && (![string equal {} $link])} {
					foreach line [::secwatch::wrapit "(\002$pdate\002) \002$title\002 >> $link" 300] {
						puthelp "PRIVMSG $target :$line"
					}
					if {[incr lineout] >= $::secwatch::maxresults} {break}
				}
			}
		}
		bind pub - !sophos ::secwatch::sophosPubCmds
	}

	## symantec specifics
	if {$::secwatch::components(symantec)} {
		setudef flag symantec

		variable symantec-vdata; array set symantec-vdata [list]
		variable symantec-vdata2; array set symantec-vdata2 [list]
		variable symantec-tdata; array set symantec-tdata [list]
		variable symantec-tdata2; array set symantec-tdata2 [list]
		variable symantec-adata; array set symantec-adata [list]
		variable symantec-adata2; array set symantec-adata2 [list]

		proc risk {num} {
			switch -exact -- $num {
				1 {return "\002\00300,02 $num \003\002"}
				2 {return "\002\00300,03 $num \003\002"}
				3 {return "\002\00300,09 $num \003\002"}
				4 {return "\002\00300,07 $num \003\002"}
				5 {return "\002\00300,04 $num \003\002"}
			}
		}

		proc symantecCallback {type token} {
			if {[catch {::lephttp::status $token} status] != 0} {return}
			if {![string equal -nocase {ok} $status]} {
				switch -exact -- $status {
					timeout {
						putlog "\[\002SYMANTEC\002\] Timeout (60 seconds) on connection to server."
					}
					default {
						putlog "\[\002SYMANTEC\002\] Unknown error occured, server output of the error is as follows: $status"
					}
				}
				::lephttp::cleanup $token; return
			}
			array unset ::secwatch::[set type]2; array set ::secwatch::[set type]2 [array get ::secwatch::[set type]]; array unset ::secwatch::[set type]
			foreach line [split [::lephttp::data $token] \n] {
				if {![string equal {} $line]} {
					array set ::secwatch::[set type] [list [lindex $line 1] [split [string trim \
					[string map {' {} [ {} ] {} ; {}} [join [lindex [split $line {=}] end]]]] {,}]]
				}
			}
			::lephttp::cleanup $token; if {![array size [join ::secwatch::[set type]2]]} {return}
			switch -exact -- [lindex [split $type {-}] end] {
				vdata {
				   ## check virus latest...
					foreach var {risk name url date} var2 {risk2 name2 url2 date2} element {symLrisks symLnames symLurls symLdates} {
						set $var [lindex [lindex [array get ::secwatch::symantec-vdata $element] end] 0]
						set $var2 [lindex [lindex [array get ::secwatch::symantec-vdata2 $element] end] 0]
					}
					if {(![string equal {} $name]) && (![string equal $name $name2])} {
						## check user profiles and send email if appropriate
						if {$::secwatch::userprofiles != 0} {::secwatch::checkUsers $name "http://securityresponse.symantec.com/avcenter/venc/data/$url"}
						## display output in channels
						putlog "\[\002V-ALERT\002\] [::secwatch::risk $risk] $date \002$name\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url"
						foreach chan [channels] {
							if {[channel get $chan symantec]} {
								puthelp "PRIVMSG $chan :\[\002V-ALERT\002\] [::secwatch::risk $risk] $date \002$name\002 >> \
								http://securityresponse.symantec.com/avcenter/venc/data/$url"
							}
						}
					}
					## check virus top...
					foreach var {risk name url date} var2 {risk2 name2 url2 date2} element {symTrisks symTnames symTurls symTdates} {
						set $var [lindex [lindex [array get ::secwatch::symantec-vdata $element] end] 0]
						set $var2 [lindex [lindex [array get ::secwatch::symantec-vdata2 $element] end] 0]
					}
					if {(![string equal {} $name]) && (![string equal $name $name2])} {
						## check user profiles and send email if appropriate
						if {$::secwatch::userprofiles != 0} {::secwatch::checkUsers $name "http://securityresponse.symantec.com/avcenter/venc/data/$url"}
						## display output in channels
						putlog "\[\002V-ALERT\002\] [::secwatch::risk $risk] $date \002$name\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url"
						foreach chan [channels] {
							if {[channel get $chan symantec]} {
								puthelp "PRIVMSG $chan :\[\002V-ALERT\002\] [::secwatch::risk $risk] $date \002$name\002 >> \
								http://securityresponse.symantec.com/avcenter/venc/data/$url"
							}
						}
					}
				}
				tdata {
					foreach var {name url} var2 {name2 url2} element {symRnames symRurls} {
						set $var [lindex [lindex [array get ::secwatch::symantec-tdata $element] end] 0]
						set $var2 [lindex [lindex [array get ::secwatch::symantec-tdata2 $element] end] 0]
					}
					if {(![string equal {} $name]) && (![string equal $name $name2])} {
						## check user profiles and send email if appropriate
						if {$::secwatch::userprofiles != 0} {::secwatch::checkUsers $name "http://securityresponse.symantec.com/avcenter/venc/data/$url"}
						## display output in channels
						putlog "\[\002T-ALERT\002\] \002$name removal tool\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url"
						foreach chan [channels] {
							if {[channel get $chan symantec]} {
								puthelp "PRIVMSG $chan :\[\002T-ALERT\002\] \002$name removal tool\002 >> \
								http://securityresponse.symantec.com/avcenter/venc/data/$url"
							}
						}
					}
				}
				adata {
					foreach var {name url} var2 {name2 url2} element {symAnames symAurls} {
						set $var [lindex [lindex [array get ::secwatch::symantec-adata $element] end] 0]
						set $var2 [lindex [lindex [array get ::secwatch::symantec-adata2 $element] end] 0]
					}
					if {(![string equal {} $name]) && (![string equal $name $name2])} {
						## check user profiles and send email if appropriate
						if {$::secwatch::userprofiles != 0} {::secwatch::checkUsers $name "http://securityresponse.symantec.com/avcenter/security/Content/$url"}
						## display output in channels
						putlog "\[\002S-ALERT\002\] \002$name\002 >> http://securityresponse.symantec.com/avcenter/security/Content/$url"
						foreach chan [channels] {
							if {[channel get $chan symantec]} {
								puthelp "PRIVMSG $chan :\[\002S-ALERT\002\] \002$name\002 >> http://securityresponse.symantec.com/avcenter/security/Content/$url"
							}
						}
					}
				}
			}
		}

		proc symantecPubCmds {nick uhost hand chan text} {
			if {![channel get $chan symantec]} {return}
			switch -exact -- [string trim $text] {
				{virus latest} {set type vdata; set subt latest}
				{virus top} {set type vdata; set subt top}
				security {set type adata; set subt {}}
				tools {set type tdata; set subt {}}
				default {
					putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !symantec <virus (latest|top)|security|tools>"; return
				}
			}
			putcmdlog "# $nick@$chan !symantec $text #"
			switch -- $::secwatch::messagetarget {
				nick {set target $nick}
				chan {set target $chan}
				default {putlog "\[\002SYMANTEC\002\] Error, unknown messagetarget specified in script!"; return}
			}
			set lineout 0
			switch -exact $type {
				vdata {
					switch -exact -- $subt {
						latest {
							foreach risk ${::secwatch::symantec-vdata(symLrisks)} name ${::secwatch::symantec-vdata(symLnames)} \
							url ${::secwatch::symantec-vdata(symLurls)} date ${::secwatch::symantec-vdata(symLdates)} {
								if {(![string equal {} $risk]) && (![string equal {} $name]) && (![string equal {} $url]) && (![string equal {} $date])} {
									foreach line [::secwatch::wrapit "[::secwatch::risk $risk] $date \002$name\002 >> \
									http://securityresponse.symantec.com/avcenter/venc/data/$url" 300] {
										puthelp "PRIVMSG $target :$line"
									}
									if {[incr lineout] >= $::secwatch::maxresults} {break}
								}
							}
						}
						top {
							foreach risk ${::secwatch::symantec-vdata(symTrisks)} name ${::secwatch::symantec-vdata(symTnames)} \
							url ${::secwatch::symantec-vdata(symTurls)} date ${::secwatch::symantec-vdata(symTdates)} {
								if {(![string equal {} $risk]) && (![string equal {} $name]) && (![string equal {} $url]) && (![string equal {} $date])} {
									foreach line [::secwatch::wrapit "[::secwatch::risk $risk] $date \002$name\002 >> \
									http://securityresponse.symantec.com/avcenter/venc/data/$url" 300] {
										puthelp "PRIVMSG $target :$line"
									}
									if {[incr lineout] >= $::secwatch::maxresults} {break}
								}
							}
						}
					}
				}
				tdata {
					foreach name ${::secwatch::symantec-tdata(symRnames)} url ${::secwatch::symantec-tdata(symRurls)} {
						if {(![string equal {} $name]) && (![string equal {} $url])} {
							foreach line [::secwatch::wrapit "\002$name removal tool\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url" 300] {
								puthelp "PRIVMSG $target :$line"
							}
							if {[incr lineout] >= $::secwatch::maxresults} {break}
						}
					}
				}
				adata {
					foreach name ${::secwatch::symantec-adata(symAnames)} url ${::secwatch::symantec-adata(symAurls)} {
						if {(![string equal {} $name]) && (![string equal {} $url])} {
							foreach line [::secwatch::wrapit "\002$name\002 >> http://securityresponse.symantec.com/avcenter/security/Content/$url" 300] {
								puthelp "PRIVMSG $target :$line"
							}
							if {[incr lineout] >= $::secwatch::maxresults} {break}
						}
					}
				}
			}
		}
		bind pub - !symantec ::secwatch::symantecPubCmds
	}

	## fetch urls for active components
	proc getData {minute hour day month year} {
		if {[incr ::secwatch::uinterval2] >= $::secwatch::uinterval} {
			foreach {type url} [array get ::secwatch::urls] {
				if {$::secwatch::components([lindex [split $type {-}] 0])} {
						::lephttp::geturl $url -command [list ::secwatch::[lindex [split $type {-}] 0]Callback $type] -timeout 60000
				}
			}
			set ::secwatch::uinterval2 0
		}
	}
	bind time - "* * * * *" ::secwatch::getData
}


## start init ##
foreach timer [utimers] {
	if {[string match {::secwatch::getData*} [join [lindex $timer 1]]]} {
		killutimer [lindex $timer end]
	}
}
set ::secwatch::uinterval2 $::secwatch::uinterval; utimer 8 {::secwatch::getData - - - - -}

set secwatchModules [list]; foreach secwatchModule [array names ::secwatch::components] {
	if {$::secwatch::components($secwatchModule)} {lappend secwatchModules $secwatchModule}
}
## end init ##

putlog "secwatch.tcl v$::secwatch::comver by leprechau@EFNet loaded with modules: [join $::secwatch::LoadedComps {, }]"
