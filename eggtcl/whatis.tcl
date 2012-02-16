## Simple definition script by leprechau
## Version 3.3 -- fixed possible problem with very large databases
###
##### WARNING: this causes old databases to be incompatible with this new version
##### to convert old dbs please see notation below in the settings section
###
## Version 3.2 -- added option to customize all commands in a nice array (advice from kitchen@EFnet)
## Version 3.1 -- fixed namespaces, general code cleanup
## Version 3.0 -- totall rewrite, version number bumped to 3.0 (10.19.2003)
## Version 2.5 -- i forget what i did here :P
## Version 0.1 -> 2.4 -- undocumented changes
## Initial release (sometime in 2000)

## do not edit these lines ##
namespace eval ::whatis {
	namespace export pubRead pubWrite pubDel pubTotal
	## Begin Settings ##

	## set this line to the location of your defintion file
	variable whatislist "/home/ahurt/lepster/scripts/misc/whatis.db"

	## restrict pub write/delete to channel ops and +o users (1=on/0=off)
	variable restrict "1"

	## append time and date term defined and who defined it (1=on/0=off)
	variable tagit "1"

	## maximum number of matches to return for wildcard requests
	variable max_matches "10"

	## customize script public triggers.  Format: {long_command shortcut}
	## Use '-' to disable shortcut for specified command
	variable cmds; array set cmds {
		whatis		{!whatis ??}
		addwhat		{!addwhat !?}
		delwhat		{!delwhat !!}
		helpwhat	{!helpwhat -}
		totalwhat	{!totalwhat -}
	}

	## this code will convert a pre 3.3 database to the new format
	## only uncomment if you are upgrading from version 3.2 or lower
	## then recomment or delete this section after the first script load
	##
	### start upgrade code...uncomment below only if needed
	##
	# package require base64
	# source $whatislist
	# set fid [open $whatislist w]
	# puts $fid [::base64::encode [array get DATA]]; close $fid
	# die "WHATIS - Only run the upgrade code once ... please remove or comment!"
	#
	##
	### end upgrade code

	#####################################################
	## Begin Main Script...DO NOT Edit Below This Line ##
	#####################################################
	variable whatisver "3.3"

	## we are using the base64 package that comes with tcllib
	package require base64

	## Startup and Initialization
	setudef flag nowhatis
	variable DATA; array set DATA [list]
	if {![file isfile $whatislist]} {
		putlog "\[\002ERROR\002\] File '$whatislist' does not exist!"
		putlog "A new file will be created when you add your first term."
	} else {
		putlog "Loading whatis database: $whatislist...."
		if {[catch {set file [open $whatislist r]} open_error] != 0} {
			putlog "\[\002ERROR\002\] Could not open '$whatislist' for reading:  $open_error"; return
		}
		array set DATA [::base64::decode [read $file]]
		if {[catch {close $file} close_error] != 0} {
			putlog "\[\002ERROR\002\] Error closing $file:  $close_error"; return
		}
		putlog "Done, [array size DATA] terms loaded!"
	}

	proc strip {text} {
		regsub -all -- {\003[0-9]{0,2}(,[0-9]{0,2})?|\017|\037|\002|\026} $text {} text
		return $text
	}

	proc getData {term} {
	variable whatislist;variable max_matches;variable DATA
		array set temparray [array get DATA [string tolower $term]]
		if {[array size temparray] > $max_matches} {
			lappend return "\[\002What-is\002\] Query returned $matches matches, which exceeds the maximum displayable number of $max_matches.  Please refine your search and try again."
		} else {
			foreach term [array names temparray] {
				lappend return "\[\002What-is $term\002\] [lindex [array get temparray $term] 1]"
			}
		}
		if {[info exists return]} {return $return} else {return {}}
	}

