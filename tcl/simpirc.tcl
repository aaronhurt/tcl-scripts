#!/usr/local/bin/tclsh8.4
#
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##


## some settings ##
set irc(nick) "lepIRC"
set irc(server) "irc.banetele.no"
set irc(port) "6667"
set irc(ident) "0"
set irc(myhost) ""

## begin script ##
set irc(version) v0.04

# setting this to 1 shows all raw irc text
set debugging 1

if {[string equal {} $irc(myhost)]} { set irc(myhost) [info hostname] }

proc bgerror {text} {
	putcon $text
	exit
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

proc putirc {text} {
global irc
	catch {puts $irc(sock) "$text"} retval
	return $retval
}

proc putcon {text} {
	catch {puts stdout "[clock format [clock seconds] -format \[%H:%M:%S\]] $text"} retval
	return $retval

}

proc validport {port} {
	set port [string trim [join $port ""] ""]
	if {(![regexp \[^0-9\] $port]) || ($port < 1) || ($port > 65535)} {
		return 1
	} else { return 0 }
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
			dccsend { dcc:init [lindex [split $line] 1] [lindex [split $line] 2] }
			join { putirc "JOIN [lrange [split $line] 1 2]" ; set irc(lastchan) [lindex [split $line] 1] }
			msg { putirc "PRIVMSG [lindex [split $line] 1] :[lrange [split $line] 2 end]" }
			nick { putirc "NICK [lindex [split $line] 1]" ; set irc(nick) [lindex [split $line] 1] }
			part { putirc "PART [lindex [split $line] 1]" }
			quit { putirc "QUIT :lepIRC $irc(version)" ; putcon "Client quitting...\n" ; after 1000 {exit 0} }
			raw { putirc "[join [lrange [split $line] 1 end]]" }
			server { irc:connect [lindex [split $line] 1] [lindex [split $line] 2] $irc(nick) }
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

proc irc:gettext {sock} {
global irc debugging
	if {[eof $sock] || [catch {gets $sock line}]} {
		close $sock
	} elseif {$irc(registerd) == 0} {
		irc:puttext register; return
	} else {
		if {$debugging == 1} { putcon "\[DEBUGGING\] $line" }
		if {[string equal :$irc(server) [join [lindex [split $line] 0]]]} {
			switch -- [lindex [split $line] 1] {
				NOTICE {
					putcon "[color fgred][join [lindex [split $line {:}] 2]][color]"
				}
				001 - 002 - 003 - 250 - 251 - 255 {
					putcon "[color fgmagenta]*** [join [lindex [split $line {:}] 2]][color]"
				}
				004 - 005 - 252 - 254 {
					putcon "[color fgmagenta]*** [join [lrange [split $line] 3 end]][color]"
				}
				372 - 375 - 376 {
					putcon "[color fgyellow][join [lindex [split $line {:}] 2]][color]"
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
					irc:puttext ctcpreply [lindex [split [lindex [split $line {:}] 1] {!}] 0] $ctcp "lepIRC version $irc(version)"
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

proc dcc:init {nick fname} {
global irc dcc
	set myip [lindex [split [fconfigure $irc(sock) -sockname]] 0]
	set longip [ip2long $myip]
	set port [expr int(rand() * 3976) + 1024]
	set dcc(sock) [socket -server dcc:accept_send $port]
	after 15000 [list timeout $dcc(sock) dcc]
	if {![file isfile $fname]} { putcon "ERROR: file not found"; return }
	set dcc(fname) $fname
	putirc "PRIVMSG $nick :\001DCC SEND $fname $longip $port [file size $fname]\001"
}

proc dcc:accept_send {sock addr port} {
global dcc
	fconfigure $sock -encoding binary -translation binary
	putcon "Accepting DCC ($sock) connection from $addr port $port"
	uplevel #0 set connected($dcc(sock),dcc) 1
	set sfile [open $dcc(fname) r]
	fconfigure $sfile -encoding binary -translation binary
	set buff 2048
	set dcc(bsent) 0
	set dcc(start) [clock seconds]
	fcopy $sfile $sock -command [list dcc:send $sfile $sock $buff] -size $buff
}

proc dcc:send {sfile sock buff bytes {error {}}} {
global dcc
	incr dcc(bsent) $bytes
	if {![string equal {} $error]} {
		close $dcc(sock) ; close $sfile
		putcon "ERROR: Error sending $dcc(fname) after $dcc(bsent) bytes: $error"
	} elseif {[eof $sfile]} {
		putcon "FINISHED: Sent $dcc(fname) ($dcc(bsent) bytes) in [expr [clock seconds] - $dcc(start)] seconds."
		close $dcc(sock) ; close $sfile
	} else {
		fcopy $sfile $sock -command [list dcc:send $sfile $sock $buff] -size $buff
	}
}

if {[llength $argv] == 3} {
	irc:connect $argv
} else {
	putcon "[color fgwhite]Full command line arguments not passed, using default values.[color]"
	irc:connect $irc(server) $irc(port) $irc(nick)
}
