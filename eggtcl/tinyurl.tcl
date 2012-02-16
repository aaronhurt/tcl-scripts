## url title poster and link shortener via tinyurl or metamark
##
## by leprechau@EFnet
##
## initial version...no documentation or support
## other than provided herein...
##
## flags: .chanset #chan +notinyurl
##
## NOTE: the only official location for any of my scripts
## http://woodstock.anbcs.com/scripts/
##
#

namespace eval ::tinyurl {

## set the minimum length url to shorten
## a tinyurl link will be around 25 chars
## metamark urls are around 10 chars
variable minlength 15

## who do you want to use as you link shortener
## you can choose 'tinyurl' or 'metamark'
variable sprovider "metamark"

## we are going to use my http package...
package require lephttp

## set a little udef for control
setudef flag notinyurl

## setup a temporary storage array
variable tmps; array set tmps [list]

}

## do the output
proc ::tinyurl::outit {target uid} {
	puthelp "PRIVMSG $target :[join [list $::tinyurl::temps($uid,short) $::tinyurl::temps($uid,title)] { -> }]\
	\($::tinyurl::temps($uid,size) bytes\)"
}

## handle http callbacks
proc ::tinyurl::getit {target uid type token} {
	if {![string equal -nocase {ok} [::lephttp::status $token]] && [::lephttp::ncode $token] != 200} {
		::lephttp::cleanup $token; return
	}
	switch -exact -- $type {
		TINY {
			## parse out our url from the tinyurl.com page
			if {![regexp -all -nocase -- {\[<a\shref=\"(.+?)\"} [::lephttp::data $token] x short]} {set short {}}
			## cleanup our token and store shorturl
			::lephttp::cleanup $token; array set ::tinyurl::temps [list $uid,short [string trim $short]]
		}
		METAMARK {
			## fetch the short url and cleanup our token...metamark is easy...
			array set ::tinyurl::temps [list $uid,short [lindex [split [::lephttp::data $token] \n] 0]]
			::lephttp::cleanup $token
		}
		TITLE {
			if {[string match -nocase {*text/html*} [set cType [::lephttp::header $token Content-type]]]} {
				## parse out our title from the url...if we don't have a head...let's stop...
				if {![regexp -all -nocase -- {<head>(.+?)</head>} [::lephttp::data $token] x head]} {return}
				if {![regexp -all -nocase -- {<title>(.+?)</title>} $head x title]} {set title {N/A}}
				## cleanup our token and store title and the page size
			} else {set title "non html ($cType)"}
			array set ::tinyurl::temps [list $uid,title [string trim [::lephttp::map $title]]\
			$uid,size [string bytelength [::lephttp::data $token]]];  ::lephttp::cleanup $token
		}
	}
	## see if we have all our info...if so...output
	if {[info exists ::tinyurl::temps($uid,short)] && [info exists ::tinyurl::temps($uid,title)]} {
		::tinyurl::outit $target $uid
	}
}

## pub proc...grab the urls and pass em off to callback
proc ::tinyurl::grabit {nick uhost hand chan text} {
	## check that we are not disabled
	if {[channel get $chan notinyurl]} {return}
	## well we are still going..let's do it...find and possibly format our url..
	if {([set index [lsearch -glob [split $text] http://*.*]] == -1) &&\
	([set index [lsearch -glob [split $text] www.*]] == -1)} {return}
	if {![string match http://* [set url [lindex [split $text] $index]]]} {
		set url http://$url
	}; set uid [md5 $url]
	## log this...just for giggles
	putlog "doing $::tinyurl::sprovider for $url posted by $nick\@$chan ..."
	## check our cache...
	if {[info exists ::tinyurl::temps($uid,short)] && [info exists ::tinyurl::temps($uid,title)]} {
		## nice we have it...outit and stop..
		::tinyurl::outit $chan $uid; return
	}
	## not in cache...check if we are long enough to tiny...
	if {[string length $url] >= $::tinyurl::minlength} {
		## make sure we have a valid provider set...if not default to metamark...
		switch -glob -- [string tolower $::tinyurl::sprovider] {
			tiny* {
				if {[catch {::lephttp::geturl http://tinyurl.com/create.php\
				-query [::lephttp::formatQuery url $url submit "Make TinyURL!"]\
				-timeout 5000 -command [list ::tinyurl::getit $chan $uid TINY]} Err] != 0} {
					return
				}
				
			}
			meta* {
				if {[catch {::lephttp::geturl http://metamark.net/api/rest/simple?long_url=[::lephttp::encode $url]\
				-timeout 5000 -command [list ::tinyurl::getit $chan $uid METAMARK]} Err] != 0} {
					return
				}
			}
		}
	} else {array set ::tinyurl::temps [list $uid,short $url]}
	## try to get a topic...
	if {[catch {::lephttp::geturl $url -timeout 5000 -command\
	[list ::tinyurl::getit $chan $uid TITLE]} Err] != 0} {return}; return
}
bind pubm - * ::tinyurl::grabit

putlog "tinyurl poster v0.1 by leprecau@EFnet loaded!"

## EOF ##
