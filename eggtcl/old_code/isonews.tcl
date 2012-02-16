##################################################
##  ISONEWS script by leprechau April 17, 2001  ##
##################################################

set inews(source) "#isonews"
set inews(bothost) "iSONEWS!*isonews@*.gtcust.grouptelecom.net"
set inews(dest) "#channel1 #channel2"
set inews(triggers) {
	{*update in*}
	{*xbox*}
	{*divx*}
}

## begin script ##
set inewsver "v.01"

proc isonews_watch { nick uhost handle chan text } {
global inews
	if {([string match -nocase $inews(bothost) ${nick}\!${uhost}]) && ([string equal -nocase $inews(source) $chan])} {
		foreach match $inews(triggers) {
			if {[string match $match $text]} {
				foreach dest $inews(dest) {
					putserv "PRIVMSG $dest :$text"
				}
				break
			}
		}
	} else { return }
}
bind pubm - * isonews_watch

### initialize ###
putlog "isonews.tcl $inewsver by leprechau@efnet loaded!"
