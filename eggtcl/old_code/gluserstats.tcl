##################################################
## glftpd public userstats script version 2.4   ##
## by leprechau@efnet October 30, 2002          ##
##################################################
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

## short name for your site
set glstats(sname) "SITE"

## character that designates a command
## prepended to site name (set to "" for none)
set glstats(cmdpre) "!site"

## groups that shoud be exluded from stats
set glstats(gexclude) "friends siteops affil1 affil2 affil3"

## users that should be excluded from stats
set glstats(uexclude) "glftpd sitebot dupecheck default.user"

## path to the userfiles
set glstats(userpath) "/glftpd/ftp-data/users"

## path to glftpd passwd file
set glstats(passwd) "/glftpd/etc/passwd"

## where you want the stats stored
set glstats(statspath) "/home/eggy/eggdrop/text"

# where you want the stats recorded
# (archive will be in old under this path)
set glstats(oldpath) "/glftpd/site/stats"

## enable builtin httpd? (0 or 1)
set glstats(httpdenable) "1"

## ip you want httpd listening on
set glstats(httpdip) "1.2.3.4"

## port you want httpd listening on
set glstats(httpdport) "65000"

## users allowed to connect to stats url
## ip restricted (ips taken from glftpd userfiles)
set glstats(httpdallowed) "leprechau admin2 admin3"

## restrict access to known users 1 or 0
set glstats(restrict) "1"

## If glstats(restrict) is set to 1, this is the flag that
## users must have to generate stats, "-" for any user
set glstats(flag) "o|o"

##################################################
##          DO NOT EDIT THIS SCRIPT             ##
##         DOING SO IS NOT SUPPORTED            ##
##################################################
set gluserstats_ver "2.4"

proc glstats_getsize { bytes } {
	set i 0
	while {$bytes > 1024} {
		set bytes "[expr $bytes / 1024]"
		incr i
	}
	switch -- $i {
		0 {return "$bytes\BYTES"}
		1 {return "$bytes\MB"}
		2 {return "$bytes\GB"}
		3 {return "$bytes\TB"}
		default {return UNKNOWN}
	}
}

proc glstats_passwd { user } {
global glstats
	if {[catch {set file [open $glstats(passwd) r]} open_error] != 0} {
		putlog "\[\002ERROR\002\] Could not open '$glstats(passwd)' for reading:  $open_error" ; return
	}
	while {![eof $file]} {
		gets $file line
		if {[string equal -nocase $user [string trim [lindex [split $line {:}] 0]]]} { 
			set added [string trim [lindex [split $line {:}] 4]] ; break
		}
	}
	if {[catch {close $file} close_error] != 0} {
		putlog "\[\002ERROR\002\] Error closing $glstats(passwd):  $close_error" ; return
	}
	if {(![info exists added]) || ([string equal {} $added])} { 
		return "UNKNOWN"
	} else {return $added}
}

proc glstats_user { user } {
global glstats
	if {[catch {set file [open $glstats(userpath)/$user r]} open_error] != 0} {
		putlog "\[\002ERROR\002\] Could not open '$glstats(userpath)/$user' for reading:  $open_error" ; return
	}
	if {[catch {set data [split [read $file] \n]} read_error] != 0} {
		putlog "\[\002ERROR\002\] Error reading $glstats(userpath)/$user:  $read_error" ; return
	}
	if {[catch {close $file} close_error] != 0} {
		putlog "\[\002ERROR\002\] Error closing $glstats(userpath)/$user:  $close_error" ; return
	}
	foreach line $data {
		switch -- [lindex $line 0] {
			USER {
				array set stats [list ADDED [lindex $line 3]]
			}
			CREDITS {
				array set stats [list CREDITS [lindex $line 1] HCREDITS [glstats_getsize [lindex $line 1]]]
			}
			RATIO {
				array set stats [list RATIO [lindex $line 1]]
			}
			ALLUP - WKUP - DAYUP - MONTHUP - ALLDN - WKDN - DAYDN - MONTHDN {
				array set stats [list [lindex $line 0] [lindex $line 2] H[lindex $line 0] [glstats_getsize [lindex $line 2]]]
			}
			GROUP {
				if {![string equal {} [string trim [lindex $line 1]]]} {
					lappend stats(GROUP) [string trim [lindex $line 1]]
				}
			}
			IP {
				if {![string equal {} [set ipmask [lindex [split $line {@}] end]]]} {
					lappend stats(IP) $ipmask
				}
			}
		}
	}
	if {[string equal {} [array get stats GROUP]]} {array set stats [list GROUP NULL]}
	return [array get stats]
}

