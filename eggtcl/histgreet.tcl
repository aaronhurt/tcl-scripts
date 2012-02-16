## channel history greeter
## v0.1 by leprechau@EFnet
##
## channel flags:
## .chanset #channel +history
## ^-- toggle history greeting on specific channel
## .chanset #channel histsize 5
## ^-- set the number of lines to replay to person
## this setting will default to 3 if not set
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::histGreet {

	## setup our defines
	setudef flag history; setudef str histsize
	
	## initialize our state array...this keeps everything
	variable State; array set State [list]
	
	## our history gathering proc
	proc getText {nick uhost hand chan text} {
		## make sure we are tracking this channel
		if {![channel get $chan history]} {return}
		## add the current line to our cache
		lappend ::histGreet::State([set chan [string tolower $chan]]) "\($nick\) $text"
		## get our max size
		if {(![string length [set max [channel get $chan histsize]]]) || (![string is int $max])} {set max 3}
		## make sure we are not over...
		if {[llength $::histGreet::State($chan)] > $max} {
			set ::histGreet::State($chan) [lrange $::histGreet::State($chan) end-[expr {$max -1}] end]
		}
	}
	bind pubm - * ::histGreet::getText
	
	## our greeter proc
	proc doGreet {nick uhost hand chan} {
		## make sure we are tracking this channel
		if {![channel get $chan history]} {return}
		## display our greeting to this person...
		foreach line [lindex [array get ::histGreet::State [set chan [string tolower $chan]]] end] {
			puthelp "PRIVMSG $nick :$line"
		}
	}
	bind join - * ::histGreet::doGreet
}
putlog "histgreet v0.1 by leprechau@EFnet loaded!"

##EOF		