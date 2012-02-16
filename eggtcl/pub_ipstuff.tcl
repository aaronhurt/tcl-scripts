## public commands for simple ip stuff
## commands: !ip2long !long2ip !ip2hex !hex2ip
## channel flags: noipstuff
## v1.0 by leprechau@EFNet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ipstuff {
	namespace export validip validhex ip2long long2ip ip2hex hex2ip

	proc validip {type ip} {
		switch -- $type {
			short {
				if {![regexp {^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$} $ip]} {
					return 0
				} else {return 1}
			}
			long {
				if {(![regexp {^([0-9]*)([0-9])+$} $ip]) || ($ip < 0) || ($ip > 4294967295)} {
					return 0
				} else {return 1}
			}
			hex {
				if {(![regexp {^([0-9]*)([0-9])+$} [set ip [format %u 0x$ip]]]) || ($ip < 0) || ($ip > 4294967295)} {
					return 0
				} else {return 1}
			}
			default {return 0}
		}
	}

	proc ip2long {ip} {
		foreach {a b c d} [split $ip .] {}
		format %u 0x[format %02X%02X%02X%02X $a $b $c $d]
	}

	proc long2ip {long} {
		set long [format %08X $long]
		foreach a {0 2 4 6} b {1 3 5 7} {
			lappend ip [format %u 0x[string range $long $a $b]]
		}
		return [join $ip .]
	}

	proc ip2hex {ip} {
		foreach {a b c d} [split $ip .] {}
		format %02x%02x%02x%02x $a $b $c $d
	}

	proc hex2ip {hex} {
		foreach a {0 2 4 6} b {1 3 5 7} {
			lappend ip [format %u 0x[string range $hex $a $b]]
		}
		return [join $ip .]
	}
}
package provide ipstuff 1.0

setudef flag noipstuff

proc pub_ip2long {nick uhost hand chan text} {
	if {[channel get $chan noipstuff] || [string equal {} $text]} { return }
	set text [string trim [join [lindex [split $text] 0]]]
	if {[::ipstuff::validip short $text]} {
		putserv "PRIVMSG $chan :ip2long($text) == [::ipstuff::ip2long $text]"
	} else {
		putserv "PRIVMSG $chan :Error, ip '$text' is not a valid ipv4 address."
	}
}
bind pub - !ip2long pub_ip2long

proc pub_long2ip {nick uhost hand chan text} {
	if {[channel get $chan noipstuff] || [string equal {} $text]} { return }
	set text [string trim [join [lindex [split $text] 0]]]
	if {[::ipstuff::validip long $text]} {
		putserv "PRIVMSG $chan :long2ip($text) == [::ipstuff::long2ip $text]"
	} else {
		putserv "PRIVMSG $chan :Error, ip '$text' is not a valid ipv4 long address."
	}
}
bind pub - !long2ip pub_long2ip

proc pub_ip2hex {nick uhost hand chan text} {
	if {[channel get $chan noipstuff] || [string equal {} $text]} { return }
	set text [string trim [join [lindex [split $text] 0]]]
	if {[::ipstuff::validip short $text]} {
		putserv "PRIVMSG $chan :ip2hex($text) == [::ipstuff::ip2hex $text]"
	} else {
		putserv "PRIVMSG $chan :Error, ip '$text' is not a valid ipv4 address."
	}
}
bind pub - !ip2hex pub_ip2hex

proc pub_hex2ip {nick uhost hand chan text} {
	if {[channel get $chan noipstuff] || [string equal {} $text]} { return }
	set text [string trim [join [lindex [split $text] 0]]]
	if {[::ipstuff::validip hex $text]} {
		putserv "PRIVMSG $chan :hex2ip($text) == [::ipstuff::hex2ip $text]"
	} else {
		putserv "PRIVMSG $chan :Error, ip '$text' is not a valid ipv4 hex address."
	}
}
bind pub - !hex2ip pub_hex2ip

putlog "Loaded pub_ipstuff.tcl v1.0 by leprechau@EFNet!"
