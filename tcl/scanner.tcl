#!/usr/local/bin/tclsh8.4
#
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

## some settings ##
set irc(nick) "blargie"
## default irc nickname
set irc(server) "irc.banetele.no"
## default irc server hostname/ip
set irc(port) "5190"
## default port of ircserver
set irc(ident) "0"
## enable internal ident server (1 or 0)
set irc(myhost) "moc.scbna.anbcs.com"
## your current host/vhost ("" for default)
set irc(myip) "64.62.132.102"
## your current ip/vhost ip ("" for default)
set socks(4log) "socks4.log"
## where to log socks4 proxies
set socks(5log) "socks5.log"
## where to log socks5 proxies
set socks(ulog) "unknown.log"
## where to log unknown proxies
set socks(cmin) "50"
## minimum users needed for channel to be scanned

## begin script ##
set irc(version) v0.01

proc bgerror {text} {
global errorInfo
	putcon $errorInfo
	exit
}

if {[string equal {} $irc(myhost)]} { set irc(myhost) [info hostname] }
if {[string equal {} $irc(myip)]} {
	catch {socket -server NULL -myaddr $irc(myhost) 0} NullSock
	set irc(myip) [lindex [split [fconfigure $NullSock -sockname]] 0]
	catch {close $NullSock}
}