proc glstats_write { file text } {
	if {[catch {set wfile [open $file a+ 0666]} open_error] != 0} {
		putlog "\[\002ERROR\002\] Could not open '$file' for writing:  $open_error" ; return
	}
	if {[catch { puts $wfile "$text" } write_error] != 0} {
		putlog "\[\002ERROR\002\] Could not write to temp file:  $write_error" ; return
	}
	if {[catch {close $wfile} close_error] != 0} {
		putlog "\[\002ERROR\002\] Error closing $file:  $close_error" ; return
	}
}

proc glstats_format { text } {
	return " $text[string repeat { } [expr 17 - [string length $text]]]"
}

proc glstats_usercheck { nick uhost hand chan user } {
global glstats
	if {($glstats(restrict) == 1) && (![matchattr $hand $glstats(flag)|$glstats(flag) $chan])} {
		puthelp "PRIVMSG $chan :\-$glstats(sname)\- \[\002USERSTATS\002\] \- Sorry, but access to this command has been restricted."
		putlog "\[\002ERROR\002\] $nick attempted an unauthorized userstats request on $chan \@ [ctime [unixtime]]"
		return
	}
	
	set added [glstats_passwd [set user [string trim $user]]]
	array set stats [glstats_user $user]
	if {![array size stats]} {
		putserv "PRIVMSG $chan :\[\002ERROR\002\] Could not get information for user that user ($user).  Remember, all information is case sensitive."
		return
	}
	putserv "PRIVMSG $chan :\002$user\002\([lindex $stats(GROUP) 0]\) added by $stats(ADDED) on $added \002::\002 RATIO:\002$stats(RATIO)\002 CREDITS:\002$stats(HCREDITS)\002"
	putserv "PRIVMSG $chan :\ALLUP:\002$stats(HALLUP)\002 WKUP:\002$stats(HWKUP)\002 DAYUP:\002$stats(HDAYUP)\002 MONTHUP:\002$stats(HMONTHUP)\002"
	putserv "PRIVMSG $chan :\ALLDN:\002$stats(HALLDN)\002 WKDN:\002$stats(HWKDN)\002 DAYDN:\002$stats(HDAYDN)\002 MONTHDN:\002$stats(HMONTHDN)\002"
}
bind pub - $glstats(cmdpre)usercheck glstats_usercheck

proc glstats_update_html {size files} {
global glstats
	catch {file delete -force $glstats(statspath)/index.html}
	glstats_write $glstats(statspath)/index.html "<html>"
	glstats_write $glstats(statspath)/index.html "<head>"
	glstats_write $glstats(statspath)/index.html "<title>gluserstats.tcl</title>"
	glstats_write $glstats(statspath)/index.html "</head>"
	glstats_write $glstats(statspath)/index.html "<body bgcolor=#ffffff text=#000000>"
	glstats_write $glstats(statspath)/index.html "<p>Displaying [llength $files] old reports totalling $size bytes found in $glstats(statspath). Use, $glstats(cmdpre)clearstats on irc to remove.</p>"
	foreach 1file $files {
		glstats_write $glstats(statspath)/index.html "<b>Filename</b>: <a href=/[file tail $1file]>[file tail $1file]</a> <b>Generated</b>: [ctime [lindex [split [file tail $1file] -] 1]]<br>"
	}
	glstats_write $glstats(statspath)/index.html "</body></html>"
}

