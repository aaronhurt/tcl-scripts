## simple mailer code..
## usage: ::eMail::doMail <sender> <sender fullname> <recipient> <recipient fullname> <subject> <message content>
##
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::eMail {

	## initial settings ##

	variable mailer "smtp";
	## outgoing email method ("smtp", "sendmail" or "none"
	
	variable sendmailpath "/usr/sbin/sendmail"
	## complete path to your sendmail binary (only required if using 'sendmail' above)
	
	variable smtphost "127.0.0.1:25"
	## the ip:port of your smtp server (only required if using 'smtp' above)

	## end settings ##

	## handle smtp outbound socket
	proc smtpWrite {sndr sndrfn rcpt rcptfn subj msg header sock} {
		fileevent $sock writable {}; fconfigure $sock -buffering line
		if {[catch {puts $sock "mail from: $sndr\nrcpt to: $rcpt\ndata"} pError] != 0} {
			catch {close $sock}; return -code error "Error writing to smtp socket($sock): $pError"
		}
		if {[catch {puts $sock [join [concat $header $msg] \n]} pError] != 0} {
			catch {close $sock}; return -code error "Error writing to command pipe: $pError"
		}
		if {[catch {puts $sock ".\n\nquit\n"} pError] != 0} {
			catch {close $sock}; return -code error "Error writing to smtp socket($sock): $pError"
		}
		if {[catch {close $sock} cError] != 0} {
			catch {close $sock}; return -code error "Error closing socket($sock): $cError"
		}
	}
	## handle outgoing email
	proc doMail {sndr sndrfn rcpt rcptfn subj msg} {
		set headertxt {
			"From: \"$sndrfn\" \<$sndr\>"
			"To: \"$rcptfn\" \<$rcpt\>"
			"Subject: $subj"
			"Date: [clock format [clock seconds] -format {%a, %d %b %Y %H:%M:%S -0000} -gmt 1]"
			"Mime-Version: 1.0"
			"Content-Type: text/plain; format=flowed"
			"X-Generator: eMail.tcl v0.1 by leprechau@EFnet"
			""
		}
		foreach 1line $headertxt {lappend header [subst $1line]}
		switch -exact -- $::eMail::mailer {
			sendmail {
				if {[catch {set fid [open "|$::eMail::sendmailpath $rcpt" w+]} oError] != 0} {
					catch {close $fid}; return -code error "Error opening command pipe: $oError"
				}
				if {[catch {puts $fid [join [concat $header $msg] \n]} pError] != 0} {
					catch {close $fid}; return -code error "Error writing to command pipe: $pError"
				}
				if {[catch {close $fid} cError] != 0} {
					catch {close $fid}; return -code error "Error closing command pipe: $cError"
				}
			}
			smtp {
				foreach {host port} [split $::eMail::smtphost {:}] {}
				if {[catch {set sock [socket -myaddr localhost -async $host $port]} oError] != 0} {
					catch {close $sock}; return -code error "Error opening smtp socket: $oError"
				}
				fileevent $sock writable [list ::eMail::smtpWrite $rcpt $rcptfn $subj $msg $header $sock]
			}
			default {return}
		}
	}
}