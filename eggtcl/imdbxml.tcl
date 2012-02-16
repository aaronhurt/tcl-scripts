## imdb movie lookup via trynt.com api
## fetch episode information from http://www.trynt.com/movie-imdb-api/v1/
## no documentation or support other than provided herein
##
## by leprechau@EFnet
##
## channel settings: .chanset #chan +/-imdb
## ^-- toggle public commands per channel
##
## public commands: !imdb <movie title|imdb id>
##
## NOTE: This script uses my http package
## http://woodstock.anbcs.com/scripts/lephttp.tcl
## download and source before this script
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::imdb {
	
	## begin settings ##

	variable messagetarget "chan";
	## target for messages on pub commands (nick or chan)

	## end settings ##
	variable version 0.3

	## get my http package from
	## http://woodstock.anbcs.com/scripts/lephttp.tcl
	package require lephttp
	
	## defines
	setudef flag imdb

	## our callback handler
	proc callback {type utxt target token} {
		if {[catch {::lephttp::status $token} status] != 0} {return}
		if {![string equal -nocase {OK} $status]} {
			switch -exact -- [string tolower $status] {
				timeout {
					putlog "\[\002IMDB\002\] Timeout (15 seconds) on connection to server."
					putserv "PRIVMSG $target :\[\002ERROR\002\] Timeout (15 seconds) on connection to server."
				}
				default {
					putlog "\[\002IMDB\002\] Unknown error occured, server output of the error is as follows: $status"
					putserv "PRIVMSG $target :\[\002ERROR\002\] Unknown error occured."
				}
			}
			::lephttp::cleanup $token; return
		}
		set data [split [::lephttp::data $token] \n]; ::lephttp::cleanup $token
		## do a quick error check
		if {([regexp -all -- {<Error>(.+?)</Error>} $data x y]) && ([string equal {true} $y])} {
			regexp -all -- {<Msg>(.+?)</Msg>} $data x msg
			puthelp "PRIVMSG $target :Sorry, the website returned the following error: $msg"; return
		}
		## go ahead...
		switch -exact -- $type {
			LOOKUP {
				## lets pull out all of our info
				foreach line $data {
					if {[string equal {} [set line [string trim $line]]]} {continue}
					switch -glob -- $line {
						{<IMDB-URL>} {set block head}
						{<Movie-ID>} {set block ids}
						{<Movie-Title>} {set block titles}
						{<*>*} {
							if {![info exists block]} {continue}
							if {[regexp -all -- {(<.+?>)([^<]*)(<.+?>)} $line x stag text etag]} {
								lappend [set block]([string trim [string tolower $stag] {<>}]) [::lephttp::map [string trim $text]]
							}
						}
					}
				}
				## did we get more than one match...if so let's give them the options and stop
				if {([llength $ids(value)] > 1) && ([llength $titles(value)] > 1)} {
					puthelp "PRIVMSG $target :Your search '[join $head(search)]' returned multiple matches, closet match: \
					[string map {\" {}} [::lephttp::map [join $head(matched-title)]]] \([join $head(matched-id)]\)"
					## make a nice title/id list
					foreach x $titles(value) y $ids(value) {lappend temp "$x \($y\)"}
					## output it
					puthelp "PRIVMSG $target :Other possible matches include: \
					[string map {\" {}} [::lephttp::map [join [lrange $temp 1 end] {, }]]]"; return
				}
				## well i guess we just got one...lets lookup the goods
				::lephttp::geturl http://www.trynt.com/movie-imdb-api/v1/?[::lephttp::formatQuery i $head(matched-id)] -timeout 15000 \
				-command [list ::imdb::callback DETAILS $head(matched-id) $target]; return
			}
			DETAILS {
				## lets pull out all of our info
				foreach line $data {
					if {[string equal {} [set line [string trim $line]]]} {continue}
					switch -glob -- $line {
						{<IMDB-Data>} {set block idata}
						{<Genres>} {set block gens}
						{<*>*} {
							if {![info exists block]} {continue}
							if {[regexp -all -- {(<.+?>)([^<]*)(<.+?>)} $line x stag text etag]} {
								lappend [set block]([string trim [string tolower $stag] {<>}]) [::lephttp::map [string trim $text]]
							}
						}
					}
				}
				## workaround for some bugs in the API we are using
				if {[string match {*</a>*} $idata(languages)]} {
					foreach {x y} [regexp -all -inline -- {>(.+?)</a>} $idata(languages)] {lappend templ $y}
					array set idata [list languages $templ]
				}
				## another workaround for similar bug in the API
				if {[string match {*</a>*} $idata(country)]} {
					foreach {x y} [regexp -all -inline -- {>(.+?)</a>} $idata(country)] {lappend tempc $y}
					array set idata [list country $tempc]
				}
				## okay it's time to show em what we got...
				puthelp "PRIVMSG $target :\002Title\002: [string map {\" {}} [::lephttp::map [join $idata(title)]]] \
				\002Link\002: http://www.imdb.com/title/$utxt/"
				puthelp "PRIVMSG $target :\002Plot\002: [::lephttp::map [join $idata(plot)]]"
				puthelp "PRIVMSG $target :\002Rating\002: [join $idata(user-rating)]\/10.0 \002Languages\002: [join $idata(languages) {, }] \
				\002Country\002: [join $idata(country) {, }] \002Directed\002: [join $idata(directed)] \
				\002Genres\002: [join $gens(genre) {, }]"; return
			}
		}
	}

	## public commands handler
	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan imdb]} {return}
		if {[string equal {} [set text [string trim $text]]]} {
			puthelp "PRIVMSG $chan :\[\002$nick\002\] Usage: !imdb <movie title|imdb id>"; return
		}
		switch -exact -- $::imdb::messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002IMDB\002\] Error, unknown messagetarget specified in script!"; return}
		}
		## check if we got a valid imdb id or a title passed
		if {[regexp -- {^tt[0-9]+$} $text]} {
			::lephttp::geturl http://www.trynt.com/movie-imdb-api/v1/?[::lephttp::formatQuery i $text] -timeout 15000 \
			-command [list ::imdb::callback DETAILS $text $target]; return
		}
		## if not...we have to look it up...
		::lephttp::geturl http://www.trynt.com/movie-imdb-api/v1/?[::lephttp::formatQuery t $text] -timeout 15000 \
		-command [list ::imdb::callback LOOKUP $text $target]; return
	}
	bind pub - !imdb ::imdb::pubCmds
}

putlog "imdb.tcl v$::imdb::version by leprechau@EFNet loaded!"
