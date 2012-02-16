#!/usr/local/bin/tclsh
####################################
## mftpproxy.tcl by phrek @ efnet ##
####################################
# 0,20,40 * * * *   /mftpproxy.tcl & >/dev/null 2>&1

### Setup ###

#package require tls
load /home/phrek/libtls.so.1
source /home/phrek/tls.tcl
set ct(path) "/home/phrek"
set ct(plogin) "phrek"
set ct(ppass) "bahgabahga"

#############

catch {socket -server iconn 49999} lsock

proc writelog {{arg ""}} {
 global ct
 set fid [open "${ct(path)}/mftpproxy.log" a]
 puts $fid "[clock format [clock seconds] -format %x] [lindex [clock format [clock seconds] -format %c] 3] : $arg"
 close $fid
}

proc exceptsecure {adx csock} {
 global ct
 if {[catch {open "${ct(path)}/except.conf" r} fid2]} {
  return 0
 } else {
  set authtype 2
  while {![eof $fid2]} {
   gets $fid2 line2
   if {[regexp $adx $line2]} { set authtype [lindex $line2 1] }
  }
  close $fid2
  lappend ct($csock) $authtype
  lappend ct($csock) 0
 }
}

proc addexcept {ip authtype} {
 global ct
 if {[catch {open "${ct(path)}/except.conf" a} fid3]} {
  return 0
 } else {
  puts $fid3 "$ip $authtype"
  close $fid3
 }
}

proc xindex {xarg xarg1} {
 return [join [lrange [split $xarg] $xarg1 $xarg1]]
}
proc xrange {xarg xarg1 xarg2} {
 return [join [lrange [split $xarg] $xarg1 $xarg2]]
}

proc sinit {csock adx prt usr} {
 global ct
 if {[catch {socket -async $adx $prt} sockid]} { return 1 }
 lappend ct($csock) $sockid
 fconfigure [lindex $ct($csock) 1] -blocking 0 -buffering line
 fileevent [lindex $ct($csock) 1] readable [list sconn $csock [lindex $ct($csock) 1] $usr]
 exceptsecure $adx $csock
 return 0
}

proc sconn {csock ssock usr} {
 global ct
 if {[eof $ssock] || [catch {gets $ssock line}]} {  
  catch {puts $csock "221 $line"}
  catch {puts $csock "221 "}
  catch {close $csock}
  writelog "C:$csock:Connection closed"
  catch {close $ssock}
  writelog "S:$ssock:Connection closed" 
  catch {unset ct($csock)}
 } else {
  if {[lindex $ct($csock) 0] != 4 && [lindex $ct($csock) 3] == 0 && [string range $line 0 3] == "220 "} {
   switch -- [lindex $ct($csock) 2] {
    0 { puts $ssock "USER $usr" ; return 0}
    1 { puts $ssock "AUTH SSL" ; set ct($sock) [lreplace ct($csock) 3 3 1] return 0 }
   }
  }
  if {[string range $line 0 3] == "220 " && [lindex $ct($csock) 0] != 4 && [lindex $ct($csock) 2] == 2 && [lindex $ct($csock) 3] == 0} {
   puts $ssock "AUTH TLS"
  }
  if {[string range $line 0 2] == "500" || [string range $line 0 2] == "502" || [string range $line 0 1] == "53"} {
   if {[lindex $ct($csock) 3] == 0 && [lindex $ct($csock) 0] != 4} {
    puts $ssock "AUTH SSL"
    set ct($csock) [lreplace $ct($csock) 3 3 1]
   } elseif {[lindex $ct($csock) 0] != 4} {
    puts $ssock "USER $usr"
   }
  }
  if {[string range $line 0 3] == "220-"} {
   return 0
  }
  switch -- [xindex $line 0] {
   220 {return 0}
   234 { if {[lindex $ct($csock) 3] == 0} {
         tls::import $ssock -require false -tls1 true
         if {![catch {tls::handshake $ssock}]} { puts $ssock "USER $usr" }
        } else {
         tls::import $ssock -require false
         if {![catch {tls::handshake $ssock}]} { puts $ssock "USER $usr" }
        }
       }
   331 {catch {puts $csock $line}}
   default {catch {puts $csock $line}}
  }
 }
}