	proc writeData {term def} {
	variable whatislist;variable DATA
		set term [string tolower $term]
		if {![string equal {} [array get DATA $term]]} {
			return "\[\002ERROR\002\] Error, the term you are trying to add already exists"
		}
		array set DATA [list $term $def]
		if {[catch {set file [open $whatislist w]} open_error] != 0} {
			putlog "\[\002ERROR\002\] Could not open '$whatislist' for writing:  $open_error"; return
		}
		puts $file "[::base64::encode [array get DATA]]"
		if {[catch {close $file} close_error] != 0} {
			putlog "\[\002ERROR\002\] Error closing $file:  $close_error"; return
		}
		return "\[\002Add What-is\002\] $term - $def"
	}

	proc deleteData {term} {
	variable whatislist;variable tagit;variable DATA
		set term [string tolower [string map -nocase {? {} * {} | {}} $term]]
		if {[string equal {} [array get DATA $term]]} {
			return "\[\002ERROR\002\] The term '$term' was not found in the database, and therefore not deleted."
		}
		if {[catch {array unset DATA $term} catch_error] != 0} {
			return "\[\002\ERROR\002\] Term '$term' could not be deleted due to an unknown error."
		} else {
			if {[catch {set file [open $whatislist w]} open_error] != 0} {
				putlog "\[\002ERROR\002\] Could not open '$whatislist' for writing:  $open_error"; return
			}
			puts $file "[::base64::encode [array get DATA]]"
			if {[catch {close $file} close_error] != 0} {
				putlog "\[\002ERROR\002\] Error closing $file:  $close_error"; return
			}
			return "\[\002Del What-is\002\] Term '$term' successfully removed from the database"
		}
	}

	## PUB Commands
	proc pubRead {nick uhost hand chan text} {
		variable restrict;variable cmds
		set text [::whatis::strip $text]
		if {([string equal {} $text]) || ([channel get $chan nowhatis])} { return }
		putcmdlog "#$nick# $::lastbind $text on $chan"
		if {[string equal {} [set output [::whatis::getData $text]]]} {
			if {$restrict && ![isop $nick $chan] && ![matchattr $hand o] && ![matchchanattr $hand o]} {
				puthelp "PRIVMSG $chan :\[\002What-is\002\] That term has not been defined."
			} else {
				puthelp "PRIVMSG $chan :\[\002What-is\002\] That term has not been defined. To define the term use: [lindex [lindex [array get cmds addwhat] end] 0] <term> % <definition>"
			}
		} else {
			foreach line $output {
				if {[string length $line] > 300} {
					set len 0
					while {$len < [string length $line]} {
						set outstring "[string range $line $len [expr [string wordend $line [expr $len + 299]] - 1]]"
						puthelp "PRIVMSG $chan :$outstring"
						incr len [string length $outstring]
					}
				} else { puthelp "PRIVMSG $chan :$line" }
			}
		}
	}
	foreach {cmd shrt} [lindex [array get cmds whatis] end] {
		bind pub - $cmd ::whatis::pubRead
		if {(![string equal {-} $shrt]) && (![string equal {} $shrt])} {
			bind pub - $shrt ::whatis::pubRead
		}
	}

	proc pubWrite {nick uhost hand chan text} {
	variable whatislist;variable restrict;variable tagit
		if {([string equal {} [set text [::whatis::strip $text]]]) || ([channel get $chan nowhatis])} { return }
		if {![string match *%* $text]} {
			puthelp "PRIVMSG $chan :\[\002ERROR\002\] Usage: [lindex [lindex [array get cmds addwhat] end] 0] <term> % <definition>"; return
		}
		set term [string trim [lindex [split $text {%}] 0]]
		set def [string trim [lindex [split $text {%}] 1]]
		putcmdlog "#$nick# $::lastbind $text on $chan"
		if {$restrict && ![isop $nick $chan] && ![matchattr $hand o] && ![matchchanattr $hand o]} {
			puthelp "PRIVMSG $nick :No you can't do that thing when you ain't got that swing!"
			puthelp "PRIVMSG $nick :Command only available to +o users and channel ops."; return
		}
		if {$tagit} {
			append def " --defined by $nick on [date] at [time]"
		}
		if {![string equal {} [set output [::whatis::writeData $term $def]]]} { puthelp "NOTICE $nick :$output" }
	}
	foreach {cmd shrt} [lindex [array get cmds addwhat] end] {
		bind pub - $cmd ::whatis::pubWrite
		if {(![string equal {-} $shrt]) && (![string equal {} $shrt])} {
			bind pub - $shrt ::whatis::pubWrite
		}
	}

