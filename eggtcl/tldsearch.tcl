## lookup tlds and give a link to more information
## powered by tld-resource.com
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::tldsearch {
	## settings
	variable target "chan"
	## set to either "nick" or "chan"
	variable outtype "privmsg"
	## set to either "privmsg" or "notice"
}

## this script requires my http package
## get it from: http://woodstock.anbcs.com/scripts/tcl/lephttp.tcl
package require lephttp

## set a control flag
setudef flag tldsearch

## setup a cache array...
array set ::tldsearch::cache [list]

proc ::tldsearch::outIt {target type nick txt} {
	## check if we have a match in the array...if so display and return
	if {[string length [set result [array get ::tldsearch::cache $txt]]]} {
		foreach {tld info} $result {foreach {desc pg} $info {}; break}
		puthelp "$type $target :.$tld = $desc \( http://www.tld-resource.com/tld-information/$pg \)"; return
	}
	## well looks like we didn't get a result...so let's tell them so
	puthelp "$type $target :Sorry $nick, I couldn't find any iformation for your tld request: $txt"; return
}

proc ::tldsearch::callback {target type nick txt token} {
	## check our status...
	if {[catch {::lephttp::status $token} status] != 0} {return}
	if {![string equal -nocase {ok} $status]} {
		switch -exact -- $status {
			timeout {
				puthelp "$type $target :Sorry $nick, connection to server timed out, please try again later."
				::lephttp::cleanup $token; return
			}
			default {
				puthelp "$type $target :Sorry $nick, an unknown error has occured, server output of the error is as follows: $status"
				::lephttp::cleanup $token; return
			}
		}
	}
	## set our data and cleanup the results
	set data [::lephttp::data $token]; ::lephttp::cleanup $token
	## check our results...and build our cache array
	foreach {x pg tld desc} [regexp -all -inline {<li><a href=\"http://www.tld-resource.com/tld-information/(.+?)\">(.+?)</a>\s-\s(.+?)</li>} $data] {
		array set ::tldsearch::cache [list $tld [list [::lephttp::map [::lephttp::strip $desc]] $pg]]
	}
	## okay...that's done let's output it and return
	::tldsearch::outIt $target $type $nick $txt; return
}

proc ::tldsearch::pubSearch {nick uhost hand chan text} {
	## check for our control flag...and that we actually got some text
	if {![channel get $chan tldsearch] || ![string length [set txt [string trim [lindex [split [string tolower $text]] 0] .]]]} {return}
	## get our target and output type from our settings
	switch -glob -- [string tolower $::tldsearch::target] {
		n* {set target $nick}
		c* {set target $chan}
		default {return -code error "invalid target set in tldsearch"}
	}
	switch -glob -- [string tolower $::tldsearch::outtype] {
		p* {set type PRIVMSG}
		n* {set type NOTICE}
		default {return -code error "invalid outtype set in tldsearch"}
	}
	## well so far so good...let's do it...but check our cache first
	if {[array size ::tldsearch::cache]} {
		## nice we have a cache...let's use it...output and return
		::tldsearch::outIt $target $type $nick $txt; return
	}
	## since tlds don't change very often we will only hit the web once per script load...the cache we build in the callback never expires
	::lephttp::geturl http://www.tld-resource.com/tldinfo.php -command [list ::tldsearch::callback $target $type $nick $txt] -timeout 10000
}
bind pub - !tld ::tldsearch::pubSearch

putlog "TLDsearch v0.1 by leprechau@EFnet LOADED!"
