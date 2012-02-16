## announe text passed from a website
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

catch {close $::announcer(ssock)}

namespace eval ::announcer {
	variable announcer; ##variable hist

	## settings ##
	array set announcer {
		webport "LISTEN_PORT_HERE"
		webips "IP_MASKS_HERE"
		authkey "AUTH_KEY_HERE"
	}
	## end settings ##
	setudef flag torrents

	proc close_sock {sock reason} {
		catch {close $sock}
		putlog "Closed ($sock) from $::announcer::announcer($sock) ($reason)"
		catch {unset ::announcer::announcer($sock)}
	}

	proc listener {port} {
		if {![info exists ::my-ip]} {
			putlog "\002AnnouncerListener\002: Error, please set 'my-ip' in eggdrop.conf"; return
		}
		if {[catch {set ::announcer(ssock) [socket -server ::announcer::accept -myaddr ${::my-ip} $port]} sock_err] != 0} {
			putlog "\002AnnouncerListener\002: Error, $sock_err."; return
		} else {
			putlog "\002AnnouncerListener\002: Listening on ${::my-ip} port $port!"
		}
	}

	proc accept {sock addr port} {
		set ::announcer::announcer($sock) $addr:$port; set allow_connect 0
		if {[string length $::announcer::announcer(webips)] != 0} {
			foreach ip "$::announcer::announcer(webips)" {
				if {[string match "$ip" "$addr"]} {set allow_connect 1; break}
			}
		} else { set allow_connect 1 }
		if {$allow_connect != 1} {
			::announcer::close_sock $sock "unauthorized connection"; return
		} else {
			putlog "Accepted announce ($sock) connection from $addr port $port"
			fconfigure $sock -buffering line
			fileevent $sock readable [list ::announcer::handler $sock $addr]
		}
	}

	proc handler {sock addr} {
		if {[eof $sock] || [catch {gets $sock line}]} {
			::announcer::close_sock $sock "EOF of sock"; return
		}
		##putlog "line == $line"
		if {[llength [set text [split $line {¿}]]] != 7} {::announcer::close_sock $sock "insufficient arguments"; return}
		foreach {key reqid sname tname tsize uname tlink} $text {}
		##putlog "key == $key || reqid == $reqid || sname == $sname || tname == $tname || tsize == $tsize || uname == $uname || tlink == $tlink"
		if {![string equal $::announcer::announcer(authkey) $key]} {
			putlog "\[\002WARNING\002\] Recieved connection from $::announcer::announcer($sock) with invalid auth key!"
			putlog "\[\002WARNING\002\] String: $line"
			::announcer::close_sock $sock "unauthorized connection"; return
		}
		putlog "*** Closing connection ($sock) from $::announcer::announcer($sock)"
		::announcer::close_sock $sock "connection finished"
		foreach chan [channels] {
			if {[channel get $chan torrents]} {
				if {$reqid != 0} {
					puthelp "PRIVMSG $chan :\002\[ New Request \]\002 .... $tname"
					puthelp "PRIVMSG $chan :\002\[ Requested by \]\002 .... $uname"
					puthelp "PRIVMSG $chan :\002\[ Link \]\002 .... $tlink"
				} else {
					puthelp "PRIVMSG $chan :\002\[ New Torrent \]\002 .... $tname \($tsize\)"
					puthelp "PRIVMSG $chan :\002\[ Uploaded by \]\002 .... $uname"
					puthelp "PRIVMSG $chan :\002\[ Link \]\002 .... $tlink"
				}
			}
		}
	}
}

putlog "\002Loaded:\002 Eggdrop torrent announcer v0.1 (opening listening socket in 5 seconds)"
utimer 5 "::announcer::listener $::announcer::announcer(webport)"
