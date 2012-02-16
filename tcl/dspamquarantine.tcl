#!/usr/local/bin/tclsh8.4
##
### Usage: crontab this script as root and run it as often as neccessary
### for your particular server volume...
###
### Purpose: append messages quarantined by simscan to the appropriate
### user.mbox quarantine file used by the dspam web cgi....also support
### is provided for the firstspam.txt and quarantinefull.txt notifications
#
namespace eval ::dspam {
	## full path to dspam home
	variable dhome "/var/db/dspam"
	## full path to the simscan quarantine
	variable simqdir "/var/qmail/quarantine"
	## full path to our rcpthosts
	variable rcpthosts "/var/qmail/control/rcpthosts"
	## full path to you vpopmail installation
	variable vhome "/usr/local/vpopmail"
	## quota warn size in bytes
	variable qwarn "1048576" ;# 1mb
	## use builtin deliver...or my vdeliver wrapper...set to "" to use internal
	variable dagent "/usr/local/vpopmail/bin/dspamdeliver.tcl"
	## use mysql to ensure accurate lookups...set to "" to parse headers
	variable mysqldb "socket:dbuser:dbass:dbname"
	## are our preferences stored in mysql (1 or 0)
	variable mysqlprefs "0"
}

## are we going to be using mysql??
if {[info exists ::dspam::mysqldb] && [string length $::dspam::mysqldb]} {
	package require mysqltcl 3.0
}

## generate our maildir file names and deliver the message
proc ::dspam::deliver {user host msg} {
	## which delivery are we using...
	if {[info exists ::dspam::dagent] && [string length $::dspam::dagent]} {
		catch {exec $::dspam::dagent $user\@$host << $msg}; return
	} else {
		## check for an alias...and adjust accordingly if found
		if {[catch {exec [file join $::dspam::vhome bin valias] -d $user\@$host} email] == 0} {
			set email [string trimleft [lindex [split [lindex [split $email \n] end]] end] &]
		} else {set email $user\@$host}
		## get our delivery path...
		if {[catch {exec [file join $::dspam::vhome bin vuserinfo] -d $email} path] != 0} {return}
		## sometimes info hostname returns incorrect..try to use system bin instead
		if {[catch {exec hostname} hostname] != 0} {set hostname [info hostname]}
		## set the filename and catch the write
		set fname [clock seconds].[expr {abs([clock clicks -milliseconds])+[pid]}].$hostname
		catch {puts [set fid [open [set mfile [file join $path Maildir new $fname]] w 0600]] $msg; close $fid}
		## fix permissions
		catch {exec [file join [file separator] usr sbin chown] vpopmail:vchkpw $mfile}
	}
}

## pull out all of our headers and return a nice keyed list
proc ::dspam::gethead {head} {
	array set tmp [list]; foreach line $head {
		switch -glob -- [lindex [split [set line [string trim $line]]] 0] {
			*: {
				set header [string trimright [string tolower [lindex [split $line] 0]] :]
				if {![info exists tmp($header)]} {
					set tmp($header) [join [lrange [split $line] 1 end]]
				} else {set tmp($header) "$tmp($header) [join [lrange [split $line] 1 end]]"}
			}
			default {set tmp($header) "$tmp($header) $line"}
		}
	}
	return [array get tmp]
}

