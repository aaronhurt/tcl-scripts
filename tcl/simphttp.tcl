proc timeout {sock} {
global connected
	if {(![info exists connected($sock)]) || ($connected($sock) != 1)} {
		set connected($sock) 0
		close $sock
		puts "Error, Socket($sock) timed out."
	}
}

proc put:data {sock {path {}}} {
	fileevent $sock writable {}
	fconfigure $sock -buffering full
	uplevel #0 set connected($sock) 1
	if {[string equal {} $path]} { set path / }
	puts $sock "GET $path HTTP/1.0\n\n"
	flush $sock
}

proc get:data {sock} {
global data
	if {[eof $sock] || [catch {gets $sock line}]} {
		fileevent $sock readable {}
		close $sock
		uplevel #0 set done($sock) 1
		puts "$sock done"
	} else { set data($sock) [split [read $sock] \n] }
}

proc go {host port {path {}}} {
global data
	set sock [socket $host $port]
	set data($sock) {}
	fileevent $sock writable [list put:data $sock $path]
	fileevent $sock readable [list get:data $sock]
	after 1000 [list timeout $sock]
	vwait done($sock)
	return $sock
}

proc dump:list {sock} {
global data
	puts $data($sock)
}

proc dump:data {sock} {
global data
	foreach line $data($sock) { puts "$line" }
}
