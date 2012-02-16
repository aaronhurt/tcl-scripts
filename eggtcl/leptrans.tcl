##################################################
## public translator version 1.3                ##
## by leprechau@efnet                           ##
## Sunday, October 27, 2002 -- 1.0              ##
## Friday, January 17, 2003 -- 1.2              ##
## Monday, October 27, 2003 -- 1.3 (final)      ##
## Monday, October 25, 2005 -- 1.3.1 (lephttp)	##
##################################################
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

## the translator you wish to use (worldlingo or tranexp)
set leptrans(engine) "tranexp"

## the path to your document root
set leptrans(docroot) "/home/ahurt/lepster/text"

## ip you want httpd listening on
set leptrans(httpdip) "64.71.131.21"

## port you want httpd listening on
set leptrans(httpdport) "65080"

## ip masks allowed to connect to httpd
## should be the ip of the translation service
## 209.247.193.211 (www.worldlingo.com)
## 209.51.138.18, 216.180.241.154 and 67.136.24.36 (www.tranexp.com)
set leptrans(httpdallowed) {
	209.247.193.211
	209.51.138.18
	216.180.241.154
	67.136.24.36
}

##################################################
##          DO NOT EDIT THIS SCRIPT             ##
##         DOING SO IS NOT SUPPORTED            ##
##################################################
set leptrans(version) "1.3.1"

## get my http package from
## http://woodstock.anbcs.com/scripts/lephttp.tcl
package require lephttp

set leptrans(useragent) "MSIE 6.0"
if {([info exists leptrans(httpdip)]) && ([string equal {} $leptrans(httpdip)])} {
	set leptrans(httpdip) "myaddr"
}
switch -- $leptrans(engine) {
	worldlingo {
		set leptrans(languages) {
			english dutch french german greek italian portuguese spanish
		}
	}
	tranexp {
		set leptrans(languages) {
			english bulgarian croation danish dutch spanish finnish french
			german greek hungarian icelandic italian norwegian polish portuguese
			romanian russian serbian slovenian swedish welsh turkish latin
		}
	}
}
if {[info exists leptrans(active)]} {array unset leptrans active}
catch {
	set file [open $leptrans(docroot)/index.html w 0644]
	puts $file "<html><head><title>leptrans.tcl version $leptrans(version)</title></head>"
	puts $file "<body bgcolor=#ffffff text=#000000><div align=\"center\"><h1>Welcome</h1>"
	puts $file "<h2>You have reached the temp docroot of an eggdrop running leptrans.tcl version $leptrans(version), nothing to see here.</h2>"
	puts $file "</div></body></html>"
	close $file
}

proc hexencode {text} {
	set encoded {}
	foreach 1char [split $text {}] {
		append encoded "%[format %02X [scan $1char %c]]"
	}
	return $encoded
}

proc urlencode {text} {
	foreach 1char [split $text {}] {
		if {(![string equal {.} $1char]) && ([regexp \[^a-zA-Z0-9_\] $1char])} {
			append encoded "[hexencode $1char]"
		} else { append encoded "$1char" }
	}
	return $encoded
}

proc unhtml {text} {
	regsub -all -- {(<.+?>)} $text {} text
	return $text
}

proc rands { length } {
	set rs ""
	for {set j 0} {$j < $length} {incr j} {
		set x [rand 62]
		append rs [string range "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789" $x $x]
	}
	return $rs
}

proc kill_timer {command} {
	set timer_id [join [lrange [split [string trim $command] " "] 0 end]]
	set killed 0
	foreach 1timer [timers] {
		if {[string match [lindex $1timer 1] $timer_id]} {
			killtimer [lindex $1timer 2]
			set killed 1
		}
	}
	return $killed
}

proc kill_utimer {command} {
	set timer_id [join [lrange [split [string trim $command] " "] 0 end]]
	set killed 0
	foreach 1utimer [utimers] {
		if {[string match [lindex $1utimer 1] $timer_id]} {
			killutimer [lindex $1utimer 2]
			set killed 1
		}
	}
	return $killed
}

proc settimer {minutes command} {
	if {$minutes < 1} { set minutes 1 }
	kill_timer "$command"
	timer $minutes "$command"
}

proc setutimer {seconds command} {
	if {$seconds < 1} { set seconds 1 }
	kill_utimer "$command"
	utimer $seconds "$command"
}

proc clean_cache_files {list} {
	global leptrans
	foreach 1file $list {
		file delete -force $leptrans(docroot)/$1file
	}
}

