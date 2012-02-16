## sexhelp@EFnet botscript by leprechau@EFnet
## first revision..no comments or help yet
## this is a private script..
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::sexhelp {

	variable terms [list penis sex cunt vagina dick cock suck fuck screw anal ass tit boob shaft cum pussy whore]
	setudef flag sexhelp

	proc pubSearch {nick uhost hand chan text} {
	variable url; variable data
		if {![channel get $chan sexhelp]} {return}
		foreach word [split [set text [string trim [string tolower $text] {?}]]] {
			if {[lsearch -glob $::sexhelp::terms \*$word\*]} {set found 1; break}
		}; if {![info exists found]} {return}
		if {![string equal {} $result]} {
			putserv "PRIVMSG $chan :\002$text\002 -> [format [string trimright $url {contents.htm}]%s $result]"
		}
	}
	bind pubm - * ::sexhelp::pubSearch
}

putlog "sexhelp.tcl v0.1 by leprechau@Efnet loaded!"