proc glstats_showstats { nick uhost hand chan text } {
global glstats 
	set text [string tolower [string trim $text]]
	if {($glstats(restrict) == 1) && (![matchattr $hand $glstats(flag)|$glstats(flag) $chan])} {
		puthelp "PRIVMSG $chan :\-$glstats(sname)\- \[\002USERSTATS\002\] \- Sorry, but access to this command has been restricted."
		putlog "\[\002ERROR\002\] $nick attempted an unauthorized userstats request on $chan \@ [ctime [unixtime]]"
		return
	}
	if {([string equal {} $text]) || (![string match *$text* "allup wkup dayup monthup"])} {
		putserv "PRIVMSG $chan :\[\002ERROR\002\] Usage: $glstats(cmdpre)userstats <sorter>"
		putserv "PRIVMSG $chan :Valid sorters\: allup wkup dayup monthup"
		return
	}
	set glstats(statsfile) "stats-[unixtime]-$text.lst"
	set oldstats "[glob -nocomplain -type f -path $glstats(statspath)/ stats-*]"
	set num_oldstats "[llength $oldstats]"
	set div "|------------------|------------------|------------------|------------------|------------------|------------------|------------------|"
	set head "|------USER--------|------ADDED-------|------ALLUP-------|------WKUP--------|-------DAYUP------|------MONTHUP-----|------GROUP-------|"
	glstats_write "$glstats(statspath)/$glstats(statsfile)" "$div"
	glstats_write "$glstats(statspath)/$glstats(statsfile)" "$head"
	glstats_write "$glstats(statspath)/$glstats(statsfile)" "$div"
	if {[catch {set file [open $glstats(passwd) r]} open_error] != 0} {
		putlog "\[\002ERROR\002\] Could not open '$glstats(passwd)' for reading:  $open_error" ; return
	}
	if {[catch {set data [split [read $file] \n]} read_error] != 0} {
		putlog "\[\002ERROR\002\] Error reading $glstats(passwd):  $read_error" ; return
	}
	if {[catch {close $file} close_error] != 0} {
		putlog "\[\002ERROR\002\] Error closing $glstats(passwd):  $close_error" ; return
	}
	foreach 1line $data {
		if {(![string equal {} [set user [string trim [lindex [split $1line {:}] 0]]]]) && ([lsearch -exact [split [string tolower $glstats(uexclude)] { }] [string tolower $user]] == -1)} {
			set added [string trim [lindex [split $1line {:}] 4]]
			array set stats [glstats_user $user]; if {![array size stats]} {continue}
			switch -- $text {
				allup { set sorter $stats(ALLUP) }
				wkup { set sorter $stats(WKUP) }
				dayup { set sorter $stats(DAYUP) }
				monthup { set sorter $stats(MONTHUP) }
			}
			set excluded 0
			foreach grp $stats(GROUP) {
				if {[lsearch -exact [split [string tolower $glstats(gexclude)] { }] [string tolower $grp]] != -1} {set excluded 1}
			}
			if {$excluded == 0} {lappend statslist $sorter:$user:$added:$stats(HALLUP):$stats(HWKUP):$stats(HDAYUP):$stats(HMONTHUP):[lindex $stats(GROUP) 0]}
		}
	}
	set rank 1
	foreach 1line [lsort -decreasing -dictionary $statslist] {
		set line [lrange [split $1line {:}] 1 end]
		set wline \|[glstats_format "\#$rank [lindex $line 0]"]
		for {set i 1} {$i <= 6} {incr i} { append wline "|[glstats_format [lindex $line $i]]" }
		append wline "|"
		glstats_write "$glstats(statspath)/$glstats(statsfile)" "$wline"
		glstats_write "$glstats(statspath)/$glstats(statsfile)" "$div"
		incr rank
	}
	puthelp "PRIVMSG $chan :User stats created -\-\> $glstats(statspath)/$glstats(statsfile)"
	if {$num_oldstats != 0} {
		set size_oldstats 0
		foreach 1file $oldstats { incr size_oldstats [file size $1file] }
		glstats_update_html $size_oldstats "$oldstats"
		puthelp "PRIVMSG $chan :$num_oldstats old reports totalling $size_oldstats bytes found in $glstats(statspath). Use, $glstats(cmdpre)clearstats to remove or $glstats(cmdpre)statsfiles for more information."
	}
	puthelp "PRIVMSG $chan :To request a copy:"
	puthelp "PRIVMSG $chan :    Goto http://$glstats(httpdip):$glstats(httpdport)/$glstats(statsfile) (ip restricted)"
	puthelp "PRIVMSG $chan :    Type '$glstats(cmdpre)dccstats' for dccsend."
	puthelp "PRIVMSG $chan :    Type '$glstats(cmdpre)mailstats address' to email copy."
	return
}
bind pub - $glstats(cmdpre)userstats glstats_showstats

