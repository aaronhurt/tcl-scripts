## example survey type tcl
## by leprechau@EFnet
##
## INCOMPLETE...NOT WORKING...
##
## always check for newer code at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::survey {

	variable questions {
		{{Do you have IRC?} {yes no}}
		{{Do you have hotmail?} {yes no}}
	}
	## set your questions and answers in a list
	variable timeout 30
	## how many seconds can elapse before we stop waiting for an answer
	variable results "/path/to/results/file.txt"
	variable Sessions;array set Sessions [list]
	## internal sessions variable

	proc askQ {uhost} {
		variable questions;variable timeout;variable Sessions
		if {![string equal {} [array get Sessions $uhost]]} {
			foreach {uhost nick qnum last} [array get Sessions $uhost] {}
			if {$qnum >= [llength $questions]} {
				putserv "PRIVMSG $nick :Thank you for completing the survey."
				array unset Sessions $uhost; return
			} elseif {[expr {[clock seconds] - $last}] >= $timeout} {
				putserv "PRIVMSG $nick :Sorry you could not complete the survey.  Session has timed out."
				array unset Sessions $uhost; return
			} else {
				incr Sessions(qnum)
				putserv "PRIVMSG $nick :[lindex [set q [lindex $questions $qnum]] 0] ([lindex $q end])"
			}
		}
	}

	proc getReply {nick uhost hand text} {
		variable results;variable Sessions

	}