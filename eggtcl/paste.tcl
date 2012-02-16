## client side script to handle paste from http://paste.anbcs.com
## no documentation or support other than provided herein
## by leprechau@EFnet
##
## always check for newer code at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
catch {close $::paste(ssock)}

namespace eval ::paste {
	namespace export listener
	variable paste; variable waiting

	## settings ##
	array set paste {
		webport "LISTEN_PORT_HERE"
		webips "WEBSERVER_IP_OR_IP_MASK"
		pasteip "LISTEN_IP_HERE"
		authkey "LONG_RANDOM_AUTH_KEY"
	}
	## end settings ##

	proc close_sock {sock reason} {
		catch {close $sock}
		putlog "Closed ($sock) from $::paste::paste($sock) ($reason)"
		catch {unset ::paste::paste($sock)}
	}

	proc listener {port} {
		if {[string equal {} [array get ::paste::paste pasteip]]} {
			putlog "\002PasteListener\002: Error, please set 'pasteip' in this script ([info script])."; return
		}
		if {[catch {set ::paste::paste(ssock) [socket -server ::paste::accept -myaddr $::paste::paste(pasteip) $port]} sock_err] != 0} {
			putlog "\002PasteListener\002: Error, $sock_err."; return
		} else {
			putlog "\002PasteListener\002: Listening on $::paste::paste(pasteip) port $port!"
		}
	}

	proc accept {sock addr port} {
		set ::paste::paste($sock) $addr:$port; set allow_connect 0
		if {[string length $::paste::paste(webips)] != 0} {
			foreach ip "$::paste::paste(webips)" {
				if {[string match "$ip" "$addr"]} {set allow_connect 1; break}
			}
		} else { set allow_connect 1 }
		if {$allow_connect != 1} {
			::paste::close_sock $sock "unauthorized connection"; return
		} else {
			putlog "Accept paste ($sock) connection from $addr port $port"
			fconfigure $sock -buffering line
			fileevent $sock readable [list ::paste::handler $sock $addr]
		}
	}

	proc handler {sock addr} {
		if {[eof $sock] || [catch {gets $sock line}]} {
			::paste::close_sock $sock "EOF of sock"; return
		}
		if {[llength $line] != 6} {::paste::close_sock $sock "insufficient arguments"; return}
		foreach {key chan poster comment ip url} $line {}
		#putlog "key == $key | chan == $chan | poster == $poster | comment == $comment | ip == $ip | url == $url"
		if {![string equal $::paste::paste(authkey) $key]} {
			putlog "\[\002WARNING\002\] Recieved paste connection from $::paste::paste($sock) with invalid auth key!"
			putlog "\[\002WARNING\002\] String: $line"
			::paste::close_sock $sock "unauthorized connection"; return
		}
		if {[validchan $chan] && [onchan $::botnick $chan]} {
			if {![onchan $poster $chan]} {
				putlog "\[\002PASTE\002\] Recieved paste from '$poster' for '$chan' but user is not on that channel."; return
			} else {
				putlog "\[\002PASTE\002\] Relaying $url to $chan for $poster@$ip ...."
				switch -- $comment {
					NONE {puthelp "PRIVMSG $chan :\[\002PASTE\002\] $poster just pasted code at \002$url\002"}
					default {puthelp "PRIVMSG $chan :\[\002PASTE\002\] $poster just pasted code at \002$url\002 ($comment)"}
				}
			}
		} else {
			putlog "\[\002PASTE\002\] Adding '$chan' to my channel list."
			if {[array exists ::paste::waiting] && [info exists ::paste::waiting([string tolower $chan])]} {
				lappend ::paste::waiting([string tolower $chan]) [list $poster $comment $ip $url]
			} else {array set ::paste::waiting [list [string tolower $chan] [list $poster $comment $ip $url]]}
			if {![validchan $chan]} {channel add $chan} else {
				putlog "\[\002\ERROR\002\] Channel $chan is in my channel list, but I am not on that channel!"
			}
		}
		putlog "*** Closing connection ($sock) from $::paste::paste($sock)"
		::paste::close_sock $sock "connection finished"
	}

	proc new_channel {nick uhost hand chan} {
		if {([string equal $::botnick $nick]) && (![string equal {} [array get ::paste::waiting [string tolower $chan]]])} {
			foreach paste [lindex [array get ::paste::waiting [string tolower $chan]] 1] {
				foreach {poster comment ip url} $paste {}
				if {![onchan $poster $chan]} {
					putlog "\[\002PASTE\002\] Recieved paste from '$poster' for '$chan' but user is not on that channel."; return
				} else {
					putlog "\[\002PASTE\002\] Relaying $url to $chan for $poster@$ip ...."
					switch -- $comment {
						NONE {puthelp "PRIVMSG $chan :\[\002PASTE\002\] $poster just pasted code at \002$url\002"}
						default {puthelp "PRIVMSG $chan :\[\002PASTE\002\] $poster just pasted code at \002$url\002 ($comment)"}
					}
				}
			}
			array unset ::paste::waiting [string tolower $chan]
		}
	}
	bind join - * ::paste::new_channel
}
package provide paste

putlog "\002Loaded:\002 Eggdrop paste announcer v1.0 (opening listening socket in 5 seconds)"
utimer 5 "::paste::listener $::paste::paste(webport)"

##EOF##