proc glstats_dccstats { nick uhost hand chan text } {
global glstats 
	set text ""
	if {($glstats(restrict) == 1) && (![matchattr $hand $glstats(flag)|$glstats(flag) $chan])} {
		puthelp "PRIVMSG $chan :\-$glstats(sname)\- \[\002USERSTATS\002\] \- Sorry, but access to this command has been restricted."
		putlog "\[\002ERROR\002\] $nick attempted an unauthorized userstats request on $chan \@ [ctime [unixtime]]"
		return
	}
	if {([info exists glstats(statsfile)]) && ([file isfile "$glstats(statspath)/$glstats(statsfile)"])} {
		puthelp "NOTICE $nick :Initiating dccsend of '$glstats(statspath)/$glstats(statsfile)', please accept."
		dccsend "$glstats(statspath)/$glstats(statsfile)" $nick
	} else {
		puthelp "NOTICE $nick :Error, unable to find statsfile, send aborted." ; return
	}
}
bind pub - $glstats(cmdpre)dccstats glstats_dccstats

proc glstats_dccstatsfile { nick uhost hand chan text } {
global glstats 
	set text [lindex [split $text] 0]
	if {($glstats(restrict) == 1) && (![matchattr $hand $glstats(flag)|$glstats(flag) $chan])} {
		puthelp "PRIVMSG $chan :\-$glstats(sname)\- \[\002USERSTATS\002\] \- Sorry, but access to this command has been restricted."
		putlog "\[\002ERROR\002\] $nick attempted an unauthorized userstats request on $chan \@ [ctime [unixtime]]" ; return
	}
	if {[file isfile "$glstats(statspath)/$text"]} {
		puthelp "NOTICE $nick :Initiating dccsend of '$glstats(statspath)/$text', please accept."
		dccsend "$glstats(statspath)/$text" $nick
	} else {
		puthelp "NOTICE $nick :Error, unable to find statsfile, send aborted." ; return
	}
}
bind pub - $glstats(cmdpre)dccstatsfile glstats_dccstatsfile

