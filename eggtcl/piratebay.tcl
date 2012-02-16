## script to monitor/announce thepiratebay.org rss feeds
## and provide for searching old releases via thier website
## no documentation or support other than provided herein
## by leprechau@efnet
## last update 05.21.2008
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
##
## usage:
## channel flags: .chanset #channel +piratebay
## public commands: !pub-(all audio video apps games other) <latest|search> [text]
##
## read the settings thoroughly and any other comments throughout the code
## if you have any further questions...
##


namespace eval ::piratebay {

	## begin settings ##
	
	variable maxresults 8;
	## maximum results to display on public commands
	variable uinterval 10;
	## update interval in minutes (connection to thepiratebay.org)
	## PLEASE PLEASE PLEASE don't set this any lower than 8 minutes
	## we have to fetch around 30 rss feeds to get all the information we need
	## if you set this too low you will hammer piratebay and your bot
	variable flood "10:30"
	## flood settings (number:seconds)
	variable messagetarget "nick";
	## public command target (must be "nick" or "chan")
	variable announce "\[\002%SECTION%\002\] %TITLE% -> %COMMENT%"
	## announcement text...the following macros can be used
	## %SECTION% %TITLE% %LINK% %COMMENT% %PDATE% %CREATOR% %GUID%
	## macros are replaced with thier actual content before outputting to server
	variable pubtext1 "(%SECTION%) \002%TITLE%\002 -> %COMMENT% (%PDATE%)"
	## text for the pub 'latest' command...the following macros cat be used
	## %SECTION% %TITLE% %LINK% %COMMENT% %PDATE% %CREATOR% %GUID%
	## macros are replaced with thier actual content before outputting to server
	variable pubtext2 "(%SECTION%) \002%NAME%\002 -> %DETAIL% (%DATE%) \002%SIZE% SE/%SE% LE/%LE%\002"
	## text for the pub 'search' command...the following macros cat be used
	## %SECTION% %NAME% %DATE% %LINK% %DETAIL% %SIZE% %LE%
	## macros are replaced with thier actual content before outputting to server
	variable url "http://rss.thepiratebay.org/"
	## base url for thepiratebay.org rss feeds
	## change this if you run a local mirror (*hint*hint*)

	## end settings ##

	## get my http package from 
	## http://woodstock.anbcs.com/scripts/lephttp.tcl
	## source it before this script in your conf
	package require lephttp
	## get my flood control package from
	## http://woodstock.anbcs.com/scripts/floodcontrol.tcl
	## source it before this script in your conf
	package require floodcontrol
	set ::floodcontrol::flimits(piratebay) $::piratebay::flood

	## define custom flag
	setudef flag piratebay

	## set initial timer check and version info
	variable uinterval2 0; variable version 0.1

	## our main arrays...all info we store goes here
	variable data; array set data [list]
	variable data2; array set data2 [list]
	## static array for our category-section map
		variable catMap; array set catMap {
		audio,all,catid 100
		audio,music,catid 101
		audio,books,catid 102
		audio,sound,catid 103
		audio,flac,catid 104
		audio,other,catid 199
		video,all,catid 200
		video,movies,catid 201
		video,dvdr,catid 202
		video,music,catid 203
		video,clips,catid 204
		video,tv,catid 205
		video,handheld,catid 206
		video,hrmovies,catid 207
		video,hrtv,catid 208
		video,other,catid 299
		apps,all,catid 300
		apps,windows,catid 301
		apps,mac,catid 302
		apps,unix,catid 303
		apps,handheld,catid 304
		apps,other,catid 399
		games,all,catid 400
		games,pc,catid 401
		games,mac,catid 402
		games,ps2,catid 403
		games,xbox,catid 404
		games,gamecube,catid 405
		games,handheld,catid 406
		games,other,catid 499
		other,all,catid 600
		other,e-books,catid 601
		other,comics,catid 602
		other,pictures,catid 603
		other,covers,catid 604
		other,other,catid 699
		all,all,catid 0
	}