proc lang2code {lang} {
global leptrans
	if {[string match {worldlingo} $leptrans(engine)]} {
		switch -- $lang {
			english { return en }
			dutch { return nl }
			french { return fr }
			german { return de }
			greek { return el }
			italian { return it }
			portuguese { return pt }
			spanish { return es }
		}
	} elseif {[string match {tranexp} $leptrans(engine)]} {
		return [string range $lang 0 2]
	}
}

proc code2lang {code} {
global leptrans
	if {[string match {worldlingo} $leptrans(engine)]} {
		switch -- $code {
			en { return english }
			nl { return dutch }
			fr { return french }
			de { return german }
			el { return greek }
			it { return italian }
			pt { return portuguese }
			es { return spanish }
		}
	} elseif {[string match {tranexp} $leptrans(engine)]} {
		switch -- $code {
			eng { return english }
			bul { return bulgarian }
			cro { return croation }
			dan { return danish }
			dut { return dutch }
			spa { return spanish }
			fin { return finnish }
			fre { return french }
			ger { return german }
			gre { return greek }
			hun { return hungarian }
			ice { return icelandic }
			ita { return italian }
			nor { return norwegian }
			pol { return polish }
			por { return portuguese }
			rom { return romanian }
			rus { return russian }
			ser { return serbian }
			slo { return slovenian }
			swe { return swedish }
			wel { return welsh }
			tur { return turkish }
			lat { return latin }
		}
	}
}

proc trans_showhelp {chan nick} {
global leptrans
	puthelp "PRIVMSG $chan :\[\002$nick\002\] I think '!translation help' could do wonders for you."
	if {[info exists leptrans(active)]} {array unset leptrans active}
	return
}

proc trans_callback {chan nick token} {
global leptrans
	set status [::lephttp::status $token]
	if {![string equal -nocase {ok} $status]} {
		switch -- $status {
			timeout {
				puthelp "PRIVMSG $chan :\[\002Translation\002\] Timeout (60 seconds) on connection to server, please try again later."
				catch {array unset leptrans active ; file delete -force $leptrans(docroot)/$leptrans(transfile)} ; return
			}
			default {
				puthelp "PRIVMSG $chan :\[\002Translation\002\] Unknown error has occured, server output of the error is as follows: $status"
				catch {array unset leptrans active ; file delete -force $leptrans(docroot)/$leptrans(transfile)} ; return
			}
		}
	}
	set data [::lephttp::data $token]
	set ttime "[expr ([clock clicks -milliseconds] - $leptrans(startclicks).0) / 1000]"
	if {$ttime > 60.0} {
		set ttime "[expr $ttime / 60.0] Minutes"
	} else {
		set ttime "$ttime Seconds"
	}
	#putlog "raw data == $data"
	set data [unhtml [join [lindex [split $data \n] 0]]]
	if {![string equal {} $data]} {
		putserv "PRIVMSG $chan :\[\002Translation\002\] $data \002Elapsed Time:\002 $ttime"
	} else {
		putserv "PRIVMSG $chan :\[\002Translation\002\] Sorry, an unknown error has occured, please try again later. \002Elapsed Time:\002 $ttime"
	}
	set page [::lephttp::cleanup $token]
	catch {array unset leptrans active ; file delete -force $leptrans(docroot)/$leptrans(transfile)}
	return
}