proc glstats_mailstats { nick uhost hand chan text } {
global glstats 
	set text [lindex [split $text] 0]
	if {($glstats(restrict) == 1) && (![matchattr $hand $glstats(flag)|$glstats(flag) $chan])} {
		puthelp "PRIVMSG $chan :\-$glstats(sname)\- \[\002USERSTATS\002\] \- Sorry, but access to this command has been restricted."
		putlog "\[\002ERROR\002\] $nick attempted an unauthorized userstats request on $chan \@ [ctime [unixtime]]" ; return
	}
	if {[string equal {} $text]} { puthelp "NOTICE $nick :Error, please specify a valid email address, send aborted." ; return }
	if {([info exists glstats(statsfile)]) && ([file isfile "$glstats(statspath)/$glstats(statsfile)"])} {
		puthelp "NOTICE $nick :Emailing '$glstats(statspath)/$glstats(statsfile)' to '$text'."
		if {[catch {set email [open "|mail -s \"$glstats(statspath)/$glstats(statsfile)\" $text" w]} open_error] != 0} {
			putlog "\[\002ERROR\002\] Error trying to send email: $open_error" ; return
		}
		if {[catch {set file [open $glstats(statspath)/$glstats(statsfile) r]} open_error] != 0} {
			putlog "\[\002ERROR\002\] Could not open '$glstats(statspath)/$glstats(statsfile)' for reading:  $open_error" ; return
		}
		while {![eof $file]} {
			gets $file line
			if {![string equal {} $line]} {
				puts $email $line
			}
		}
		if {[catch {close $email} close_error] != 0} {
			putlog "\[\002ERROR\002\] Error closing mail channel:  $close_error" ; return
		}
		if {[catch {close $file} close_error] != 0} {
			putlog "\[\002ERROR\002\] Error closing '$glstats(statspath)/$glstats(statsfile)':  $close_error" ; return
		}
	} else {
		puthelp "NOTICE $nick :Error, unable to find statsfile, send aborted." ; return
	}
}
bind pub - $glstats(cmdpre)mailstats glstats_mailstats

proc glstats_mailstatsfile { nick uhost hand chan text } {
global glstats
	set statsfile [lindex [split $text] 0]
	set address [lindex [split $text] 1]
	if {($glstats(restrict) == 1) && (![matchattr $hand $glstats(flag)|$glstats(flag) $chan])} {
		puthelp "PRIVMSG $chan :\-$glstats(sname)\- \[\002USERSTATS\002\] \- Sorry, but access to this command has been restricted."
		putlog "\[\002ERROR\002\] $nick attempted an unauthorized userstats request on $chan \@ [ctime [unixtime]]"
		return
	}
	if {[string equal {} $address]} { puthelp "NOTICE $nick :Error, please specify a valid email address, send aborted." ; return }
	if {[file isfile "$glstats(statspath)/$statsfile"]} {
		puthelp "NOTICE $nick :Emailing '$glstats(statspath)/$statsfile' to '$address'."
		if {[catch {set email [open "|mail -s \"$glstats(statspath)/$statsfile\" $address" w]} open_error] != 0} {
			putlog "\[\002ERROR\002\] Error trying to send email: $open_error" ; return
		}
		if {[catch {set file [open $glstats(statspath)/$statsfile r]} open_error] != 0} {
			putlog "\[\002ERROR\002\] Could not open '$glstats(statspath)/$statsfile' for reading:  $open_error" ; return
		}
		while {![eof $file]} {
			gets $file line
			if {![string equal {} line]} {
				puts $email $line
			}
		}
		if {[catch {close $email} close_error] != 0} {
			putlog "\[\002ERROR\002\] Error closing mail channel:  $close_error" ; return
		}
		if {[catch {close $file} close_error] != 0} {
			putlog "\[\002ERROR\002\] Error closing '$glstats(statspath)/$statsfile':  $close_error" ; return
		}
	} else {
		puthelp "NOTICE $nick :Error, unable to find statsfile, send aborted." ; return
	}
}
bind pub - $glstats(cmdpre)mailstatsfile glstats_mailstatsfile

