## simple google stuff by leprechau@efnet
## no dependencies or extra packages required
## little typo fix and added a limit
## read comments in code
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::googlestuff {

	## set your url...no http:// here
	variable url "www.google.com"
	## set max results
	variable max "4"
	## use safesearch? (on OR off)
	variable safe "off"

	## end settings ##
	variable data; array set data [list]
	setudef flag nogoogle

	## encode urls
	proc urlEncode {text} {
		foreach 1char [split $text {}] {
			if {(![string equal {.} $1char]) && ([regexp \[^a-zA-Z0-9_\] $1char])} {
				append encoded "%[format %02X [scan $1char %c]]"
			} else {append encoded "$1char"}
		}
		return $encoded
	}

	## map common html entities and xml entities
	proc mapEntities {html} {
		if {[regexp -all -- {&#([0-9]+);} [set html [string map "{&quot;} {\"} {&amp;} {\&} {&lt;} {\<} {&gt;} {\>}" $html]]]} {
			foreach {x y} [regexp -all -inline -- {&#([0-9]+);} $html] {
				set html [string map [list $x [format %c $y]] $html]
			}; return $html
		} else {return $html}
	}

	## remove html tags
	proc unhtml {text} {
	   ## this isn't as pretty as it could be...but we need the varname for 8.3 compliance
		regsub -all -- {(<.+?>)} $text {} text; return $text
	}

	## parse and output our result if we make it this far :)
	proc outputIt {sock chan} {
		## check for no results...
		if {[string match -nocase "*your search*did not match any documents*" $::googlestuff::data($sock)]} {
			puthelp "PRIVMSG $chan :Sorry, I could not find any results on google for your search."
			## cleanup search and return
			catch {unset ::googlestuff::data($sock)}; return
		}
		## loop through our 'data' and output cleaned up results
		foreach {x item} [regexp -all -inline -nocase {<nobr>(.+?)</nobr>} $::googlestuff::data($sock)] {
			## check for 'sign in' junk...and skip it if found
			if {[string match {*>Sign in<*} $item]} {continue}
			## output our results to irc...we worked hard to get these :)
			regsub -all -- {^[0-9]\.} [::googlestuff::mapEntities [::googlestuff::unhtml $item]] \002&\002 title
			lappend outs "$title -> [lindex [regexp -inline -nocase {href=(.+?)>} $item] end]"
		}
		puthelp "PRIVMSG $chan :[join $outs]"
		## cleanup this fetch from the data array
		catch {unset ::googlestuff::data($sock)}
	}

	## tell google what we want from it
	proc writeIt {sock text} {
		fileevent $sock writable {}
		## we do all our limiting and whatnot right here in our fetch
		## http://www.google.com/ie?q=blargs&num=5&hl=en&safe=off
		puts $sock "GET /ie?q=[string map {{%20} {+}} [::googlestuff::urlEncode $text]]\&num=$::googlestuff::max\&hl=en\&safe=$::googlestuff::safe HTTP/1.0"
		puts $sock "Host: $::googlestuff::url"
		puts $sock ""
		flush $sock
	}

	## read in the data and append to data array
	proc readIt {sock chan} {
		fileevent $sock readable {}
		while {![eof $sock]} {
			append ::googlestuff::data($sock) [string trim [gets $sock]]
		}
		catch {close $sock}; ::googlestuff::outputIt $sock $chan
	}

	## setup the fileevents and open the socket async
	proc doIt {text chan} {
		set sock [socket -async $::googlestuff::url 80]
		fconfigure $sock -buffering line -buffersize 1024 -blocking no
		fileevent $sock writable [list ::googlestuff::writeIt $sock $text]
		fileevent $sock readable [list ::googlestuff::readIt $sock $chan]
	}

	proc pubGoogle {nick uhost hand chan text} {
		## start the process...
		if {[channel get $chan nogoogle]} {return}
		if {[string length $text] < 1} {
			puthelp "PRIVMSG $chan :Sorry, I didn't catch that...you want me to google for what?"; return
		} else {::googlestuff::doIt $text $chan}
	}

	## bind it to !google
	bind pub - !google ::googlestuff::pubGoogle
}

putlog "googlestuff.tcl loaded"
