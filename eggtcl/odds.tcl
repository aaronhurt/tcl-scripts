## simple sports line script by leprechau@EFnet
##
## flags:
## .chanset #chan +\-odds -> enable or disable triggers per channel
##
## other options/settings described below
##
## NOTE: this script requres my lephttp package
## available at http://woodstock.anbcs.com/scripts/lephttp.tcl
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##


namespace eval ::linesmaker {
	
	## set our lookup info for linesmaker.com
	variable burl "http://LinesMaker.com/xml/%NM%.xml"
	variable sports; array set sports {nfl 203 fbfh 175 fbht 176 sb 520 afcc 522 nfcc 521 ncf 206 bcs 592 nba 200 bbfh 173 bbht 174 nba-ch 524 nba-ec 584 nba-wc \
	583 ncb 201 ncb-ch 525 mlb 204 ffi 94 ws 526 nlp 527 alp 528 nhl 202 fpl 84 sc 523 nhl-ec 810 nhl-wc 811 pga 85 pga-ml 771 pga-ma 530}

	## setup enable/disable udef
	setudef flag odds
	
	## we're using my http package of course
	package require lephttp
}

## generate the url
proc ::linesmaker::genurl {sport} {string map "%NM% [lindex [array get ::linesmaker::sports $sport] end]" $::linesmaker::burl}

## build our regexps
proc ::linesmaker::breg {items} {
	foreach i [lrange $items 1 end] {append rxp "\<$i\>\(\.\+\?\)\<\/$i\>"}
	return "<[lindex $items 0]>$rxp</[lindex $items 0]>"
}

## handle our web return
proc ::linesmaker::callback {sport team nick chan token} {
	## check status of our token
	if {![string equal -nocase {ok} [set status [::lephttp::status $token]]] && [::lephttp::ncode $token] != 200} {
		::lephttp::cleanup $token; return -code error "Error processing url: $status"
	}
	## create our data list
	set xml {}; foreach line [split [::lephttp::data $token] \n] {append xml [string trim $line]}; ::lephttp::cleanup $token
	## continue on...switch parsing based on sport
	switch -glob -- $sport {
		nfl* - ncf* - nba* - ncb* - mlb* - fb* - bb* {
			foreach {x dt aro atm amo ali ato hro htm hmo hli hto} [regexp -all -inline -- \
			[::linesmaker::breg [list entry date_time awayrotationnumber awayteam awaymoney awayline awaytotal homerotationnumber hometeam homemoney homeline hometotal]] $xml] {
				## check our team names per entry
				if {[string match -nocase *$team* $atm] || [string match -nocase *$team* $htm]} {
					## we got it..let's show it
					set matched 1; puthelp "PRIVMSG $chan :$aro $atm $ali $amo $ato"; puthelp "PRIVMSG $chan :$hro $htm $hli $hmo $hto"
				}
			}
		}
	}
	## sorry...
	if {![info exists matched]} {
		puthelp "PRIVMSG $chan :$nick, Sorry, I couldn't find a team matching \*$team\* in my $sport lines (try city vs team name and vice versa)."; return
	}
}

## show em the ropes...
proc ::linesmaker::help {nick chan {help {0}}} {
	if {$help} {
		puthelp "NOTICE $nick :\[Extra Options\]"
		puthelp "NOTICE $nick :Football: First Half (fbfh) Halftime (fbht) Super Bowl (sb) AFC Championship (afcc) NFC Championship (nfcc)"
		puthelp "NOTICE $nick :Basketball: First Half (bbfh) Half Time (bbht) Championship (nba-ch) Eastern Conf (nba-ec) Western Conf (nba-wc)"
		puthelp "NOTICE $nick :Baseball: First Five Innings (ffi) World Series (ws) National League Pennant (nlp) American Leage Pennant (alp)"
		puthelp "NOTICE $nick :Hockey: First Period Line (fpl) Stanley Cup (sc) Eastern Conf (nhl-ec) Western Conf (nhl-wc)"
		puthelp "NOTICE $nick :Golf: PGA Money List (pga-ml) PGA Masters (pga-ma)"
	} else {
		puthelp "PRIVMSG $chan :Usage: !odds <sport> <team>"
		puthelp "NOTICE $nick :Sports: mlb nfl nba nhl ncf ncb"
		puthelp "NOTICE $nick :For additional information: !odds help"
	}; return
}	
	
## pub handler
proc ::linesmaker::pubs {nick uhost hand chan text} {
	## make sure we are enabled...
	if {![channel get $chan odds]} {return}
	## log it
	#putcmdlog "$nick\@$chan $::lastbind $text"
	## get and check our arguments..if wrong help them
	switch -exact -- [lindex [split $text] 0] {
		help {::linesmaker::help $nick $chan 1; return}
		default {
			if {[llength [split $text]] < 2} {::linesmaker::help $nick $chan 0; return}
			## parse out our text...
			set sport [lindex [split $text] 0]; set team [lrange [split $text] 1 end]
			if {![string length [array get ::linesmaker::sports $sport]]} {::linesmaker::help $nick $chan 0; return}
		}
	}
	## okay...we are in the clear...let's do it
	::lephttp::geturl [::linesmaker::genurl $sport] -timeout 5000 -command [list ::linesmaker::callback $sport $team $nick $chan]
}
bind pub - !odds ::linesmaker::pubs

putlog "odds script v0.1 by leprechau@EFNet"

## EOF ##