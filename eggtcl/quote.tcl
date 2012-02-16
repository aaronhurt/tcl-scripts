# quote.tcl v0.1 by leprechau@EFNet
# short and simple...i made this cause all the other quote scripts stink
# commands: !quote <mask> || !addquote || !delquote || !quotestats <mask>
# also channel flag +noquote ... to disable script on per channel basis
# usage: .chanset #channel +noquote OR .chanset #channel -noquote

namespace eval ::quote {
	variable qfile "/home/ahurt/lepster/scripts/misc/quote.txt"
	variable qlog "/home/ahurt/lepster/scripts/misc/quote.log"
	variable dolog "1"
	variable donotice "0"
	variable qdelflags "m|m"

	setudef flag noquote

	proc getdata {} {
		variable qfile
		if {[file exists $qfile]} {
			if {[catch {set data [split [read [set fid [open $qfile r]]] \n]; close $fid} Err] != 0} {
				putlog "Quote Error: $Err"; return 1
			} else {return $data}
		}
	}

	proc putdata {text} {
		variable qfile
		if {[catch {puts [set fid [open $qfile a+]] $text; close $fid} Err] != 0} {
			putlog "Quote Error: $Err"; return 1
		} else {return 0}
	}

	proc deldata {text} {
		variable qfile; set data [::quote::getdata]
		if {[string match \#* $text] && [string is int [string range [lindex [split $text] 0] 1 end]]} {
			set index [string range [lindex [split $text] 0] 1 end]
		} else {
			if {[set index [lsearch -exact $data $text]] == -1} {return 1}
		}
		if {[catch {set fid [open $qfile w]} Err] != 0} {
			putlog "Quote Error: $Err"; return 1
		} else {
			## couple little fixes...thanks to BL4DE@EFnet for finding these two
			## check our file length...if it's less than or equal to 1...just delete it
			if {[llength $data] <= 1} {file delete -force -- $qfile; return 0}
			## check for empty index..
			if {![string length [string trim [lindex $data $index]]]} {return 1}
			## go ahead...we should be all good now...
			if {[catch {puts -nonewline $fid [join [lreplace $data $index $index] \n]; close $fid} Err] != 0} {
				putlog "Quote Error: $Err"; return 1
			}
			return 0
		}
	}

	proc writelog {nick uhost chan text} {
		variable qlog
		if {[catch {puts [set fid [open $qlog a+]] "$nick ($uhost) of $chan @[clock format [clock seconds]] $text"; close $fid} Err] != 0} {
			putlog "Quote Error: $Err"; return 1
		} else {return 0}
	}

	proc quote {nick uhost hand chan text} {
		variable donotice
		if {[channel get $chan noquote] || [string equal {} [set data [::quote::getdata]]]} {return}
		if {![string equal {} [set text [string trim $text]]]} {
			if {[string match \#* $text] && [string is int [string range [lindex [split $text] 0] 1 end]]} {
				set outs [join [lindex $data [set index [expr {int([string range [lindex [split $text] 0] 1 end])}]]]]
			} else {
				if {[llength [set indexes [lsearch -all -glob [string tolower $data] [string tolower $text]]]] > 0} {
					set outs [lindex $data [set index [lindex $indexes [expr {int(rand()*[llength $indexes])}]]]]
				}
			}
		} else {set outs [lindex $data [set index [expr {int(rand()*[llength $data])}]]]}
		if {![info exists outs] || [string equal {} $outs]} {return}
		switch -- $donotice {
			0 { putserv "PRIVMSG $chan :\002Quote\002: $outs (\#$index)" }
			1 { putserv "NOTICE $nick :\002Quote\002: $outs (\#$index)" }
		}
	}
	bind pub - !quote ::quote::quote

	proc addQuote {nick uhost hand chan text} {
		variable dolog
		if {[channel get $chan noquote] || [string equal {} [set text [string trim $text]]]} {return}
		if {[lsearch -exact [::quote::getdata] $text] == -1} {
			if {![::quote::putdata $text]} {
				putserv "NOTICE $nick :bling bling...Quote added!"
				if {$dolog} {::quote::writelog $nick $uhost $chan "ADDED: $text"}
			}
		}
	}
	bind pub - !addquote ::quote::addQuote

	proc delQuote {nick uhost hand chan text} {
		variable dolog;variable qdelflags
		if {[string equal {} [set text [string trim $text]]] || ![matchattr $hand $qdelflags $chan]} {
			putserv "NOTICE $nick: Oh no you can't do that thing when you ain't got that swing!"; return
		}
		if {![::quote::deldata $text]} {
			putserv "NOTICE $nick :bling bling...Quote deleted!"
			if {$dolog} {::quote::writelog $nick $uhost $chan "DELETED: $text"}
		} else {putserv "NOTICE $nick :Sorry, quote was not deleted.  Check partyline for more information."}
	}
	bind pub - !delquote ::quote::delQuote

	proc quoteStats {nick uhost hand chan text} {
		variable donotice
		if {[llength [split $text]] != 0} {
			set msg "I found [set f [llength [lsearch -all -glob -inline [string tolower [::quote::getdata]] [string tolower $text]]]] quotes \
			out of [set t [expr {[llength [::quote::getdata]]-2}]] ([format %0.2f [expr ($f.0/$t.0)*100]]%) matching $text in my quote file."
		} else {
			set msg "I have [expr {[llength [::quote::getdata]]-2}] quotes in my quote file."
		}
		switch -- $donotice {
			0 { putserv "PRIVMSG $chan :\002Quotestats\002: $msg" }
			1 { putserv "NOTICE $nick :\002Quotestats\002: $msg" }
		}
	}
	bind pub - !quotestats ::quote::quoteStats
}
package provide quotes 0.1

putlog "quote.tcl v0.1 by leprechau@EFNet loaded!"