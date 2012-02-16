proc timeout {sock} {
global connected
   if {(![info exists connected($sock)]) || ($connected($sock) != 1)} {
      set connected($sock) 0
      close $sock
      puts "Error, Socket($sock) timed out."
   }
}

proc get:data {sock} {
   uplevel #0 set connected($sock) 1
   if {[eof $sock] || [catch {gets $sock line}]} {
      close $sock
   } else { puts $line }
}

proc init {host port} {
   set sock [socket $host $port]
   fconfigure $sock -buffering line
   fileevent $sock readable [list get:data $sock]
   after 1000 [list timeout $sock]
   vwait connected($sock)
}

init localhost 25