proc iconn {csock adx prt} {
 global ct
 writelog "C:$csock:New connection from $adx on port $prt"
 set ct($csock) 0
 fconfigure $csock -buffering line -blocking 0
 fileevent $csock readable [list cconn $csock]
 fileevent $csock writable [list cwritable $csock]
}

proc cwritable {csock} {
 fileevent $csock writable {}
 catch { puts $csock "220 440 880 1760 3520 7040 14080 28160 56320 112640 225280 450560 901120 1802240" }
}

proc cconn {csock} {
 global ct
 if {[eof $csock] || [catch {gets $csock line}]} {
  catch {close $csock}
  catch {unset ct($csock)}
  writelog "C:$csock:Connection closed"
 } else {
  switch -- [lindex $line 0] {
    USER { if {$ct($csock) == "0"} {
            if {[lrange $line 1 end] == "$ct(plogin)"} {
             catch {puts $csock "331 662 1324 2648 5296 10592 21184 42368 84736 169472 338944 677888 1355776"}
             set ct($csock) 1
            } else {
             catch {puts $csock "001 Invalid command!"}
             writelog "C:$csock:Invalid username given"
             catch {close $csock}
             writelog "C:$csock:Connection closed"
             catch {unset ct($csock)}
            }
           } elseif {$ct($csock) == "2"} {
            #user@ip:port
            writelog "S:$csock:Connecting to Server"
            set slinfo "[lindex [split [lrange $line 1 end] "@:"] 1] [lindex [split [lrange $line 1 end] "@:"] 2] [lindex [split [lrange $line 1 end] "@:"] 0]"
            if {[llength $slinfo] == 2} {
             set slinfo [linsert $slinfo 1 "21"]
            }
            if {[sinit $csock [lindex $slinfo 0] [lindex $slinfo 1] [lindex $slinfo 2]]} {
             # Connection to server failed
             catch {unset ct($csock)}
             catch {close $csock}
             writelog "C:$csock:Connection closed"
            } else {
             # Connection to server success
             set ct($csock) [lreplace $ct($csock) 0 0 "3"]
            }
           } else {
            catch {puts $csock "550 Invalid state."}
           }
         }
    PASS { switch -- [lindex $ct($csock) 0] {
            0 { puts $csock "003 Error processing events!" }
            2 { puts $csock "004 Error processing events!" }
            1 {
                if {[lindex $line 1] == "$ct(ppass)"} {
                  catch {puts $csock "230 460 920 1840 3680 7360 14720 29440 58880 117760 235520 471040 942080 1884160"}
                  set ct($csock) 2
                  writelog "C:$csock:User authorized"
                 } else {
                  catch {puts $csock "002 Error processing events!"}
                  writelog "C:$csock:Invalid password given"
                  catch {close $csock}
                  catch {unset ct($csock)}
                  writelog "C:$csock:Connection closed"
                 }
              }
            3 { 
                catch {puts [lindex $ct($csock) 1] "PASS [lindex $line 1]"}
                catch {puts $csock "240 Proxy Login Successful"}
                set ct($csock) [lreplace $ct($csock) 0 0 "4"]
                writelog "S:$csock:Logging on to Server"
              }
            default { catch {puts $csock "550 Error processing events!"} }
           }
         }
    ADDEXCEPT { if {[llength $line] == 3} {
                 addexcept [lindex $line 1] [lindex $line 2]
                 puts $csock "350 Added except to except.conf"
                 writelog "P:Added except for [lindex $line 1] with auth-type [lindex $line2]"
                 return
                }
              }
    default { 
              writelog $line
              catch {puts [lindex $ct($csock) 1] "$line"}
            }
  }
 }
}

proc bgerror {arg} {puts "error:$arg"}

if {![regexp "\n.*\n" [exec ps x | grep mftpproxy.tcl]]} {vwait forever}