	## substitute our macros we use above
	proc submacs {sect title link comment pdate creator guid string} {
		foreach {x y} [split $sect {,}] {}; set sect "[string toupper [string index $x 0]][string range $x 1 end] > [string toupper [string index $y 0]][string range $y 1 end]"
		set map [list %SECTION% $sect %TITLE% $title %LINK% $link %COMMENT% $comment %PDATE% $pdate %CREATOR% $creator %GUID% $guid]; string map $map $string
	}
	proc submacs2 {sect name date link detail size se le string} {
		set map [list %SECTION% $sect %NAME% $name %DATE% $date %LINK% $link %DETAIL% http://thepiratebay.org$detail %SIZE% $size %SE% $se %LE% $le]
		string map $map $string
	}

	## example source from thepiratebay.org rss feed - 05.21.2008
	## <item>
	## <title>The Bloody Beetroots</title>
	## <link>http://torrents.thepiratebay.org/4199509/The_Bloody_Beetroots.4199509.TPB.torrent</link>
	## <comments>http://thepiratebay.org/tor/4199509</comments>
	## <pubDate>Wed, 21 May 2008 23:17:30 +0200</pubDate>
	## <category>Audio > Music</category>
	## <dc:creator>electro212</dc:creator>
	## <guid>http://torrents.thepiratebay.org/4199509/The_Bloody_Beetroots.4199509.TPB.torrent</guid>
	## </item>	

	## callback handler for automatic/timed parsing
	proc autoCallback {sect token} {
		if {[catch {::lephttp::status $token} status] != 0} {return}
		if {![string equal {ok} [set status [string tolower $status]]]} {
			switch -exact -- $status {
				timeout {
					putlog "\[\002PIRATEBAY\002\] Timeout (60 seconds) on connection to server."
				}
				default {
					putlog "\[\002PIRATEBAY\002\] Unknown error occured, server output of the error is as follows: $status"
				}
			}
			::lephttp::cleanup $token; return
		}
		# clean out old data and initialize new
		array unset ::piratebay::data2 $sect,*; array set ::piratebay::data2 [array get ::piratebay::data $sect,*]; array unset ::piratebay::data $sect,*
		array set ::piratebay::data [list $sect,titles {} $sect,links {} $sect,comments {} $sect,pdates {} $sect,creators {} $sect,guids {}]
		# start the parsing :-)
		set rss {}; foreach line [split [::lephttp::data $token] \n] {append rss [string trim $line]}; ::lephttp::cleanup $token
		set regex {<item><title>(.+?)</title><link>(.+?)</link><comments>(.+?)</comments><pubDate>(.+?)</pubDate><category>(.+?)</category><dc:creator>(.+?)</dc:creator><guid>(.+?)</guid></item>}
		foreach {x title link comment pdate cat creator guid} [regexp -all -inline -- $regex $rss] {
			foreach thing {title link comment pdate cat creator guid} things {titles links comments pdates cat creators guids} {
				if {[regexp -all -- {\<\!\[CDATA\[(.+?)\]\]} [set $thing] x tmp]} {set $thing $tmp}
				lappend ::piratebay::data($sect,$things) [set $thing [::lephttp::strip [::lephttp::map [set $thing]]]]
			}
			## announce items from our 'all' records ...these contain dupes we don't want here
			## we only use the all urls for our 'latest' pub command down below
			if {[string match *,all* $sect]} {continue}
			## else...let's continue on
			if {([llength [set acs [lindex [array get ::piratebay::data2 $sect,comments] end]]]) && ([lsearch -exact $acs $comment] == -1)} {
				putlog [::piratebay::submacs $sect $title $link $comment $pdate $creator $guid $::piratebay::announce]
				foreach chan [channels] {
					if {[channel get $chan piratebay]} {
						puthelp "PRIVMSG $chan :[::piratebay::submacs $sect $title $link $comment $pdate $creator $guid $::piratebay::announce]"
					}
				}
			}
		}
	}
	
	proc getData {minute hour day month year} {
		if {[incr ::piratebay::uinterval2] >= $::piratebay::uinterval} {
			## let's be a little less bursty (3 sec delay between fetch)...it's nicer to piratebay.org's servers and our bot not to have 30+ simultaneous http connections
			set delay 0; foreach {name cat} [array get ::piratebay::catMap] {
				utimer [incr delay 3] [list ::lephttp::fetch $::piratebay::url/$cat -command [list ::piratebay::autoCallback [join [lrange [split $name {,}] 0 1] {,}]] -timeout 60000]
			}
			set ::piratebay::uinterval2 0
		}
	}
	bind time - "* * * * *" ::piratebay::getData
	
	## example source from thepiratebay.org search results - 05.21.2008
	## <td class="vertTh"><a href="/browse/101" title="More from this category">Audio &gt; Music</a></td>
	## <td><a href="/tor/3585361/Metallica" class="detLink" title="Details for Metallica">Metallica</a></td>
	## <td>12-28&nbsp;2006</td>
	## <td><a href="http://torrents.thepiratebay.org/3585361/Metallica.3585361.TPB.torrent" title="Download this torrent"><img src="http://static.thepiratebay.org/img/dl.gif" class="dl" alt="Download" /></a></td>
	## <td align="right">848.38&nbsp;MiB</td>
	## <td align="right">0</td>
	## <td align="right">0</td>
	## </tr>
	## <tr class="alt">
	## <td class="vertTh"><a href="/browse/101" title="More from this category">Audio &gt; Music</a></td>
	## <td><a href="/tor/4048269/Metallica" class="detLink" title="Details for Metallica">Metallica</a></td>
	## <td>02-26&nbsp;14:10</td>
	## <td><a href="http://torrents.thepiratebay.org/4048269/Metallica.4048269.TPB.torrent" title="Download this torrent"><img src="http://static.thepiratebay.org/img/dl.gif" class="dl" alt="Download" /></a></td>
	## <td align="right">1017.16&nbsp;MiB</td>
	## <td align="right">0</td>
	## <td align="right">0</td>
	## </tr>
	
	## okay...this proc is really really nasty and ugly...but about this point in the night i get tired...so deal with it :)
	proc pubCallback {target token} {
		## set our 2 really bad regular expressions
		set regex {<tr><td(.+?)>(.+?)</td><td>(.+?)</td><td>(.+?)</td><td>(.+?)</td><td(.+?)>(.+?)</td><td(.+?)>(.+?)</td><td(.+?)>(.+?)</td></tr>}
		set regex2 {<tr class="alt"><td(.+?)>(.+?)</td><td>(.+?)</td><td>(.+?)</td><td>(.+?)</td><td(.+?)>(.+?)</td><td(.+?)>(.+?)</td><td(.+?)>(.+?)</td></tr>}
		## make data a nice consistent format...no newlines or extra whitespaces junk
		set data {}; foreach line [split [::lephttp::data $token] \n] {append data [string trim $line]}; ::lephttp::cleanup $token
		## loop through our data for each regex and build some arrays
		foreach {x y cat name date link z size xx se yy le} [regexp -all -inline $regex $data] {
			lappend temp(cats) [::lephttp::map [::lephttp::strip $cat]]; lappend temp(names) [::lephttp::map [::lephttp::strip $name]]
			lappend temp(links) [lindex [regexp -all -inline -- {href=\"(.+?)\"} $link] end]
			lappend temp(details) [lindex [regexp -all -inline -- {href=\"(.+?)\"} $name] end]
			lappend temp(sizes) [::lephttp::map $size]; lappend temp(dates) [::lephttp::map $date]
			lappend temp(ses) $se; lappend temp(les) $le
		}
		foreach {x y cat name date link z size xx se yy le} [regexp -all -inline $regex2 $data] {
			lappend temp2(cats) [::lephttp::map [::lephttp::strip $cat]]; lappend temp2(names) [::lephttp::map [::lephttp::strip $name]]
			lappend temp2(links) [lindex [regexp -all -inline -- {href=\"(.+?)\"} $link] end]
			lappend temp2(details) [lindex [regexp -all -inline -- {href=\"(.+?)\"} $name] end]
			lappend temp2(sizes) [::lephttp::map $size]; lappend temp2(dates) [::lephttp::map $date]
			lappend temp2(ses) $se; lappend temp2(les) $le
		}
		## make sure our temp arrays actually got populated before we go on...yes i know this makes it need at least 2 matches...but who cares
		if {![info exists temp(cats)] || ![info exists temp2(cats)]} {puthelp "PRIVMSG $target :Sorry, nothing found for your last search."; return}
		## put it all together in one array to maintain order of matches to that of website...
		foreach cat $temp(cats) cat2 $temp2(cats) name $temp(names) name2 $temp2(names) date $temp(dates) date2 $temp2(dates) link $temp(links) link2 $temp2(links) \
		detail $temp(details) detail2 $temp2(details) size $temp(sizes) size2 $temp2(sizes) se $temp(ses) se2 $temp2(ses) le $temp(les) le2 $temp2(les) {
			lappend temp3(cats) $cat $cat2; lappend temp3(names) $name $name2; lappend temp3(dates) $date $date2; lappend temp3(links) $link $link2
			lappend temp3(details) $detail $detail2; lappend temp3(sizes) $size $size2; lappend temp3(ses) $se $se2; lappend temp3(les) $le $le2
		}
		## okay...now we can show our results to the user
		set lineout 0; foreach cat $temp3(cats) name $temp3(names) date $temp3(dates) link $temp3(links) detail $temp3(details) size $temp3(sizes) se $temp3(ses) le $temp3(les) {
			if {(![string equal {} $name]) && (![string equal {} $link])} {
				puthelp "PRIVMSG $target :[::piratebay::submacs2 $cat $name $date $link $detail $size $se $le $::piratebay::pubtext2]"
				if {[incr lineout] >= $::piratebay::maxresults} {break}
			}
		}
	}

	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan piratebay] || [::floodcontrol::check piratebay]} {
			putlog "\[\002PIRATEBAY\002\] Flood control triggered in $chan by $nick ($::piratebay::flood)"; return
		}; ::floodcontrol::record piratebay $uhost
		putcmdlog "# $nick@$chan $::lastbind $text #"
		switch -- $::piratebay::messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002PIRATEBAY\002\] Error, unknown messagetarget specified in script!"; return}
		}
		set sect "[lindex [split [string tolower $::lastbind] {-}] end],all"
		set lineout 0; switch -glob -- $text {
			lat* {
				foreach title $::piratebay::data($sect,titles) link $::piratebay::data($sect,links) comment $::piratebay::data($sect,comments) pdate $::piratebay::data($sect,pdates) creator $::piratebay::data($sect,creators) guid $::piratebay::data($sect,guids) {
					if {(![string equal {} $title]) && (![string equal {} $link])} {
						puthelp "PRIVMSG $target :[::piratebay::submacs $sect $title $link $comment $pdate $creator $guid $::piratebay::pubtext1]"
						if {[incr lineout] >= $::piratebay::maxresults} {break}
					}
				}
			}
			sea* {
				if {![string length [set text [join [lrange [split $text] 1 end]]]]} {
					puthelp "PRIVMSG $target :Sorry, you didn't give me anything to search for."; return
				}
				::lephttp::fetch http://thepiratebay.org/search.php?[::lephttp::formatQuery q $text [lindex [split [string tolower $::lastbind] {-}] end] on] -command [list ::piratebay::pubCallback $target]
			}
			default {puthelp "PRIVMSG $chan :Usage: $::lastbind <latest|search> \[text\]"; return}
		}
	}
	## fix all of our binds
	foreach sect {all audio video apps games other} {bind pub - !pb-$sect ::piratebay::pubCmds}; unset sect
}

## start init ##

foreach timer [utimers] {
	if {[string match {*piratebay*} [join [lindex $timer 1]]]} {
		killutimer [lindex $timer end]
	}
}
set ::piratebay::uinterval2 $::piratebay::uinterval; utimer 8 {::piratebay::getData - - - - -}

## end init ##

putlog "piratebay.tcl v$::piratebay::version by leprechau@EFNet loaded!"
