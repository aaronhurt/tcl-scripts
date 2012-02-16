## simple ps list handling tools
## by leprechau@EFnet
## initial version no documentation or support
## other than provided herein
##
## commands:
##
## ::pslist::lst
## ^-- returns an array/keyed list of process data
##
## ::pslist::count cmd OR ::pslist::count "cmd1 cmd2 cmd3 cmd4"
## ^-- returns an array/keyed list of process counts
## multiple cmds optional...at least one required
##
## examples: (from tclsh)
##
##
## % array set pslist [::pslist::lst]
##
##
## % array get pslist
##
## cpu {0.0 0.0 0.0 0.0 0.0 0.0 0.0 0.0} rss {2324 1468 1448 3376 292 2016 3020 4424} tt {p1- ?? p1 p1 p1 ?? p1- p0-} stat {S I S+ S Is S S S} pid {91228 38635 38151 37144 37135 37134 30626 78962} vszs {3000 2408 1852 3732 636 5300 3524 4868} user {ahurt ahurt ahurt ahurt ahurt ahurt ahurt ahurt} mem {0.1 0.1 0.1 0.2 0.0 0.1 0.1 0.2} started {12Jul06 1:46PM 1:31PM 1:04PM 1:04PM 1:04PM 1Aug06 26Jul06} time {7:46.91 0:00.01 0:00.16 0:00.84 0:00.01 0:00.21 5:40.71 105:00.82} command {{./eggdrop sexdoc.conf (eggdrop-1.6.17)} /usr/local/libexec/vsftpd tclsh8.4 {./eggdrop egg.conf (eggdrop-1.6.17)} {-sh (sh)} {sshd: ahurt@ttyp1 (sshd)} {./eggdrop egg.conf (eggdrop-1.6.12)} {./eggdrop secefnet.conf (eggdrop-1.6.16)}}
##
## % foreach pid $pslist(pid) command $pslist(command) {puts "$pid >> $command"}
##
## 91228 >> ./eggdrop sexdoc.conf (eggdrop-1.6.17)
##
## 38635 >> /usr/local/libexec/vsftpd
##
## 38151 >> tclsh8.4
##
## 37144 >> ./eggdrop egg.conf (eggdrop-1.6.17)
##
## 37135 >> -sh (sh)
##
## 37134 >> sshd: ahurt@ttyp1 (sshd)
##
## 30626 >> ./eggdrop egg.conf (eggdrop-1.6.12)
##
## 78962 >> ./eggdrop secefnet.conf (eggdrop-1.6.16)
##
##
## % ::pslist::count [list sh sshd eggdrop tclsh ftpd bash httpd]
##
## 3 sh 1 sshd 4 eggdrop 1 tclsh 0 ftpd 0 bash 0 httpd
##
## % ::pslist::count [list eggdrop sh tclsh]
##
## 4 eggdrop 3 sh 1 tclsh
##
##
## % array set tmp [::pslist::count [list eggdrop sh tclsh]]
##
## % foreach name [lsort -increasing -integer [array names tmp]] {puts "$tmp($name) == $name"}
##
## tclsh == 1
##
## sh == 3
##
## eggdrop == 4
##
## end tclsh examples...nothing to configure or set below ##
##
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::pslist {
	## location of the 'ps' bin...this should work on most all systems
	variable bin [exec which ps]
	
	## parse the ps output and return a keyed list
	proc lst {} {
		## get our list and catch any errors...halt on error
		if {[catch {exec $::pslist::bin auxww} eError] != 0} {
			return -code error "Error: $eError"
		}
		## init a little temp array
		array set outs [list]
		## loop through our list and make sure we cut out
		## the header and last line which is our ps process
		foreach line [lrange [split $eError \n] 1 end-1] {
			foreach index {0 1 2 3 4 5 6 7 8 9} col {user pid cpu mem vszs rss tt stat started time} {
				## set our single word columns
				lappend outs($col) [lindex $line $index];
			}
			## set our trailing bits...the command column
			lappend outs(command) [join [lrange $line 10 end]]
		}
		## return our results as a tcl array/keyed list
		## this makes an easy format to search/parse in another script
		return [array get outs]
	}
	
	proc count {cmds} {
		## catch errors..return empty on error
		if {[catch {::pslist::lst} tmp] != 0} {return {}}
		## setup our ps array
		array set pslist [set tmp]
		## get our counts and make a keyed list
		foreach cmd $cmds {
			lappend outs [llength [lsearch -all -glob $pslist(command) *$cmd*]] $cmd
		}
		## return our keyed list...or return empty if not set...error?
		if {[info exists outs]} {return $outs} else {return {}}
	}
}
