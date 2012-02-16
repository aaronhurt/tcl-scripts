proc hexencode {char} {return "[format %02X [scan $char %c]]"}

proc urlencode {text} {
	set encoded {}
	foreach char [split $text {}] {
		if {(![string equal {.} $char]) && ([regexp \[^a-zA-Z0-9_\] $char])} {
			append encoded "%[hexencode $char]"
		} else {
			append encoded "$char"
		}
	}
	return $encoded
}

proc hexdecode {char} {return "[format %c [format %i 0x$char]]"}

proc urldecode {text} {
	set decoded {}
	if {![string equal {%} [string index $text 0]]} {
		append decoded [lindex [split $text {%}] 0]; set text "[join [lrange [split $text {%}] 1 end] {%}]"
	}
	foreach st [split $text %] {
		if {![string equal {} $st]} {
			append decoded "[hexdecode [string range $st 0 1]][string range $st 2 end]"
		}
	}
	return $decoded
}
