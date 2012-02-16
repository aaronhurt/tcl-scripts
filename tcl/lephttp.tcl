## lep's simple http package
## stripped down...simple and fast
## last update: 10.28.2006
##
## supported switches to ::lephttp::geturl -> -command -query -headers -timeout
## supported switches to ::lephttp::config -> -accept -useragent
##
## added commands:
##
## ::lephttp::formatQuery <var1 value2 var2 value2 var3 value3 ...>
## ^- return a string suitable for use
## with -query option of ::lephttp::geturl
##
## ::lephttp::status <token>
## ^- get return status associated with token
##
## ::lephttp::map <text>
## ^- map html and xml entities
##
## ::lephttp::maphtml <text>
## ^- map html entities only
##
## ::lephttp::mapxml <text>
## ^- map xml entities only
##
## ::lephttp::strip <text>
## ^- strip all html tags from text
##
## ::lephttp::encode <text>
## ^- url encode text
##
## ::lephttp::header <token> [pattern]
## ^- return all headers associated with 'token'
## or just headers matching pattern if specified
##
## ::lephttp::tokens
## ^- returns all current tokens
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::lephttp {
	## package version :)
	variable version 0.31
	## all current html 4.01 entities according to http://www.w3schools.com/tags/ref_entities.asp
	variable htmlEntities; array set htmlEntities {
		nbsp \xa0 iexcl \xa1 cent \xa2 pound \xa3 curren \xa4 yen \xa5 brvbar \xa6 sect \xa7 uml \xa8 copy \xa9
		ordf \xaa laquo \xab not \xac shy \xad reg \xae macr \xaf deg \xb0 plusmn \xb1 sup2 \xb2 sup3 \xb3 acute \xb4
		micro \xb5 para \xb6 middot \xb7 cedil \xb8 sup1 \xb9 ordm \xba raquo \xbb frac14 \xbc frac12 \xbd frac34 \xbe
		iquest \xbf Agrave \xc0 Aacute \xc1 Acirc \xc2 Atilde \xc3 Auml \xc4 Aring \xc5 AElig \xc6 Ccedil \xc7 Egrave \xc8
		Eacute \xc9 Ecirc \xca Euml \xcb Igrave \xcc Iacute \xcd Icirc \xce Iuml \xcf ETH \xd0 Ntilde \xd1 Ograve \xd2
		Oacute \xd3 Ocirc \xd4 Otilde \xd5 Ouml \xd6 times \xd7 Oslash \xd8 Ugrave \xd9 Uacute \xda Ucirc \xdb Uuml \xdc
		Yacute \xdd THORN \xde szlig \xdf agrave \xe0 aacute \xe1 acirc \xe2 atilde \xe3 auml \xe4 aring \xe5 aelig \xe6
		ccedil \xe7 egrave \xe8 eacute \xe9 ecirc \xea euml \xeb igrave \xec iacute \xed icirc \xee iuml \xef eth \xf0
		ntilde \xf1 ograve \xf2 oacute \xf3 ocirc \xf4 otilde \xf5 ouml \xf6 divide \xf7 oslash \xf8 ugrave \xf9 uacute \xfa
		ucirc \xfb uuml \xfc yacute \xfd thorn \xfe yuml \xff fnof \u192 Alpha \u391 Beta \u392 Gamma \u393 Delta \u394
		Epsilon \u395 Zeta \u396 Eta \u397 Theta \u398 Iota \u399 Kappa \u39A Lambda \u39B Mu \u39C Nu \u39D Xi \u39E
		Omicron \u39F Pi \u3A0 Rho \u3A1 Sigma \u3A3 Tau \u3A4 Upsilon \u3A5 Phi \u3A6 Chi \u3A7 Psi \u3A8 Omega \u3A9
		alpha \u3B1 beta \u3B2 gamma \u3B3 delta \u3B4 epsilon \u3B5 zeta \u3B6 eta \u3B7 theta \u3B8 iota \u3B9 kappa \u3BA
		lambda \u3BB mu \u3BC nu \u3BD xi \u3BE omicron \u3BF pi \u3C0 rho \u3C1 sigmaf \u3C2 sigma \u3C3 tau \u3C4 upsilon \u3C5
		phi \u3C6 chi \u3C7 psi \u3C8 omega \u3C9 thetasym \u3D1 upsih \u3D2 piv \u3D6 bull \u2022 hellip \u2026 prime \u2032
		Prime \u2033 oline \u203E frasl \u2044 weierp \u2118 image \u2111 real \u211C trade \u2122 alefsym \u2135 larr \u2190
		uarr \u2191 rarr \u2192 darr \u2193 harr \u2194 crarr \u21B5 lArr \u21D0 uArr \u21D1 rArr \u21D2 dArr \u21D3 hArr \u21D4
		forall \u2200 part \u2202 exist \u2203 empty \u2205 nabla \u2207 isin \u2208 notin \u2209 ni \u220B prod \u220F sum \u2211
		minus \u2212 lowast \u2217 radic \u221A prop \u221D infin \u221E ang \u2220 and \u2227 or \u2228 cap \u2229 cup \u222A
		int \u222B there4 \u2234 sim \u223C cong \u2245 asymp \u2248 ne \u2260 equiv \u2261 le \u2264 ge \u2265 sub \u2282
		sup \u2283 nsub \u2284 sube \u2286 supe \u2287 oplus \u2295 otimes \u2297 perp \u22A5 sdot \u22C5 lceil \u2308 rceil \u2309
		lfloor \u230A rfloor \u230B lang \u2329 rang \u232A loz \u25CA spades \u2660 clubs \u2663 hearts \u2665 diams \u2666 quot \x22
		amp \x26 lt \x3C gt \x3E OElig \u152 oelig \u153 Scaron \u160 scaron \u161 Yuml \u178 circ \u2C6 tilde \u2DC ensp \u2002
		emsp \u2003 thinsp \u2009 zwnj \u200C zwj \u200D lrm \u200E rlm \u200F ndash \u2013 mdash \u2014 lsquo \u2018 rsquo \u2019
		sbquo \u201A ldquo \u201C rdquo \u201D bdquo \u201E dagger \u2020 Dagger \u2021 permil \u2030 lsaquo \u2039 rsaquo \u203A
		euro \u20AC
	}
	## our state array..everything we store is in here
	## don't 'overwrite' this info if it already exists
	if {(![array exists ::lephttp::state]) || (![array size ::lephttp::state])} {
		variable state; array set state [list tokenID 0 accept "*/*" \
		useragent "Mozilla/5.0 (compatible; LepHTTP/$::lephttp::version; +http://woodstock.anbcs.com/scripts/lephttp.tcl)"]
	}

	## new option fetcher
	proc getOpt {opts key text} {
		## make sure only valid options are passed
		foreach {opt val} $text {
			if {[lsearch -exact $opts $opt] == -1} {
				return -code error "Unknown option '$opt', must be one of: [join $opts {, }]"
			}
		}
		## return selected option
		if {[set index [lsearch -exact $text $key]] != -1} {
			return [lindex $text [expr {$index +1}]]
		} else {return {}}
	}

	## configure default state array
	proc config {args} {
		if {[llength $args]} {
			if {[string length [set useragent [::lephttp::getOpt {-accept -useragent} -useragent $args]]]} {
				array set ::lephttp::state [list useragent $useragent]
			}
			if {[string length [set accept [::lephttp::getOpt {-accept -useragent} -accept $args]]]} {
				array set ::lephttp::state [list accept $accept]
			}
		} else {return "[array get ::lephttp::state accept] [array get ::lephttp::state useragent]"}
	}

	## create tokens
	proc gettok {} {
		set token ::lephttp::[incr ::lephttp::state(tokenID)]
		array set ::lephttp::state [list $token,useragent $::lephttp::state(useragent) $token,accept $::lephttp::state(accept) $token,afterid {}]
		return $token
	}

	## map html entities
	proc maphtml {text} {
		if {[regexp -all -- {\&([a-zA-z0-9]+)\;} $text]} {
			foreach {x y} [regexp -all -inline -- {\&([a-zA-z0-9]+)\;} $text] {
				if {[string length [set char [lindex [array get ::lephttp::htmlEntities $y] end]]]} {
					set text [string map [list $x $char] $text]
				}
			}; return $text
		} else {return $text}
	}

	## map xml entities
	proc mapxml {text} {
		if {[regexp -all -- {\&\#([0-9]+)\;} $text]} {
			foreach {x y} [regexp -all -inline -- {\&\#([0-9]+)\;} $text] {
				set text [string map [list $x [format %c $y]] $text]
			}; return $text
		} else {return $text}
	}

	## map hex and html entities
	proc map {text} {
		set text [::lephttp::xml [::lephttp::maphtml $text]]; return $text
	}

	## remove html tags...little ugly with the return but we want 8.3+ compat
	proc strip {text} {regsub -all -- {(<.+?>)} $text {} retval; return $retval}

	## encode urls
	proc encode {text} {
		foreach 1char [split $text {}] {
			if {(![string equal {.} $1char]) && ([regexp \[^a-zA-Z0-9_\] $1char])} {
				append encoded "%[format %02X [scan $1char %c]]"
			} else {append encoded "$1char"}
		}
		if {[info exists encoded]} {return $encoded} else {return $text}
	}

	## format a post query
	proc formatQuery {args} {
		foreach {var value} $args {lappend outs [::lephttp::encode $var]=[string map {{%20} {+}} [::lephttp::encode $value]]}
		return [join $outs {&}]
	}

	## timeout check...
	proc timeout {token} {
		if {([info exists ::lephttp::state($token,connected)]) && ($::lephttp::state($token,connected) != 1)} {
			set ::lephttp::state($token,connected) 0; catch {close $::lephttp::state($token,sock)}
			set ::lephttp::state($token,done) 1; set ::lephttp::state($token,status) timeout
			::lephttp::outputIt $token
		}
	}

	## execute our callback if we had one...
	proc outputIt {token} {
		if {[string length [set cmd [::lephttp::getOpt {-command -query -headers -timeout} -command $::lephttp::state($token,args)] ]]} {
			catch {eval [linsert [set cmd] end $token]}
		}
	}

	## tell httpd what we want from it
	proc writeIt {token} {
		fileevent [set sock $::lephttp::state($token,sock)] writable {}
		if {[string length [set sockError [fconfigure $sock -error]]]} {
			::lephttp::cleanup $token; catch {close $sock}; return -code error "Error opening socket: $sockError"
		}
		set ::lephttp::state($token,connected) 1; catch {after cancel $::lephttp::state($token,afterid)}
		if {[string length [set query [::lephttp::getOpt {-command -query -headers -timeout} -query $::lephttp::state($token,args)]]]} {
			puts $sock "POST $::lephttp::state($token,path) HTTP/1.0"
			puts $sock "Accept: $::lephttp::state($token,accept)"
			puts $sock "Host: $::lephttp::state($token,host)"
			puts $sock "User-Agent: $::lephttp::state($token,useragent)"
			if {[string length [set headers [::lephttp::getOpt {-command -query -headers -timeout} -headers $::lephttp::state($token,args)]]]} {
				foreach {key val} $headers {if {![string match *: $key]} {set key "$key\:"}; puts $sock "$key $val"}
			}
			puts $sock "Content-type: application/x-www-form-urlencoded"
			puts $sock "Content-length: [string length $query]"
			puts $sock ""
			puts $sock "$query"
			puts $sock ""; flush $sock
		} else {
			puts $sock "GET $::lephttp::state($token,path) HTTP/1.0"
			puts $sock "Accept: $::lephttp::state($token,accept)"
			puts $sock "Host: $::lephttp::state($token,host)"
			puts $sock "User-Agent: $::lephttp::state($token,useragent)"
			if {[string length [set headers [::lephttp::getOpt {-command -query -headers -timeout} -headers $::lephttp::state($token,args)]]]} {
				foreach {key val} $headers {if {![string match *: $key]} {set key "$key\:"}; puts $sock "$key: $val"}
			}
			puts $sock ""; flush $sock
		}
		## keep event loop updated untill read (only run if we are not in eggdrop)
		if {[lsearch -exact [info commands] *dcc:dccstat] == -1} {
			while {([info exists ::lephttp::state($token,done)]) && ($::lephttp::state($token,done) == 0)} {
				## conserve cpu...pause for 1/100th of a second between updates
				update; after 10
			}
		}
	}

	## read in the data and append to data array
	proc readIt {token} {
		fileevent [set sock $::lephttp::state($token,sock)] readable {}; set ::lephttp::state($token,done) 1
		if {[string length [set sockError [fconfigure $sock -error]]]} {
			::lephttp::cleanup $token; catch {close $sock}; return -code error "Error opening socket: $sockError"
		}
		set rawRead {}; while {![eof $sock]} {append rawRead [read $sock]}; catch {close $sock}
		## seperate headers from body
		set loc response; foreach line [split $rawRead \n] {
			if {![info exists ::lephttp::state($token,response)]} {
				set ::lephttp::state($token,status) [string tolower [join [lrange [split $line] 2 end]]]
				set ::lephttp::state($token,ncode) [lindex [split $line] 1]
				set ::lephttp::state($token,protocol) [lindex [split $line] 0]
				set ::lephttp::state($token,$loc) $line; set loc headers; continue
			}
			if {([string equal $loc headers]) && ([string equal {} $line])} {
				set loc body; continue
			}
			append ::lephttp::state($token,$loc) $line\n
		}
		::lephttp::outputIt $token
	}

	## setup the fileevents and open the socket async
	proc geturl {url args} {
		if {(![regexp -nocase {^(http://)?([^:/]+)(:([0-9]+))?(/.*)?$} $url x prot host y port path]) || (![string match http* $prot])} {
			return -code error "Invalid URL: $url"
		}; set token [::lephttp::gettok]
		## just a couple sanity checks...
		if {![string equal {/} [string index $path 0]]} {set path "/$path"}; if {![string length $port]} {set port 80}
		## check if we got this passed from the fetch proc
		if {[llength $args] == 1} {set args [lindex $args 0]}
		## continue on...and open the socket
		if {[catch {socket -async $host $port} sock] != 0} {
			::lephttp::cleanup $token; catch {close $sock}; return -code error "Error opening socket: $sock"
		}
		## setup our state array with the basic info we need to go on...
		array set ::lephttp::state [list $token,args $args $token,prot $prot $token,host $host $token,port $port $token,path $path $token,sock $sock]
		## continue now setting up our socket...
		fconfigure $sock -buffering line -buffersize 1024 -blocking off
		fileevent $sock writable [list ::lephttp::writeIt $token]
		fileevent $sock readable [list ::lephttp::readIt $token]
		if {[string length [set timeo [::lephttp::getOpt {-command -query -headers -timeout} -timeout $args]]]} {
			set ::lephttp::state($token,afterid) [after $timeo ::lephttp::timeout $token]
		}
		## set our progress vars...
		set ::lephttp::state($token,status) ok
		set ::lephttp::state($token,connected) 0; set ::lephttp::state($token,done) 0
		## keep event loop updated untill connect (only run if we are not in eggdrop)
		if {[lsearch -exact [info commands] *dcc:dccstat] == -1} {
			while {([info exists ::lephttp::state($token,connected)]) && ($::lephttp::state($token,connected) == 0)} {
				## conserve cpu...pause for 1/100th of a second between updates
				update; after 10
			}
		}
		## return our 'token'
		return $token
	}

	## for easy compat with http package
	proc fetch {url args} {::lephttp::geturl $url $args}

	## return status
	proc status {token {text {}}} {
		if {![string length [set status [array get ::lephttp::state $token,status]]]} {
			return -code error "Invalid data token specified"
		}
		switch -exact -- [string tolower $text] {
			protocol {return $::lephttp::state($token,protocol)}
			ncode {return $::lephttp::state($token,ncode)}
			full {return $::lephttp::state($token,response)}
			default {return [string tolower [lindex $status end]]}
		}
	}

	## little compat for http package
	proc code {token} {::lephttp::status $token full}

	## little compat for http package
	proc ncode {token} {::lephttp::status $token ncode}

	## return header data
	proc header {token {text {}}} {
		if {![string length [set data [array get ::lephttp::state $token,headers]]]} {
			return -code error "Invalid data token specified"
		}
		if {[string length $text]} {
			if {![string match *: $text]} {set text $text\:}
			foreach line [split [lindex $data end] \n] {
				if {[string match -nocase $text* $line]} {
					lappend outs [join [lrange [split $line] 1 end]]
				}
			}
			if {[info exists outs]} {return $outs}; return {}
		} else {return [lindex $data end]}
	}

	## return body data
	proc data {token} {
		if {![string length [set data [array get ::lephttp::state $token,body]]]} {
			return -code error "Invalid data token specified"
		}
		return [lindex $data end]
	}

	## cleanup arrays
	proc cleanup {token} {
		catch {array unset ::lephttp::state $token,*}
	}

	## list current tokens
	proc tokens {} {
		if {[llength [set toks [array names ::lephttp::state ::lephttp::*]]]} {
			foreach tok $toks {lappend tokens [lindex [split $tok {,}] 0]}
			return [lsort -decreasing -dictionary -unique $tokens]
		} else {return {}}
	}
}
package provide lephttp $::lephttp::version