proc pub_translate {nick uhost hand chan text} {
global leptrans
	if {[info exists leptrans(active)]} {
		puthelp "PRIVMSG $chan :\[\002Translation\002\] Currently processing another translation.  Please wait a moment and try again."
		return
	}
	if {(![string equal {} $text]) && ([string match *-* "[lindex [split $text] 0]"]) && (![string equal {} [lindex [split $text] 1]])} {
		set t_from "[lindex [split [lindex [split $text] 0] {-}] 0]"
		set t_to "[lindex [split [lindex [split $text] 0] {-}] 1]"
		set text "[join [lrange [split $text] 1 end]]"
	} else {
		trans_showhelp $chan $nick ; return
	}
	if {(![string match *$t_from* $leptrans(languages)]) || (![string match *$t_to* $leptrans(languages)])} {
		trans_showhelp $chan $nick
		return
	}
	set leptrans(active) 1
	#putserv "PRIVMSG $chan :\[\002Translation\002\] Translating '$text' from $t_from to $t_to, please be patient..."
	setutimer 60 "catch {array unset leptrans active}"
	set leptrans(startclicks) "[clock clicks -milliseconds]"
	set leptrans(transfile) "[md5 [getchanhost $nick $chan]].[rands 5].txt"
	set cachefiles "[glob -nocomplain -tails -type f -path $leptrans(docroot)/ [md5 [getchanhost $nick $chan]].*]"
	if {(![string equal {} $cachefiles]) && ([llength $cachefiles] >= 1)} {
		puthelp "PRIVMSG $chan :\[\002Translation\002\] Error, cache data already exists for your hostmask, please wait a moment and try again."
		setutimer 60 "clean_cache_files [list $cachefiles]"
		catch {array unset leptrans active} ; return
	}
	catch {file delete -force $leptrans(docroot)/$leptrans(transfile)}
	if {[catch {set tmpfile [open $leptrans(docroot)/$leptrans(transfile) w 0644]} open_error] != 0} {
		putlog "\[\002ERROR\002\] Could not open temp file '$leptrans(docroot)/$leptrans(transfile)' for writing:  $open_error"
		catch {array unset leptrans active ; file delete -force $leptrans(docroot)/$leptrans(transfile)} ; return
	}
	if {[catch { puts $tmpfile "$text" } write_error] != 0} {
		putlog "\[\002ERROR\002\] Could not write to temp file '$leptrans(docroot)/$leptrans(transfile)':  $write_error"
		catch {array unset leptrans active ; file delete -force $leptrans(docroot)/$leptrans(transfile)} ; return
	}
	if {[catch {close $tmpfile} close_error] != 0} {
		putlog "\[\002ERROR\002\] Error closing temp file '$leptrans(docroot)/$leptrans(transfile)':  $close_error"
		catch {array unset leptrans active ; file delete -force $leptrans(docroot)/$leptrans(transfile)} ; return
	}
	set t_url "$leptrans(httpdip):$leptrans(httpdport)/$leptrans(transfile)"
	switch -- $leptrans(engine) {
		worldlingo {
			set t_tran "[string toupper [lang2code $t_from]]-[lang2code $t_to]"
			set url "http://www.worldlingo.com/wl/translate?wl_lp=$t_tran&wl_fl=2&wl_rurl=[urlencode $t_url]&wl_url=$t_url&wl_g_table=-3"
		}
		tranexp {
			set t_from "[string range $t_from 0 2]" ; set t_to "[string range $t_to 0 2]"
			set url "http://www.tranexp.com:2000/Translate/index.shtml?type=url&url=[urlencode $t_url]&from=$t_from&to=$t_to&Submit.x=16&Submit.y=16"
		}
	}
	::lephttp::fetch $url -command [list trans_callback $chan $nick] -timeout 60000
}
bind pub - !translate pub_translate

proc pub_transinfo {nick uhost hand chan text} {
global leptrans
	if {[info exists leptrans(active)]} {
		puthelp "PRIVMSG $chan :\[\002Translation\002\] Currently processing another translation.  Please wait a moment and try again." ; return
	}
	set text [string tolower [lindex $text] 0]
	if {[string match [join [split $text]] "help"]} {
		set langlist {}
		putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !translate from-to what to translate"
		putserv "PRIVMSG $chan :\[\002$nick\002\] Example: !translate english-dutch I love lepster."
		putserv "PRIVMSG $chan :\[\002$nick\002\] Languages: [join [join $leptrans(languages)] {, }]"
	} else {
		putserv "PRIVMSG $chan :\[\002$nick\002\] Unknown request, try '!translation help'."
	}
	if {[info exists leptrans(active)]} {array unset leptrans active} ; return
}
bind pub - !translation pub_transinfo

##################################################
## begin stolen httpd stuff (slightly modified) ##
##################################################

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

array set Httpd [list allowed $leptrans(httpdallowed)]

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
global Httpd
	set allow_connect 0
	foreach ipmask $Httpd(allowed) {
		if {[string match $ipmask $ipaddr]} { set allow_connect 1 ; break }
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
	if [info exists data(infile)] {
		catch {close $data(infile)}
	}
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

############################
## end stolen httpd stuff ##
############################

## let's start it (cross your fingers)
catch {array unset Httpd listen}
if {[catch {Httpd_Server $leptrans(docroot) $leptrans(httpdip) $leptrans(httpdport) index.html} httpd_error] != 0} {
	putlog "Error starting leptrans.tcl httpd server: $httpd_error"
} else {
	putlog "leptrans httpd active..."
	putlog "listening on $leptrans(httpdip) port $leptrans(httpdport)"
	putlog "allowed ips: [join $leptrans(httpdallowed) {, }]"
}

putlog "leptrans.tcl v$leptrans(version) by leprechau@efnet loaded."
