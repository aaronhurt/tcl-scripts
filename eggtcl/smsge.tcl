## simple sms relay for www.sms.ge
## commands: !sms what you want to send
##
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::smsge {
	variable host "www.sms.ge"
	variable cmd "!sms"

	proc doit {type sock {url {}}} {
		switch -- $type {
		wit {
			fileevent $sock writable {}
			fconfigure $sock -buffering full
			set ::smsge::connected($sock) 1
			puts $sock "GET $url HTTP/1.0\n\n"; flush $sock
		}
		rit {
			fileevent $sock readable {}; close $sock
		}
	}
	
	proc con {host url} {
		if {[catch {set sock [socket -async $host 80]} sError] != 0} {
			putlog "ERROR: $sError"
		}
		fileevent $sock writable [list ::smsge::doit wit $sock $url]
		fileevent $sock readable [list ::smsge::doit rit $sock]
	}

	proc pubSms {nick uhost hand chan text} {
		variable cmd;variable host
		if {([string equal {} $text]) || ([llength [split $text { }]] < 2)} {
			putserv "PROVMSG $nick :\[\002ERROR\002\] Usage: /msg $::botnick $cmd <your telephone number> <your message>"
			putserv "PRIVMSG $nick :Example: /msg $::botnick $cmd 11234657890 What are you doing tonight?"; return
		}
		::smsge::con $host "http://www.sms.ge/chat/cgi-bin/cgi.exe?function=ch_send_sms&SmsNick=[join [lindex [split $text { }] 0]]&SmsMsg=[join [lrange [split $text { }] 1 end]]"
	}
	bind msg - $cmd ::smsge::pubSms
}
package provide smsge 0.1

putlog "Example sms.ge script v0.1 by leprechau@EFNet"
