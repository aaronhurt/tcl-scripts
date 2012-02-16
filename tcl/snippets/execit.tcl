#!/usr/local/bin/tclsh8.4

proc bgerror {error} {
	puts stderr "ERROR: $error"
}

proc execit { exec } {
	set exec [join $exec]
	puts "executing: $exec"
	list [doevent [open |${exec} RDWR]]
}

proc doevent { id } {
global endline
	puts "parsing $id"
	fconfigure $id -buffering line
	fileevent $id readable [list getsit $id]
	fileevent stdin readable [list putsit stdin $id]
	vwait endline
}

proc getsit { id } {
uplevel #0 set endline 1
	if {[eof $id] || [catch {gets $id line}]} {
		close $id
	} else {
		puts "$id :: $line"
	}
	vwait endline

}

proc putsit { in id } {
uplevel #0 set endline 1
	if {[eof $id] || [catch {gets $in line}]} {
		close $id
	} else {
		if {[string equal {EXIT} $line]} {
			puts "sending exit"
			fileevent $id writable [puts $id \0x4\n]
		} else {
			fileevent $id writable [puts $id $line]
		}
	}
	vwait endline

}

execit {enscript --pretty-print=tcl --color --language=html -p-}
