## usage: sendmail /path/to/sendmail from@email.address to@email.address "subject" "message" cc@email.address
## message should be complete message plain text or html, seperate lines with \n
##
## by leprechau@EFnet
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

proc sendmail {mailbin femail temail subject message {ccemail {}}} {
	if {[catch {set channel [open "|$mailbin -f$femail $temail $ccemail" w]} open_error] != 0} {
		hputs -error "Error: error opening command pipe to $mailbin: $open_error"
		catch {close $channel}
		return
	}
	if {[catch {
		puts $channel "From: $femail \<$femail\>"
		puts $channel "Reply-to: $femail"
		puts $channel "To: $temail \<$temail\>"
		puts $channel "Cc: $ccemail \<$ccemail\>"
		puts $channel "Subject: $subject"
		puts $channel "Mime-Version: 1.0"
		puts $channel "Content-Type: text/plain\; charset=iso-8859-1"
		puts $channel "Content-Transfer-Encoding: 7bit"
		puts $channel ""
		puts $channel "$message"
	} puts_error] != 0} {
		hputs -error "Error: error writing to command pipe ($channel) to $mailbin: $puts_error"
		catch {close $channel}
		return
	}
	close $channel
}