	proc pubDel {nick uhost hand chan text} {
	variable whatislist;variable restrict
		if {([string equal {} [set text [::whatis::strip $text]]]) || ([channel get $chan nowhatis])} { return }
		putcmdlog "#$nick# $::lastbind $text on $chan"
		if {$restrict && ![isop $nick $chan] && ![matchattr $hand o] && ![matchchanattr $hand o]} {
			puthelp "PRIVMSG $nick :No you can't do that thing when you ain't got that swing!"
			puthelp "PRIVMSG $nick :Command only available to +o users and channel ops."; return
		}
		if {![string equal {} [set output [::whatis::deleteData $text]]]} {
			puthelp "NOTICE $nick :$output"
		}
	}
	foreach {cmd shrt} [lindex [array get cmds delwhat] end] {
		bind pub - $cmd ::whatis::pubDel
		if {(![string equal {-} $shrt]) && (![string equal {} $shrt])} {
			bind pub - $shrt ::whatis::pubDel
		}
	}

	proc pubTotal {nick uhost hand chan text} {
	variable DATA;variable restrict
		if {[channel get $chan nowhatis]} { return }
		putcmdlog "#$nick# $::lastbind on $chan"
		puthelp "PRIVMSG $chan :\[\002What-is\002\] Total terms defined: [array size DATA]"
	}
	foreach {cmd shrt} [lindex [array get cmds totalwhat] end] {
		bind pub - $cmd ::whatis::pubTotal
		if {(![string equal {-} $shrt]) && (![string equal {} $shrt])} {
			bind pub - $shrt ::whatis::pubTotal
		}
	}

	#PUB help
	proc pubHelp {nick uhost hand chan text} {
		variable cmds
		if {[channel get $chan nowhatis]} { return }
		putcmdlog "#$nick# $::lastbind on $chan"
		puthelp "PRIVMSG $nick :\[\002What-is version $::whatis::whatisver by leprechau PUB Help Menu\002\]"
		puthelp "PRIVMSG $nick :\002[lindex [lindex [array get cmds whatis] end] 0] <term>\002 - gives the definition of the specified term if it has been defined"
		puthelp "PRIVMSG $nick :\002[lindex [lindex [array get cmds addwhat] end] 0] <term> % <definition>\002 - adds the term to the database with the specified term"
		puthelp "PRIVMSG $nick :\002[lindex [lindex [array get cmds delwhat] end] 0] <term>\002 - removes the specified term from the database"
		puthelp "PRIVMSG $nick :\002[lindex [lindex [array get cmds totalwhat] end] 0] <term>\002 - displays a count of the total number of terms in the database"
		puthelp "PRIVMSG $nick :\002[lindex [lindex [array get cmds helpwhat] end] 0]\002 - this help menu"
		puthelp "PRIVMSG $nick : "
		foreach name [array names cmds] {
			foreach {cmd shrt} [lindex [array get cmds $name] end] {}
			if {(![string equal {-} $shrt]) && (![string equal {} $shrt])} {
				append shortcuts "($shrt == $cmd) "
			}
		}
		if {[info exists shortcuts]} {
			puthelp "PRIVMSG $nick :\002Shortcuts:\002 $shortcuts"
		}
	}
	foreach {cmd shrt} [lindex [array get cmds helpwhat] end] {
		bind pub - $cmd ::whatis::pubHelp
		if {(![string equal {-} $shrt]) && (![string equal {} $shrt])} {
			bind pub - $shrt ::whatis::pubHelp
		}
	}
}
package provide whatis 3.2

#end script
putlog "Leprechau What-is.tcl Version $::whatis::whatisver Loaded!"
