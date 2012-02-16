## simple file fetch via dcc
## no documentation or support
## 
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::fileBurst {

	## configuration ##

	variable filePath "/usr/home/ahurt/lepster/text"
	## path to text file pool only this directory will be searched

	variable warnNotExist "1"
	## show a warning if file requested does not exist

	variable fileTrigger "!!"
	## set to the trigger you want for this script

	## begin script...no more settings ##

	## set a custom flag to disable/enable script
	setudef flag fileburst
	## check file path...

	proc burstIt {nick uhost hand chan text} {
		## check if channel enabled
		if {![channel get $chan fileburst]} {return}
		## check file existence and warn if configured above
		if {[file exists [set txtFile [file join $::fileBurst::filePath $text]]]} {
			## read file in a buffer and catch any errors
			if {[catch {set data [read [set fid [open $txtFile r]]]} oError] != 0} {
				catch {close $fid}; putlog "\002\[ERROR\]\002 Could not read '$txtFile' requested by $nick@$chan :: $oError"; return
			}; catch {close $fid}
			## dcc burst file to user on irc
			::dcctools::chatInit $nick $data
		} else {
			if {$::fileBurst::warnNoExist} {
				putserv "PRIVMSG $chan :Sorry, I couldn't find a file named '$text' in my search path."; return
			}
		}
	}
}
## the bind...
bind pub - $::fileBurst::fileTrigger ::fileBurst::burstIt

## use my very simple dcc chat tools
namespace eval ::dcctools {
	namespace export chatInit
	variable cText {}; variable servSock {}
	variable dccSession; array set dccSession [list]

	proc chatInit {client text} {
		variable servSock; variable cText
		if {![info exists ::my-ip]} {return}
		set cText $text
		foreach {a b c d} [split ${::my-ip} .] {}
		set longip [format %u 0x[format %02X%02X%02X%02X $a $b $c $d]]
		set servSock [socket -myaddr ${::my-ip} -server ::dcctools::chatAccept [set port [expr int(rand() * 3976) + 1024]]]
		putserv "PRIVMSG $client :\001DCC CHAT $client $longip $port\001"
	}

	proc chatAccept {sock addr port} {
		variable servSock; variable dccSession
		putlog "Accepting DCC CHAT ($sock) connection from $addr:$port"
		close $servSock; set dccSession($sock) [list $addr $port]
		fconfigure $sock -buffering line
		fileevent $sock writable [list ::dcctools::chatSend $sock]
	}

	proc chatSend {sock} {
		variable dccSession; variable cText
		fileevent $sock writable {}
		puts $sock [join $cText \n]
		putlog "Terminating DCC CHAT ($sock) to [join $dccSession($sock) {:}]"; close $sock
	}
}