proc color {{color {}}} {
	switch  -exact -- $color {
		plain     {return [format %c 27]\[0m}
		bold      {return [format %c 27]\[1m}
		underline {return [format %c 27]\[4m}
		blink     {return [format %c 27]\[5m}
		inverted  {return [format %c 27]\[7m}
		invisible {return [format %c 27]\[8m}
		fgblack   {return [format %c 27]\[30m}
		fgred     {return [format %c 27]\[31m}
		fggreen   {return [format %c 27]\[32m}
		fgyellow  {return [format %c 27]\[33m}
		fgblue    {return [format %c 27]\[34m}
		fgmagenta {return [format %c 27]\[35m}
		fgcyan    {return [format %c 27]\[36m}
		fgwhite   {return [format %c 27]\[37m}
		bgblack   {return [format %c 27]\[40m}
		bgred     {return [format %c 27]\[41m}
		bggreen   {return [format %c 27]\[42m}
		bgyellow  {return [format %c 27]\[43m}
		bgblue    {return [format %c 27]\[44m}
		bgmagenta {return [format %c 27]\[45m}
		bgcyan    {return [format %c 27]\[46m}
		bgwhite   {return [format %c 27]\[47m}
		default   {return [format %c 27]\[0m}
	}
}

proc timeout {sock type} {
global connected
	if {(![info exists connected($sock,$type)]) || ($connected($sock,$type) != 1)} {
		set connected($sock,$type) 0
		catch { fileevent $sock writable {} }
		catch { fileevent $sock readable {} }
		close $sock
		putcon "Error, Socket($sock) ($type) timed out."
	}
}

proc ip2long {ip} {
	foreach {a b c d} [split $ip .] {}
	set long [expr {$a * pow(256,3)} + {$b * pow(256,2)} + {$c * 256} + $d]
	return [format %0.f $long]
}

proc validport {port} {
	set port [string trim [join $port ""] ""]
	if {(![regexp \[^0-9\] $port]) || ($port < 1) || ($port > 65535)} {
		return 1
	} else { return 0 }
}

proc putirc {text} {
global irc
	catch {puts $irc(sock) "$text"} retval
	return $retval
}

proc putcon {text} {
	catch {puts stdout "[clock format [clock seconds] -format \[%H:%M:%S\]] $text"} retval
	return $retval

}

proc ident:accept {sock addr port} {
	fconfigure $sock -buffering line
	putcon "Ident requested from $addr\:$port"
	fileevent $sock readable [list ident:respond $sock $addr $port]
	after 30000 [list timeout $sock ident]
}

proc ident:respond {sock addr port} {
global irc
	if {[eof $sock] || [catch {gets $sock line}]} {
		close $sock
		fileevent $sock readable {}
	}
	uplevel #0 set connected($sock,ident) 1
	if {![string match "*,*" "$line"]} {
		puts $sock "$line : ERROR : UNKNOWN-ERROR"
		putcon "Ident replied: $line : ERROR : UNKNOWN-ERROR"
	} elseif {(![validport [lindex [split $line ,] 0]]) || (![validport [lindex [split $line ,] 1]])} {
		puts $sock "$line : ERROR : INVALID-PORT"
		putcon "Ident replied: $line : ERROR : INVALID-PORT"
	} else {
		puts $sock "$line : USERID : UNIX : $irc(nick)"
		putcon "Ident replied: $line : USERID : UNIX : $irc(nick)"
	}
	catch {fileevent $sock readable {}}
	catch {close $sock}
}

proc irc:connect {args} {
global irc
	set args [lindex $args 0]
	set server [lindex $args 0]; set port [lindex $args 1]; set nick [lindex $args 2]
	if {$irc(ident) == 1} { set irc(identdsock) [socket -server ident:accept -myaddr $irc(myhost) 113] }
	set irc(registerd) 0
	if {[string equal ssl [join [lindex [split $server :] 0]]]} {
		set irc(server) [join [lindex [split $server :] 1]]
		set irc(ssl) 1
		package require tls
	} else {
		set irc(server) $server
		set irc(ssl) 0
	}
	if {![string equal {} $port]} { set irc(port) $port } else { set irc(port) 6667 }
	if {![string equal {} $nick]} { set irc(nick) $nick }
	if {$irc(ssl) == 1} {
		set irc(sock) [tls::socket -myaddr $irc(myhost) $irc(server) $irc(port)]
	} else {
		set irc(sock) [socket -myaddr $irc(myhost) $irc(server) $irc(port)]
	}
	fconfigure $irc(sock) -buffering line
	fileevent $irc(sock) readable [list irc:gettext $irc(sock)]
	fileevent $irc(sock) writable [list irc:puttext register]
	fconfigure stdin -buffering line
	fileevent stdin readable [list irc:input stdin]
	# enter event loop for duration of script
	vwait forever
}

proc irc:input {id} {
global irc
	if {[eof $id] || [catch {gets $id line}]} {
		close $id
	}
	if {![info exists irc(lastchan)]} { set irc(lastchan) NULL }
	if {(![string equal {} $line]) && ([string equal {/} [string index $line 0]])} {
		set command [string tolower [join [lindex [split [lindex [split $line] 0] {/}] 1]]]
		switch -- $command {
			quit { putirc "QUIT :blargs $irc(version)" ; putcon "Client quitting...\n" ; after 1000 {exit 0} }
			raw { putirc "[join [lrange [split $line] 1 end]]" }
			scan { putirc "LIST" }
			default { putcon "Sorry, that is not a valid command" }
		}
	} else {
		if {![string equal NULL $irc(lastchan)]} {
			putirc "PRIVMSG $irc(lastchan) :$line"
		}
	}
}

proc irc:puttext {args} {
global irc
	switch -- [lindex $args 0] {
		register {
			if {$irc(registerd) == 0} {
				fileevent $irc(sock) writable {}
				if {$irc(ssl) == 1} { tls::handshake $irc(sock) }
				putcon "Registering with irc server: $irc(server)\:$irc(port)"
				putirc "USER $irc(server)\@$irc(myhost) $irc(myhost) $irc(server) $irc(nick)"
				putirc "NICK $irc(nick)"
				set irc(registerd) 1
				if {$irc(ident) == 1} {
					after 15000 catch {close $irc(identdsock)}
				}
			} else { return }
		}
		pong {
			putirc "PONG $irc(myhost) [lindex $args 1]"
			putcon "[color fggreen]Pong![color]"
		}
		action {
			if {[string match \# [string index [lindex $args 2] 0]]} {
				putcon "[color fgmagenta]* [lindex $args 1]@[lindex $args 2] [lindex $args 3][color]"
			} else {
				putcon "[color fgmagenta]** [lindex $args 1] [lindex $args 3][color]"
			}
		}
		ctcpreply {
			putcon "[color fgyellow][color bold]CTCP [lindex $args 2][color][color fgyellow] from [lindex $args 1][color]"
			putcon "[color fgyellow]--> [color fgyellow][color bold][lindex $args 2][color][color fgyellow] reply of '[lindex $args 3]' sent[color]"
			putirc "NOTICE [lindex $args 1] :\001[lindex $args 2] [lindex $args 3]\001"
		}
		ctcpignore {
			putcon "Ingoring unknown ctcp '[lindex $args 2]' from [lindex $args 1]"
		}
		default { return }
	}
}

# Listening port stuff for a socks4 connection request....
if {[info exists v4sock]} { catch {close $v4sock}; unset v4sock }
proc getconnect {sock addr port} { putcon "GOT CONNECT TO getconnect !!"; catch {close $sock} }
for {set x 2000} {$x < 2999} {incr x} {
	if {![catch {set v4sock [socket -server getconnect -myaddr $irc(myhost) $x]}]} {
		set v4port $x; break
	}
}

# The Scanner...
proc scanit {host {type {}}} {
	if {[catch {socket -async $host 1080} sock]} {
		putcon "Not Valid: Unable to connect to $host."
		return
	}
	fileevent $sock writable [list gotconnect $sock $host $type]
	fileevent $sock readable [list gotread $sock $host $type]
	after 30000 [list timeout $sock sockscan]
}

proc gotconnect {sock host {type {}}} {
global irc env
	# Send it request to connect, if its rejected (broken pipe) port 1080 is not open.
	# 5 = SOCKS5/ 1 = I know 1 authentication methods/ 0 the one i know is 'none' as in completely open
	fconfigure $sock -translation binary -buffering none -blocking 1
	fileevent $sock writable {}
	if {[string equal {v4} $type]} {
		set data "[binary format ccSI 4 1 $v4port [ip2long $irc(myip)]]$env(USER)[binary format c 0]"
	} else {
		set data "[binary format ccc 5 1 0]"
	}
	if {[catch {puts $sock $data}]} { 
		putcon "[color bold]NO SOCKS[color]: not a socks host $host."
		catch {close $sock}
	}
}

# Got reply.
proc gotread {sock host {type {}}} {
global socks
	uplevel #0 set connected($sock,sockscan) 1
	# Read in 2 bytes of data from reply.
	catch {binary scan [read $sock 2] cc reply reply2}
	fileevent $sock readable {}
	catch {close $sock}
	set secure 0
	# Got 2bytes of reply
	if {([info exists reply] && [info exists reply2])} {
		if {$reply == 0} { set reply 4 }
		# Is sock4 or sock5
		if {$reply == 4 || $reply == 5} {
			# Reply was is a socks4 w/ error msg, connect as socks4 and see if open.
			if {$reply == 4 && $reply2 == 91} {
				# If connection is still not granted after second attempt, give up.....
				if {[string equal {v4} $type]} {
					scanit $host v4
					return
				}
			}
			# no auth is required. (90 = sock4, 0 = sock5)
			if {($reply == 4 && $reply2 == 90 || $reply == 5 && $reply2 == 0)} {
				set msg "[color bgred][color fgwhite]OPEN SOCKS: $host is a socks v$reply, without autentication.[color]"
			} else {
				set secure 1
				set msg "[color bgred][color fgwhite]SECURE SOCKS: $host is a socks v$reply but authentication is required.[color]"
			}
			# Unknown reply
		} else {
			set msg "[color fgwhite][color bold]UNKNOWN: $host gave an unrecognized reply.[color]"
		}
		# Log socks.
		switch -- $reply {
			4 {
				if {$secure == 1} {
					set file [open secure.$socks(4log) a+]
				} else {
					set file [open $socks(4log) a+]
				}
			}
			5 {
				if {$secure == 1} {
					set file [open secure.$socks(5log) a+]
				} else {
					set file [open $socks(5log) a+]
				}
			}
			default {
				if {$secure == 1} {
					set file [open secure.$socks(ulog) a+]
				} else {
					set file [open $socks(ulog) a+]
				}
			}
		}
		puts $file "$host"
		close $file
	}
	if {[info exist msg]} { putcon "$msg" }
}

proc sockscan {host channel} {
global scanchans hostscanlist scannedhosts scan_inprogress
	set index [lsearch -exact $hostscanlist $host]
	set hostscanlist [lreplace $hostscanlist $index $index]
	lappend scannedhosts $host; set validsock 1
	scanit $host
	if {[llength $hostscanlist] == 0} {
		putcon "[color bold]SOCKSCAN[color] All hosts from $channel scanned, [llength $scannedhosts] total hosts scanned thus far."
		if {[llength $scanchans] == 0} {
			catch {unset scanchans}; catch {unset scannedhosts}
			putcon "[color bold]SOCKSCAN[color] All channels scanned.  Please wait for scanner to finish hosts from $channel then check logs for results."
			after 5000 [list putirc "PART $channel"]
			catch {unset scan_inprogress}
		} else {
			putcon "[color bold]SOCKSCAN[color] Finished scanning $channel [llength $scanchans] channels left to scan."
			after 5000 [list putirc "PART $channel"]
			after 7000 [list putirc "JOIN [lindex $scanchans 0]"]
		}
	}
	if {[info exists validsock]} {
		putcon "[color bold]SOCKSCAN[color] Scanning $host [llength $hostscanlist] hosts from $channel left to scan."
	}
}

proc irc:gettext {sock} {
global irc scanchans hostscanlist scannedchans socks scan_inprogress
	if {[eof $sock] || [catch {gets $sock line}]} {
		close $sock
	} elseif {$irc(registerd) == 0} {
		irc:puttext register; return
	} else {
		if {[string equal {} $line]} {return}
		set from [string range [join [lindex [split $line] 0]] 1 end]
		set keyword [join [lindex [split $line] 1]]
		set text [join [lrange [split $line] 2 end]]
		#putcon "\[DEBUGGING\] $line"
		#putcon "\[DEBUGGING\] from == $from || keyword == $keyword || text == $text"
		if {[string equal :$irc(server) [join [lindex [split $line] 0]]]} {
			switch -- $keyword {
				NOTICE {
					putcon "[color fgred][join [lindex [split $line {:}] 2]][color]"
				}
				001 - 002 - 003 - 250 - 251 - 255 {
					putcon "[color fgmagenta]*** [join [lindex [split $line {:}] 2]][color]"
				}
				004 - 005 - 252 - 254 {
					putcon "[color fgmagenta]*** [join [lrange [split $line] 3 end]][color]"
				}
				315 {
					set index [lsearch -exact $scanchans [lindex [split $text] 1]]
					set scanchans [lreplace $scanchans $index $index]
					set delay 500; set i $delay
					putcon "[color bold]SOCKSCAN[color] Preparing to scan [llength $hostscanlist] hosts from [lindex [split $text] 1] for open socks."
					putcon "     -- Estimated time to complete [expr ($delay.0 * [llength $hostscanlist])/1000.0] seconds."
					foreach 1host $hostscanlist {
						after $i [list sockscan $1host [lindex [split $text] 1]]
						incr i $delay
					}
				}
				322 {
					set channel [lindex [split $text] 1]
					set numusers [lindex [split $text] 2]
					if {![info exists scan_inprogress]} {
						putcon "[color bold]SOCKSCAN[color] Generating channel list, please be patient."
						set scan_inprogress 1
					}
					if {($numusers >= $socks(cmin)) && ([string index $channel 0] == "#")} {
						lappend scanchans [list $numusers $channel]
					}
				}
				323 {
					if {[info exists scanchans]} {
						foreach index [lsort -increasing -dictionary $scanchans] {
							lappend sorted [lindex $index 1]
						}
						set scanchans $sorted
						putcon "[color bold]SOCKSCAN[color] Preparing to join and scan [llength $scanchans] channels, please be patient."
						after 5000 [list putirc "JOIN [lindex $scanchans 0]"]
					}
				}
				352 {
					if {![info exists scannedhosts]} { lappend scannedhosts $irc(myhost) }
					if {![info exists hostscanlist]} { set hostscanlist "" }
					if {([lsearch -exact $scannedhosts [lindex [split $text] 3]] == -1) && ([lsearch -exact $hostscanlist [lindex [split $text] 3]] == -1)} {
						lappend hostscanlist "[lindex [split $text] 3]"
					}
				}
				366 {
					putirc "WHO [lindex [split $text] 1]"
				}
				372 - 375 - 376 {
					putcon "[color fgyellow][join [lindex [split $line {:}] 2]][color]"
				}
				437 - 471 - 472 - 473 - 474 - 475 {
					set index [lsearch -exact $scanchans [lindex [split $text] 1]]
					set scanchans [lreplace $scanchans $index $index]
					putcon "[color bold]SOCKSCAN[color] Skipping channel [lindex [split $text] 1] [lrange [split $text] 2 end]"
					after 2000 [list putirc "PART [lindex [split $text] 1]"]
					after 5000 [list putirc "JOIN [lindex $scanchans 0]"]
				}
				default { putcon "\[RAW\] $line" }
			}
		} elseif {[string match \001*\001 [string range [join [lrange [split $line] 3 end]] 1 end]]} {
			set ctcp [string toupper [string map {\001 {}} [string range [join [lindex [split $line] 3]] 1 end]]]
			switch -- $ctcp {
				ACTION {
					irc:puttext action [lindex [split [lindex [split $line {:}] 1] {!}] 0] [lindex [split $line] 2] [join [lrange [split $line] 4 end]]
				}
				VERSION {
					irc:puttext ctcpreply [lindex [split [lindex [split $line {:}] 1] {!}] 0] $ctcp "blargs version $irc(version)"
				}
				default {
					irc:puttext ctcpignore [lindex [split [lindex [split $line {:}] 1] {!}] 0] $ctcp
				}
			}
		} elseif {[string equal ERROR [join [lindex [split $line] 0]]]} {
			putcon "[color fgred][color bold]\[ERROR\] [join [lrange [split $line {:}] 1 end]][color]"
		} elseif {[string equal NOTICE [join [lindex [split $line] 0]]]} {
			putcon "[color fgred][join [lrange [split $line {:}] 1 end]][color]"
		} elseif {[string equal PING [join [lindex [split $line] 0]]]} {
			putcon "[color fggreen]Ping?[color]"
			irc:puttext pong [lindex [split $line {:}] 1]
		} elseif {[string equal PRIVMSG [join [lindex [split $line] 1]]]} {
			set from [lindex [split [lindex [split $line {:}] 1] {!}] 0]
			set dest [lindex [split $line] 2]
			set message [string range [join [lrange [split $line] 3 end]] 1 end]
			if {[string match \# [string index $dest 0]]} {
				putcon "[color fgred]\[[color fgblue]$from@$dest[color fgred]\][color] $message"
			} else {
				putcon "[color fgred]*[color fgblue]$from[color fgred]*[color] $message"
			}
		} elseif {[string equal NOTICE [join [lindex [split $line] 1]]]} {
			set from [lindex [split [lindex [split $line {:}] 1] {!}] 0]
			set dest [lindex [split $line] 2]
			set message [string range [join [lrange [split $line] 3 end]] 1 end]
			if {[string match \# [string index $dest 0]]} {
				putcon "[color fgred]-[color fgblue]$from@$dest[color fgred]-[color] $message"
			} else {
				putcon "[color fgred]--[color fgblue]$from[color fgred]--[color] $message"
			}
		} else { putcon "\[RAW\] $line" }
	}
}

if {[llength $argv] == 3} {
	irc:connect $argv
} else {
	putcon "[color fgwhite]Full command line arguments not passed, using default values.[color]"
	irc:connect [list $irc(server) $irc(port) $irc(nick)]
}
