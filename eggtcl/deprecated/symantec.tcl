##
## DEPRECATED - NOT MAINTAINED - USE secwatch.tcl
##
## script to check latest virus threats
## commands: !symantec <virus (latest|top)|security|tools
## channel flags: .chanset #channel +/-symantec
## to enable or disable pub commands and announcements
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::symantec {
	
	## begin settings ##
	
	variable maxresults 5;
	## maximum number of results to display on pubcommands
	variable uinterval 10;
	## number of minutes between updates (connecting to symantec.com)
	variable messagetarget "nick";
	## target for messages on pub commands (nick or chan)

	## end settings ##

	variable urls; array set urls {
		vurl "http://securityresponse.symantec.com/avcenter/js/vir.js"
		turl "http://securityresponse.symantec.com/avcenter/js/tools.js"
		aurl "http://securityresponse.symantec.com/avcenter/js/advis.js"
	}
	variable vdata; array set vdata [list]
	variable tdata; array set tdata [list]
	variable adata; array set adata [list]
	variable vdata2; array set vdata2 [list]
	variable tdata2; array set tdata2 [list]
	variable adata2; array set adata2 [list]
	variable uinterval2 0;

	package require http
	::http::config -useragent {Mozilla/4.0 (compatible; MSIE 6.0; Windows NT 5.1; .NET CLR 1.1.4322)}
	setudef flag symantec

	proc callback {type token} {
		#putlog "callback: $type $token"
		variable vdata;variable tdata;variable adata
		variable vdata2;variable tdata2;variable adata2
		if {[catch {::http::status $token} status] != 0} {return}
		if {![string equal {ok} $status]} {
			switch -exact -- $status {
				reset {
					putlog "\[\002SYMANTEC\002\] Connection to server was reset."
				}
				timeout {
					putlog "\[\002SYMANTEC\002\] Timeout (60 seconds) on connection to server."
				}
				default {
					putlog "\[\002SYMANTEC\002\] Unknown error occured, server output of the error is as follows: $status"
				}
			}
			::http::cleanup $token; return
		}
		#putlog "cleaning old $type arrays"
		array unset [set type]2; array set [set type]2 [array get $type]; array unset $type
		foreach line [split [::http::data $token] \n] {
			if {![string equal {} $line]} {
				array set $type [list [lindex $line 1] [split [string trim [string map {' {} [ {} ] {} ; {}} [join [lindex [split $line {=}] end]]]] {,}]]
			}
		}
		::http::cleanup $token; if {![array size [join [set type]2]]} {return}
		#putlog "checking array $type..."
		switch -exact -- $type {
			vdata {
				foreach var {risk name url date} var2 {risk2 name2 url2 date2} element {symTrisks symTnames symTurls symTdates} {
					set $var [lindex [lindex [array get vdata $element] end] 0]; set $var2 [lindex [lindex [array get vdata2 $element] end] 0]
				}
				if {![string equal $name $name2]} {
					putlog "\[\002V-ALERT\002\] [::symantec::risk $risk] $date \002$name\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url"
					foreach chan [channels] {
						if {[channel get $chan symantec]} {
							puthelp "PRIVMSG $chan :\[\002V-ALERT\002\] [::symantec::risk $risk] $date \002$name\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url"
						}
					}
				}
				foreach var {risk name url date} var2 {risk2 name2 url2 date2} element {symLrisks symLnames symLurls symLdates} {
					set $var [lindex [lindex [array get vdata $element] end] 0]; set $var2 [lindex [lindex [array get vdata2 $element] end] 0]
				}
				if {![string equal $name $name2]} {
					putlog "\[\002V-ALERT\002\] [::symantec::risk $risk] $date \002$name\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url"
					foreach chan [channels] {
						if {[channel get $chan symantec]} {
							puthelp "PRIVMSG $chan :\[\002V-ALERT\002\] [::symantec::risk $risk] $date \002$name\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url"
						}
					}
				}
			}
			tdata {
				foreach var {name url} var2 {name2 url2} element {symRnames symRurls} {
					set $var [lindex [lindex [array get tdata $element] end] 0]; set $var2 [lindex [lindex [array get tdata2 $element] end] 0]
				}
				if {![string equal $name $name2]} {
					putlog "\[\002T-ALERT\002\] \002$name removal tool\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url"
					foreach chan [channels] {
						if {[channel get $chan symantec]} {
							puthelp "PRIVMSG $chan :\[\002T-ALERT\002\] \002$name removal tool\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url"
						}
					}
				}
			}
			adata {
				foreach var {name url} var2 {name2 url2} element {symAnames symAurls} {
					set $var [lindex [lindex [array get adata $element] end] 0]; set $var2 [lindex [lindex [array get adata2 $element] end] 0]
				}
				if {![string equal $name $name2]} {
					putlog "\[\002S-ALERT\002\] \002$name\002 >> http://securityresponse.symantec.com/avcenter/security/Content/$url"
					foreach chan [channels] {
						if {[channel get $chan symantec]} {
							puthelp "PRIVMSG $chan :\[\002S-ALERT\002\] \002$name\002 >> http://securityresponse.symantec.com/avcenter/security/Content/$url"
						}
					}
				}
			}
		}
	}

	proc getData {minute hour day month year} {
		variable urls;variable uinterval;variable uinterval2
		if {[incr uinterval2] >= $uinterval} {
			foreach url {vurl turl aurl} type {vdata tdata adata} {::http::geturl $urls($url) -command "::symantec::callback $type" -timeout 60000}
			set uinterval2 0
		}
	}
	bind time - "* * * * *" ::symantec::getData

	proc risk {num} {
		switch -exact -- $num {
			1 {return "\002\00300,02 $num \003\002"}
			2 {return "\002\00300,03 $num \003\002"}
			3 {return "\002\00300,09 $num \003\002"}
			4 {return "\002\00300,07 $num \003\002"}
			5 {return "\002\00300,04 $num \003\002"}
		}
	}

	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan symantec]} {return}
		variable maxresults;variable messagetarget;variable vdata;variable tdata;variable adata;
		switch -exact -- [string trim $text] {
			{virus latest} {set type vdata; set subt latest}
			{virus top} {set type vdata; set subt top}
			security {set type adata; set subt {}}
			tools {set type tdata; set subt {}}
			default {
				putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: !symantec <virus (latest|top)|security|tools>"; return
			}
		}
		putcmdlog "# $nick@$chan !symantec $text #"
		switch -- $messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002SYMANTEC\002\] Error, unknown messagetarget specified in script!"; return}
		}
		set lineout 0
		switch -exact $type {
			vdata {
				switch -exact -- $subt {
					latest {
						foreach risk $vdata(symLrisks) name $vdata(symLnames) url $vdata(symLurls) date $vdata(symLdates) {
							if {(![string equal {} $risk]) && (![string equal {} $name]) && (![string equal {} $url]) && (![string equal {} $date])} {
								puthelp "PRIVMSG $target :[::symantec::risk $risk] $date \002$name\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url"
								if {[incr lineout] >= $maxresults} {break}
							}
						}
					}
					top {
						foreach risk $vdata(symTrisks) name $vdata(symTnames) url $vdata(symTurls) date $vdata(symTdates) {
							if {(![string equal {} $risk]) && (![string equal {} $name]) && (![string equal {} $url]) && (![string equal {} $date])} {
								puthelp "PRIVMSG $target :[::symantec::risk $risk] $date \002$name\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url"
								if {[incr lineout] >= $maxresults} {break}
							}
						}
					}
				}
			}
			tdata {
				foreach name $tdata(symRnames) url $tdata(symRurls) {
					if {(![string equal {} $name]) && (![string equal {} $url])} {
						puthelp "PRIVMSG $target :\002$name removal tool\002 >> http://securityresponse.symantec.com/avcenter/venc/data/$url"
						if {[incr lineout] >= $maxresults} {break}
					}
				}
			}
			adata {
				foreach name $adata(symAnames) url $adata(symAurls) {
					if {(![string equal {} $name]) && (![string equal {} $url])} {
						puthelp "PRIVMSG $target :\002$name\002 >> http://securityresponse.symantec.com/avcenter/security/Content/$url"
						if {[incr lineout] >= $maxresults} {break}
					}
				}
			}
		}
	}
	bind pub - !symantec ::symantec::pubCmds
}
package provide symantec 1.0

## start init ##
foreach timer [utimers] {
	if {[string match {::symantec::getData*} [join [lindex $timer 1]]]} {
		killutimer [lindex $timer end]
	}
}
set ::symantec::uinterval2 $::symantec::uinterval; utimer 8 {::symantec::getData - - - - -}
## end init ##

putlog "symantec.tcl v1.0 by leprechau@EFNet loaded!"
