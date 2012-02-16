## settings ##
set ListenPort "65000"
# listening port (mirc connects to this)
set MyAddr "216.218.252.31"
# ip address to bind to (leave blank to listen on all interfaces)
set AuthKey "9afgEuzFArZtRfoR89y0GRaCo24W5lJI2P56puA6"
# authentication key (set to a long random string)
set IpRestrict "1"
# restriction: (0) server not ip restricted (1) server is restricted (use this)
set IpList "66.143.*"
# space deliminated list of accepted ip addresses (full wildcard masks allowed)
set LogType "1"
# logtype: (0) log to partyline(only) (1) write log to logfile and partyline
set LogFile "MsgShell.log"
# location and name of logfile (no trailing /)

## end settings ##

proc timestamp {} { return [clock format [clock seconds] -format "%a %b %d %H:%M:%S %Z %Y"] }

proc msgshell:write_log { text } {
global LogType LogFile
	putlog "$text"
	if {$LogType == 1} {
		set logfile [open $LogFile a+ 0600]
		puts $logfile "$text"
		close $logfile
	}
}

proc msgshell:close_socket { addr sock } {
global Authorized Session
	close $sock
	catch { unset Authorized($addr,$sock) }
	catch { unset Session($addr,$sock) }
}

proc msgshell:server_connect { sock addr cport } {
global Session IpRestrict IpList Authorized
	set allow_connect 0 ; set Authorized($addr,$sock) 0
	set Session($addr,$sock) [list $addr $cport]
	fconfigure $sock -buffering line
	if {$IpRestrict == 1} {
		foreach ip "$IpList" {
			if {[string match "$ip" "$addr"]} {
				set allow_connect 1
			}
		}
	} else { set allow_connect 1 }
	if {$allow_connect != 1} {
		msgshell:write_log "Closed unauthorized connect ($sock) from $Session($addr,$sock) at [timestamp]"
		catch { msgshell:close_socket $addr $sock }
	} else {
		msgshell:write_log "Accepted connection $sock from $Session($addr,$sock)"
		fileevent $sock readable [list msgshell:input_handler $sock $addr]
	}
}

proc msgshell:input_handler { sock addr } {
global Session ServerSock MyAddr ListenPort AuthKey Authorized Target
	if {[eof $sock] || [catch {gets $sock line}]} {
		fileevent $sock readable {}
		close $sock
		msgshell:write_log "Closed $Session($addr,$sock)"
		unset Session($addr,$sock)
	} else {
		switch -- [lindex [split $line] 0] {
			+HEADER {
				set header [split [lindex [split $line] 1] :]
				if {[string equal "[lindex $header 0]" "$AuthKey"]} { set Authorized($addr,$sock) 1 }
				if {![string equal {} "[lindex $header 1]"]} { set Target($addr,$sock) [lindex $header 1] }
			}
			+MESSAGE {
				if {$Authorized($addr,$sock) != 1} {
					msgshell:write_log "Closed unauthorized connect ($sock) from $Session($addr,$sock) at [timestamp]"
					catch { msgshell:close_socket $addr $sock }
					return
				} elseif {$Authorized($addr,$sock) == 1} {
					putlog "Accepting message to '$Target($addr,$sock)' from $Session($addr,$sock) ..."
					putserv "PRIVMSG $Target($addr,$sock) :[join [lrange [split $line] 1 end]]"
					putlog "Message sent to '$Target($addr,$sock)' successfully."
				} else {
					msgshell:write_log "Closed unauthorized connect ($sock) from $Session($addr,$sock) at [timestamp]"
					catch { msgshell:close_socket $addr $sock }
					return
				}
			}
			EOF {
				msgshell:write_log "Closing connect ($sock) from $Session($addr,$sock) at [timestamp]"
				catch { msgshell:close_socket $addr $sock }
			}
			default {
				puts $sock "ERROR: Invalid Input, closing session."
				msgshell:write_log "Closing connect ($sock) from $Session($addr,$sock) at [timestamp]"
				catch { msgshell:close_socket $addr $sock }
			}
		}
	}
}

proc msgshell:shutdown {type} {
global ServerSock Session
	putlog "MsgShell: Shutting down..."
	catch {close $ServerSock}
	foreach id [array names Session] {
		catch {close [lindex [split $id ,] 1]}
	}
	putlog "MsgShell: Shutdown complete!"
}
bind evnt - prerehash msgshell:shutdown
bind evnt - prerestart msgshell:shutdown

proc msgshell:initialize {} {
global ListenPort MyAddr IpRestrict IpList ServerSock
	if {$MyAddr != ""} {
		set ServerSock [socket -server msgshell:server_connect -myaddr $MyAddr $ListenPort]
	} else {
		set ServerSock [socket -server msgshell:server_connect $ListenPort]
	}
	putlog "MsgShell: Listening Port $ListenPort"
	if {$MyAddr != ""} {
		putlog "MsgShell: Listening Host $MyAddr"
	} else {
		putlog "MsgShell: Listening Host *"
	}
	if {$IpRestrict == "1"} {
		putlog "MsgShell: IP Restriction Active"
		putlog "MsgShell: Allowed IPs: $IpList"
	} else {
		putlog "MsgShell: IP Restriction NOT ACTIVE (please activate for increased security)"
	}
	putlog "MsgShell: Active"
	msgshell:write_log "Server socket ($ServerSock) opened at [timestamp]"
}

msgshell:initialize