proc glstats_showfiles { nick uhost hand chan text } {
global glstats
	if {($glstats(restrict) == 1) && (![matchattr $hand $glstats(flag)|$glstats(flag) $chan])} {
		puthelp "PRIVMSG $chan :\-$glstats(sname)\- \[\002USERSTATS\002\] \- Sorry, but access to this command has been restricted."
		putlog "\[\002ERROR\002\] $nick attempted an unauthorized userstats request on $chan \@ [ctime [unixtime]]" ; return
	}
	set oldstats "[glob -nocomplain -type f -path $glstats(statspath)/ stats-*]"
	set num_oldstats "[llength $oldstats]"
	if {$num_oldstats != 0} {
		set size_oldstats 0
		foreach 1file $oldstats { incr size_oldstats [file size $1file] }
		glstats_update_html $size_oldstats "$oldstats"
		puthelp "PRIVMSG $chan :$num_oldstats old reports totalling $size_oldstats bytes found in $glstats(statspath). Use, $glstats(cmdpre)clearstats to remove."
		puthelp "PRIVMSG $chan :Displaying 5 most recent files:"
		set displayed 0
		foreach 1file [lsort -decreasing $oldstats] {
			if {$displayed >= 5} { break }
			puthelp "PRIVMSG $chan :\002Filename\002: [file tail $1file] \002Generated\002: [ctime [lindex [split [file tail $1file] -] 1]]"
			incr displayed
		}
		puthelp "PRIVMSG $chan :Full File List: http://$glstats(httpdip):$glstats(httpdport)"
		puthelp "PRIVMSG $chan :To request a file:"
		puthelp "PRIVMSG $chan :Type '!dlrdccstatsfile filename' for dccsend."
		puthelp "PRIVMSG $chan :Type '!dlrmailstatsfile filename address' to email copy."
		return
	} elseif {$num_oldstats == 0} {
		puthelp "PRIVMSG $chan :No stats files found." ; return
	} else { puthelp "PRIVMSG $chan :Unknown error occured, please contact script author" ; return }
}
bind pub - $glstats(cmdpre)statsfiles glstats_showfiles

