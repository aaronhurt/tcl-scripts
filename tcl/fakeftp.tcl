## fake ftp server v0.1
## by leprechau@EFnet 07.19.2005
##
## always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::fakeftp {

	variable ServSock ""

	proc greet {sock} {
		fileevent $sock writable {}
		puts $sock "220 fakeftp server ready"
	}

	proc interact {sock} {
		if {[catch {gets $sock} line] || [eof $sock]} {
			catch {close $sock}
			puts "Disconected $sock...waiting for next connection...\n\n"
		}
		puts "$sock\:\: $line"
		switch -exact -- [lindex [split [string tolower $line]] 0] {
			user {catch {puts $sock "331 username okay."}}
			pass {catch {puts $sock "230 logged in."}}
			quit - exit - logout - goodbye {
				catch {puts $sock "221 goodbye. connection closed."}
				catch {close $sock}
				puts "Disconnected $sock...waiting for next connection...\n\n"
			}
			default {catch {puts $sock "500 invalid command."}}
		}
	}

	proc connect {sock caddr cport} {
		puts "Connect from $caddr:$cport ($sock)..."
		fconfigure $sock -buffering line
		fileevent $sock writable [list ::fakeftp::greet $sock]
		fileevent $sock readable [list ::fakeftp::interact $sock]
	}

	proc server {ip port} {
		set ::fakeftp::ServSock [socket -server ::fakeftp::connect -myaddr $ip $port]
		fconfigure $::fakeftp::ServSock -buffering line; vwait forever
	}
}

::fakeftp::server 192.168.1.50 21
