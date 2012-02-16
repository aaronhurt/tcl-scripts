## settings ##
set inv(invitechan) "#pre"
set inv(inviteport) "63550"
set inv(authkey) "L4elGPu52152Zc2vkeuQ"

proc site:invite_connect { idx } {
	control $idx site:invite_handler
	putidx $idx "++"
}
listen $inv(inviteport) script site:invite_connect pub

proc site:invite_handler {idx text} {
	global inv
	set text [decrypt 5uZ3nU6NI $text]
	if {![string equal "$inv(authkey)" "[lindex [split $text] 0]"]} {
		putlog "\[\002WARNING\002\ Recieved invite connection with invalid auth key!"
		putlog "*** Killing connection (sock $idx)"
		killdcc $idx
		return
	} else {
		set invitenick [lindex [split $text] 1]
		set gluser [lindex [split $text] 2]
		set glgroup [lindex [split $text] 3]
		set sitename [lindex [split $text] 4]
		putlog "\[\002SITE INVITE\002\] Inviting $gluser\@$glgroup from $sitename as $invitenick to $inv(invitechan)"
		putserv "PRIVMSG $inv(invitechan) :\[\002SITE INVITE\002\] Inviting $gluser\@$glgroup from $sitename as $invitenick ..."
		putserv "INVITE $invitenick $inv(invitechan)"
		killdcc $idx
	}
}
