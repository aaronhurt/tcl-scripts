## no help or documentation other than provided herein
## weatherxml.tcl v0.3 - leprechau@EFNet
## to use this script you need to signup for a free weather.com account
## http://registration.weather.com/registration/xmloap/step1
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::weather {
	namespace export pubWeather
	variable par "YOUR_PARTNER_ID_HERE"
	variable key "YOUR_AFFILIATE_KEY_HERE"

	## get my http package from
	## http://woodstock.anbcs.com/scripts/lephttp.tcl
	package require lephttp
	variable locids; array set locids [list]

	proc urlencode {text} {
		foreach 1char [split $text {}] {
			if {(![string equal {.} $1char]) && ([regexp \[^a-zA-Z0-9_\] $1char])} {
				append encoded "%[format %02X [scan $1char %c]]"
			} else { append encoded "$1char" }
		}
		return $encoded
	}

	proc mconv {val unit} {
		if {![string is int [string map {. {}} $val]]} { return $val }
		switch -exact -- $unit {
			F {
				set ct [expr {(($val - 32) * 5.0) / 9.0}]
				return "$val[format %c 176]F/[lindex [split $ct {.}] 0].[string index [lindex [split $ct {.}] 1] 0][format %c 176]C"
			}
			C {
				set ct [expr {(($val * 9.0) / 5.0) + 32}]
				return "[lindex [split $ct {.}] 0].[string index [lindex [split $ct {.}] 1] 0][format %c 176]F/$val[format %c 176]C"
			}
			mi {
				set ct [expr {$val * 1.61}]
				return "${val}mi/[lindex [split $ct {.}] 0].[string index [lindex [split $ct {.}] 1] 0]km"
			}
			km {
				set ct [expr {$val * 0.62}]
				return "[lindex [split $ct {.}] 0].[string index [lindex [split $ct {.}] 1] 0]mi/${val}km"
			}
			mph {
				set ct [expr {$val * 1.61}]
				return "${val}mph/[lindex [split $ct {.}] 0].[string index [lindex [split $ct {.}] 1] 0]km/h"
			}
			{km/h} {
				set ct [expr {$val * 0.62}]
				return "[lindex [split $ct {.}] 0].[string index [lindex [split $ct {.}] 1] 0]mph/${val}km/h"
			}
			in {
				set ct [expr {$val * 2.54}]
				return "${val}inHg/[lindex [split $ct {.}] 0].[string index [lindex [split $ct {.}] 1] 0]cmHg"
			}
			mm {
				set ct [expr {$val / 25.4}]
				return "[lindex [split $ct {.}] 0].[string index [lindex [split $ct {.}] 1] 0]inHg/${val}cmHg"
			}
		}
	}

	proc callback {type chan nick token} {
		variable uagent; variable par; variable key; variable locids
		if {[catch {::lephttp::status $token} status] != 0} {return}
		if {![string equal -nocase {ok} $status]} {
			switch -exact -- $status {
				timeout {
					puthelp "PRIVMSG $chan :\[\002$nick\002\] Timeout (60 seconds) on connection to server, please try again later."
					::lephttp::cleanup $token; return
				}
				default {
					puthelp "PRIVMSG $chan :\[\002$nick\002\] Unknown error has occured, server output of the error is as follows: $status"
					::lephttp::cleanup $token; return
				}
			}
		}
		switch -exact -- $type {
			LOOKUP {
				foreach line [split [::lephttp::data $token] \n] {
					if {[string equal {} [set line [string trim $line]]]} {continue}
					if {[regexp -- {<loc id=\"([^\"]*)\" type=\"([0-9])\">([^<]*)</loc>} $line match id ltype text]} {
						## let's build our cache as much as we can...
						array set locids [list $id $text]
						## add id to temp array
						array set curids [list $id $text]
					}
				}
				::lephttp::cleanup $token
				switch -exact -- [array size curids] {
					0 {
						putserv "PRIVMSG $chan :\[\002$nick\002\] Sorry, I couldn't find any locations that matched your request."
					}
					1 {
						::lephttp::fetch http://xoap.weather.com/weather/local/[lindex [array get curids] 0]?cc=*&link=xoap&prod=xoap&par=$par&key=$key -command [list ::weather::callback WEATHER $chan $nick] -timeout 60000
					}
					default {
						foreach {name value} [array get curids] {lappend locs "$value"}
						putserv "PRIVMSG $chan :\[\002$nick\002\] I found more than one location for that request, please be more specific."
						putserv "PRIVMSG $chan :\[\002$nick\002\] The following locations matched your query: [join $locs { - }]."
					}
				}
			}
			WEATHER {
				foreach line [split [::lephttp::data $token] \n] {
					if {[string equal {} [set line [string trim $line]]]} {continue}
					switch -glob -- $line {
						{<head>} {set block head}
						{<loc id="*">} {set block loc}
						{<swa>} - {<a id="*" uc="*">} {set block swa}
						{<cc>} - {</bar>} - {</wind>} - {</uv>} - {</moon>} {set block cc}
						{<bar>} {set block bar}
						{<wind>} {set block wind}
						{<uv>} {set block uv}
						{<moon>} {set block moon}
						{</cc>} - {</weather>} {continue}
						{<*>*} {
							if {![info exists block]} {continue}
							regexp -- {(<.+?>)([^<]*)(<.+?>)} $line match stag text etag
							array set $block [list [string trim $stag {<>}] $text]
						}
					}
				}
				::lephttp::cleanup $token
				switch -exact -- [channel get $chan shortweather] {
					0 {
						puthelp "PRIVMSG $chan :\002$loc(dnam)\002 @ $loc(tm) GMT $loc(zone) \002Lattitude\002: $loc(lat)[format %c 176] \002Longitude\002: $loc(lon)[format %c 176]"
						if {[array size swa]} {
							puthelp "PRIVMSG $chan :\002\026$swa(t)\026\002"
							puthelp "PRIVMSG $chan :\002\026$swa(l)\026\002"
						}
						puthelp "PRIVMSG $chan :\002Temp\002: [::weather::mconv $cc(tmp) $head(ut)] \002Index\002: [::weather::mconv $cc(flik) $head(ut)] \002Wind\002: $wind(t) [::weather::mconv $wind(s) $head(us)] \002Condition\002: $cc(t) \002Humidity\002: $cc(hmid)%"
						puthelp "PRIVMSG $chan :\002Visibility\002: [::weather::mconv $cc(vis) $head(ud)] \002Barometer\002: [::weather::mconv $bar(r) $head(ur)] $bar(d) \002Dewpoint\002: [::weather::mconv $cc(dewp) $head(ut)] \002UV\002: $uv(i) $uv(t)"
						puthelp "PRIVMSG $chan :\002Moon\002: $moon(t) \002Observation Station\002: $cc(obst) \002Last Update\002: $cc(lsup)"
						puthelp "PRIVMSG $chan :\Weather data provided by \037weather.com\037[format %c 174] -> http://www.weather.com/?prod=xoap&par=$par"
					}
					1 {
						puthelp "PRIVMSG $chan :\002$loc(dnam)\002 @ $loc(tm) GMT $loc(zone) \002Temp\002: [::weather::mconv $cc(tmp) $head(ut)] \002Index\002: [::weather::mconv $cc(flik) $head(ut)] \002Wind\002: $wind(t)"
						if {[array size swa]} {
							puthelp "PRIVMSG $chan :\002\026$swa(t)\026\002"
							puthelp "PRIVMSG $chan :\002\026$swa(l)\026\002"
						}
						puthelp "PRIVMSG $chan :\002Condition\002: $cc(t) \002Humidity\002: $cc(hmid)% \002Barometer\002: [::weather::mconv $bar(r) $head(ur)] $bar(d) \002Dewpoint\002: [::weather::mconv $cc(dewp) $head(ut)]"
						puthelp "PRIVMSG $nick :Weather data provided by \037weather.com\037[format %c 174] -> http://www.weather.com/?prod=xoap&par=$par"
					}
				}
			}
		}
	}

	proc pubWeather {nick uhost hand chan text} {
		variable par; variable key; variable uagent; variable locids
		if {[channel get $chan noweather]} {return}
		if {[string equal {} [set text [string trim $text]]]} {
			putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !weather <zip code> OR !weather <city, location>"; return
		}
		## check to see if we were passed a us zip code
		if {(![string is int $text]) || ([string length $text] != 5)} {
			## if we didn't get a zip code, we need to lookup the locid..but let's check the cache first
			foreach {name value} [array get locids] {
				if {[string equal -nocase $text $value]} {
					## alright, the cache paid off...no need to query slow weather.com for this id
					::lephttp::fetch http://xoap.weather.com/weather/local/$name?cc=*&link=xoap&prod=xoap&par=$par&key=$key -command [list ::weather::callback WEATHER $chan $nick] -timeout 60000; return
				}
			}
			## well...no hits in cache, looks like we need to look this one up
			::lephttp::fetch http://xoap.weather.com/search/search?where=[urlencode $text] -command [list ::weather::callback LOOKUP $chan $nick] -timeout 60000
		} else {
			## looks like we were passed a us zip code (no need to lookup a locid)
			##http://xoap.weather.com/weather/local/30339?cc=*&link=xoap&prod=xoap&par=[PartnerID]&key=[LicenseKey]
			::lephttp::fetch http://xoap.weather.com/weather/local/$text?cc=*&link=xoap&prod=xoap&par=$par&key=$key -command [list ::weather::callback WEATHER $chan $nick] -timeout 60000
		}
	}
	setudef flag noweather; setudef flag shortweather
	bind pub - !weather ::weather::pubWeather
	bind pub - .weather ::weather::pubWeather
}
package provide weatherxml 0.3

putlog "Loaded weatherxml.tcl v0.3 by leprechau@EFNet!"