## check and do notifications
proc ::dspam::notify {user host qsize} {
	## check for user.firstspam
	if {![file exists [set fname [file join $::dspam::dhome data $host $user $user.firstspam]]]} {
		## sanity check....and grab our firstspam.txt content....
		if {![file exists [set src [file join $::dspam::dhome txt firstspam.txt]]] || ![file writable $src]} {return}
		if {[catch {set data [string map [list \$u $user\@$host] [read [set fid [open $src r]]]]; close $fid}] != 0} {return}
		## create our user.firstspam file and insert the current date in unixtime
		if {[catch {puts [set fid [open $fname w]] [clock seconds]; close $fid}] != 0} {return}
		## fix permissions
		catch {exec [file join [file separator] usr sbin chown] vpopmail:vchkpw $fname}
		## prepend a date header and deliver the message...
		::dspam::deliver $user $host "Date: [clock format [clock seconds] -format {%a, %d %b %Y %H:%M:%S +0000} -gmt 1]\n$data"
	}
	if {$qsize >= $::dspam::qwarn} {
		## sanity check....and grab our quarantinefull.txt content....
		if {![file exists [set src [file join $::dspam::dhome txt quarantinefull.txt]]] || ![file writable $src]} {return}
		if {[catch {set data [string map [list \$u $user\@$host] [read [set fid [open $src r]]]]; close $fid}] != 0} {return}
		## prepend a date header and deliver the message...
		::dspam::deliver $user $host "Date: [clock format [clock seconds] -format {%a, %d %b %Y %H:%M:%S +0000} -gmt 1]\n$data"
	}
}

## build our mbox file
proc ::dspam::buildit {fname} {
	## couple sanity checks
	if {![file exists $fname] || ![file isfile $fname] || ![file readable $fname]} {return}
	## get our message and perform any From_ quoting neccessary
	foreach line [split [string trim [read [set fid [open $fname r]]]] \n] {
		## build our header...seperate from message body
		if {[string length $line] && ![info exists doneHead]} {lappend head [string trim $line]}
		## we got a blank line....that's it for the header
		if {![info exists doneHead] && ![string length $line]} {set doneHead 1}
		## start forming the body adn doing our From_ quoting
		if {[info exists doneHead]} {lappend body [regsub -all -- {^((>+From\s)|(From\s)).+$} $line {>\0}]}
	}; catch {close $fid}
	## parse our headers....
	array set xhead [::dspam::gethead $head]
	## we are going to try and make sure we send this to the right user
	if {[info exists xhead(to)]} {
			## first thing...read our rcpthosts to make sure we are pulling a domain we serve
			if {[catch {set rcpthosts [split [read [set fid [open $::dspam::rcpthosts r]]] \n]; close $fid}] != 0} {return}
			## okay .... here we go...
			foreach {email - - - -} [regexp -nocase -all -inline -- {([a-zA-Z0-9_'+*$%\^&!\.\-])+@(([a-zA-Z0-9\-])+\.)+([a-zA-Z0-9:]{2,4})+} [string tolower $xhead(to)]] {
					## take the first email that matches something we serve
					if {[lsearch -exact $rcpthosts [lindex [split [string tolower $email] @] end]] != -1} {set rcptto $email; break}
			}
	} else {return}
	## build and insert our From line...also combine the head and body to form our whole message
	set msg [linsert [concat $head $body] 0 "From QUARANTINE [clock format [clock seconds] -format {%a %b %d %T %Y}]"]
	## get the recipient user and host from our To: header
	foreach {user host} [split [string tolower $rcptto] @] {break}
	## verify we are good to continue...
	if {![info exists user] || ![string length $user] || ![info exists host] || ![string length $host]} {return}
	## validate our user path
	if {![file isdir [file join $::dspam::dhome data $host $user]]} {return}
	## validate our mailbox file
	if {[file exists [set mbox [file join $::dspam::dhome data $host $user $user.mbox]]] && ![file writable $mbox]} {return}
	## catch our write and do it...
	if {[catch {puts -nonewline [set fid [open $mbox a+]] [join $msg \n]\n\n; close $fid}] != 0} {return}
	## fix permissions...
	catch {exec [file join [file separator] usr sbin chown] vpopmail:vchkpw $mbox}
	## delete our source file...if we made it this far everything is safe...
	catch {file delete -force $fname}; ::dspam::notify $user $host [file size $mbox]
}

## do it...
proc ::dspam::doit {} {
	if {[llength [set flist [glob -type f -dir $::dspam::simqdir spamc*]]] > 0} {
		## loop through all our files
		foreach fname $flist {
			catch {::dspam::buildit $fname}
			## if it's still there let's just delete it...
			##if {[file exists $fname]} {catch {file delete -force $fname}}
		}
	}
}

## let's go...
::dspam::doit; exit 0