proc glstats_clearstats { nick uhost hand chan text } {
global glstats
	if {($glstats(restrict) == 1) && (![matchattr $hand $glstats(flag)|$glstats(flag) $chan])} {
		puthelp "PRIVMSG $chan :\-$glstats(sname)\- \[\002USERSTATS\002\] \- Sorry, but access to this command has been restricted."
		putlog "\[\002ERROR\002\] $nick attempted an unauthorized userstats request on $chan \@ [ctime [unixtime]]" ; return
	}
	set statsfiles "[glob -nocomplain -type f -path $glstats(statspath)/ stats-*]"
	if {[info exists $glstats(statsfile)]} {
		foreach 1file $statsfiles {
			if {![string equal $glstats(statsfile) [file tail $1file]} {
				lappend oldstats $1file
			}
		}
	} else {
		set oldstats $statsfiles
	}
	set num_oldstats "[llength $oldstats]"
	if {$num_oldstats == 0} { puthelp "PRIVMSG $chan :No old stats files found to clear." ; return }
	foreach 1file $oldstats {
		if {[catch { file delete -force $1file } file_error] != 0} {
			puthelp "PRIVMSG $chan :\[\002ERROR\002\] Error while clearing oldstats: $file_error" ; return
		}
	}
	puthelp "PRIVMSG $chan :Successfully deleted $num_oldstats old userstats reports from $glstats(statspath)."
}
bind pub - $glstats(cmdpre)clearstats glstats_clearstats

## stolen httpd stuff (modified)

array set HttpdErrors {
	204 {No Content}
	400 {Bad Request}
	404 {Not Found}
	503 {Service Unavailable}
	504 {Service Temporarily Unavailable}
}

array set Httpd {
	bufsize 2768
	sockblock 0
}

proc Httpd_Server {root {myaddr {null}} {port 80} {default index.html}} {
global Httpd
	array set Httpd [list root $root port $port default $default]
	if {![string equal {null} $myaddr]} {
		set Httpd(listen) [socket -server HttpdAccept -myaddr $myaddr $port]
		set Httpd(name) $myaddr
	} else {
		set Httpd(listen) [socket -server HttpdAccept $port]
		set Httpd(name) [info hostname]
	}
	set Httpd(accepts) 0
	return $Httpd(port)
}

proc HttpdAccept {newsock ipaddr port} {
global Httpd glstats
	set allow_connect 0
	foreach user $glstats(httpdallowed) {
		array set stats [glstats_user $user]; if {![array size stats]} {continue}
		foreach ipmask $stats(IP) {
			if {[string match $ipmask $ipaddr]} {set allow_connect 1; break}
		}
		array unset stats; if {$allow_connect} {break}
	}
	if {$allow_connect != 1} {
		catch {close $newsock}
		Httpd_Log $newsock Error "connection refused from $ipaddr:$port"
		return
	}
	upvar #0 Httpd$newsock data
	incr Httpd(accepts)
	Httpd_Log $newsock Connect "from $ipaddr:$port"
	fconfigure $newsock -blocking $Httpd(sockblock) -buffersize $Httpd(bufsize) -translation {auto crlf}
	set data(ipaddr) $ipaddr
	set data(left) 50
	fileevent $newsock readable [list HttpdRead $newsock]
}

proc HttpdRead { sock } {
upvar #0 Httpd$sock data
	set readCount [gets $sock line]
	if {![info exists data(state)]} {
		if {[regexp {(POST|GET) ([^?]+)\??([^ ]*) HTTP/(1.[01])} $line x data(proto) data(url) data(query) data(version)]} {
			set data(state) mime
		} elseif {[string length $line] > 0} {
			HttpdError $sock 400
			Httpd_Log $sock Error "bad first line:$line"
			HttpdSockDone $sock
		} else {
			# Probably eof after keep-alive
			HttpdSockDone $sock
		}
		return
	}
	set state [string compare $readCount 0],$data(state),$data(proto)
	switch -- $state {
		0,mime,GET -
		0,query,POST { HttpdRespond $sock }
		0,mime,POST { set data(state) query }
		1,mime,POST -
		1,mime,GET {
			if [regexp {([^:]+):[ 	]*(.*)}  $line dummy key value] {
				set data(mime,[string tolower $key]) $value
			}
		}
		1,query,POST	{
			set data(query) $line
			HttpdRespond $sock
		}
		default {
			if [eof $sock] {
				Httpd_Log $sock Error "unexpected eof on <$data(url)> request"
			} else {
				Httpd_Log $sock Error "unhandled state <$state> fetching <$data(url)>"
			}
			HttpdError $sock 404
			HttpdSockDone $sock
		}
	}
}

proc HttpdRespond { sock } {
global Httpd
upvar #0 Httpd$sock data
	set mypath [HttpdUrl2File $Httpd(root) $data(url)]
	if {[string length $mypath] == 0} {
		HttpdError $sock 400
		Httpd_Log $sock Error "$data(url) invalid path"
		HttpdSockDone $sock
		return
	}
	if {![catch {open $mypath} in]} {
		puts $sock "HTTP/1.0 200 Data follows"
		puts $sock "Date: [HttpdDate [clock clicks]]"
		puts $sock "Last-Modified: [HttpdDate [file mtime $mypath]]"
		puts $sock "Connection: Keep-Alive"
		puts $sock "Content-Type: [HttpdContentType $mypath]"
		puts $sock "Content-Length: [file size $mypath]"
		puts $sock ""
		fconfigure $sock -translation binary -blocking $Httpd(sockblock)
		fconfigure $in -translation binary -blocking 1
		flush $sock
		fcopy $in $sock -command [list HttpdCopyDone $in $sock]
	} else {
		HttpdError $sock 404
		Httpd_Log $sock Error "$data(url) $in"
		HttpdSockDone $sock
	}
}

proc HttpdCopyDone {in sock bytes {errorMsg {}}} {
	close $in
	Httpd_Log $sock Done "$bytes total bytes"
	HttpdSockDone $sock [expr {[string length $errorMsg] > 0}]
}

array set HttpdMimeType {
	{} text/plain
	.txt text/plain
	.lst text/plain
	.htm text/html
	.html text/html
	.gif image/gif
	.jpg image/jpeg
}

proc HttpdContentType {path} {
	global HttpdMimeType
	set type text/plain
	catch {set type $HttpdMimeType([file extension $path])}
	return $type
}

set HttpdErrorFormat {
	<title>Error: %1$s</title>
	Got the error: <b>%2$s</b><br>
	while trying to obtain <b>%3$s</b>
}

proc HttpdError {sock code} {
upvar #0 Httpd$sock data
global HttpdErrors HttpdErrorFormat
	append data(url) ""
	set message [format $HttpdErrorFormat $code $HttpdErrors($code)  $data(url)]
	puts $sock "HTTP/1.0 $code $HttpdErrors($code)"
	puts $sock "Date: [HttpdDate [clock clicks]]"
	puts $sock "Content-Length: [string length $message]"
	puts $sock ""
	puts $sock $message
}

proc HttpdDate {clicks} {
	return [clock format $clicks -format {%a, %d %b %Y %T %Z}]
}

proc Httpd_Log {sock reason text} {
	putlog "\[\002HTTPD\002\] $sock $reason: $text"
}

proc HttpdUrl2File {root url} {
global HttpdUrlCache Httpd
	if {![info exists HttpdUrlCache($url)]} {
		lappend pathlist $root
		set level 0
		foreach part  [split $url /] {
			set part [HttpdCgiMap $part]
			if [regexp {[:/]} $part] {
				return [set HttpdUrlCache($url) ""]
			}
			switch -- $part {
				.  { }
				.. {incr level -1}
				default {incr level}
			}
			if {$level <= 0} {
				return [set HttpdUrlCache($url) ""]
			} 
			lappend pathlist $part
		}
		set file [eval file join $pathlist]
		if {[file isdirectory $file]} {
			set file [file join $file $Httpd(default)]
		}
		set HttpdUrlCache($url) $file
	}
	return $HttpdUrlCache($url)
}

proc HttpdCgiMap {data} {
	regsub -all {([][$\\])} $data {\\\1} data
	regsub -all {%([0-9a-fA-F][0-9a-fA-F])} $data  {[format %c 0x\1]} data
	return [subst $data]
}

proc HttpdClose {sock} {
upvar #0 Httpd$sock data
	if {($data(left) > 0) && (([info exists data(mime,connection)] && \
	([string tolower $data(mime,connection)] == "keep-alive")) || \
	($data(version) >= 1.1))} {
		set close 0
	} else {
		set close 1
	}
	return $close
}

proc HttpdSockDone { sock {close 0}} {
upvar #0 Httpd$sock data
global Httpd
	if {!$close && ($data(left) > 0) && (([info exists data(mime,connection)] && \
	([string tolower $data(mime,connection)] == "keep-alive")) ||
	($data(version) >= 1.1))} {
		set close 0
	} else {
		set close 1
	}
	if [info exists data(cancel)] {
		after cancel $data(cancel)
	}
	catch {close $data(infile)}
	if {$close} {
		catch {close $sock}
		unset data
	} else {
		# count down transations
		set left [incr data(left) -1]
		# Reset the connection
		flush $sock
		set ipaddr $data(ipaddr)
		unset data
		array set data [list linemode 1 version 0 left $left ipaddr $ipaddr]
		# Close the socket if it is not reused within a timeout
		set data(cancel) [after 10000 [list HttpdSockDone $sock 1]]
		fconfigure $sock -blocking 0 -buffersize $Httpd(bufsize) -translation {auto crlf}
		fileevent $sock readable [list HttpdRead $sock]
		fileevent $sock writable {}
	}
}

## let's start it (cross your fingers)
catch {close $Httpd(listen)}
if {[catch {Httpd_Server $glstats(statspath) $glstats(httpdip) $glstats(httpdport) index.html} httpd_error] != 0} {
	putlog "Error starting gluserstats.tcl httpd server: $httpd_error"
} else {
	putlog "gluserstats httpd active..."
	putlog "listening on $Httpd(name) port $Httpd(port)"
	putlog "allowed users: [join $glstats(httpdallowed) {, }]"
}

putlog "gluserstats.tcl v$gluserstats_ver by leprechau@efnet loaded."
