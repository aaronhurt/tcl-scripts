###########################
##  File Distribution
##
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
set distro_flag "X"

proc md5sum {input} {
	if {[catch {exec md5sum} error] != 0} {
		return [lindex [exec md5 $input] 3]
	} else { return [lindex [exec md5sum $input] 0] }
}

proc distro_prep {bot command arg} {
	global distro_md5
	if {[string match *filesys* [modules]] == 0} {catch {loadmodule filesys}}
	set dfile [lindex [split $arg] 0]
	if {[file isfile $dfile.distro]} {
		file delete -force $dfile.distro
		putlog "\[\002DISTRO\002\] Cleaning temp file ($file.distro) from prevoius update."
	}
	set distro_md5 "[lindex $arg 0]"
} 
bind bot - distroprep distro_prep

proc distro {hand idx arg} {
	global distro_flag distro_md5 botnet-nick
	set dfile [lindex [split $arg] 0]
	set bots [lrange [split $arg] 1 end] 
	putcmdlog "#$hand# distro $arg"
	if {![matchattr ${botnet-nick} $distro_flag]} {putidx $idx "\[\002DISTRO\002\] For security reasons, this command is only available on +$distro_flag bots." ; return}
	if {$arg == ""} {putidx $idx "\002Usage:\002 .distro <file> <*|bot1 \[bot2\] ...>" ; return}
	if {![file exists $dfile]} {putidx $idx "\[\002ERROR\002\] File '$dfile' does not exist." ; return}
	file copy -force $dfile $dfile.distro
	catch {set distro_md5 "[md5sum $dfile.distro]"}
	if {![info exists distro_md5]} {set distro_md5 "UNKNOWN"}
	set i 1
	set delay [expr [file size $dfile] / 30720]
	if {$arg != "*" && $arg != ""} {
		set pending [llength $bots]
		foreach 1bot $bots {
			if {[matchattr $1bot bo]} {
				catch {putbot $1bot "distroprep $distro_md5" ; incr pending -1}
				utimer $i "catch {dccsend $dfile.distro [hand2nick $1bot]}"
				utimer [expr $i + 1] "putidx $idx {\[\002DISTRO\002\] Sending '$dfile' to [hand2nick $1bot].}"
				utimer [expr $i + 1] "putdcc $idx {*** \002$pending\002 send(s) still pending.}"
				set i [expr $i + $delay]
			} else { putidx $idx "\[\002ERROR\002\] Can not send $dfile to non +bo bot(s)." ; return }
		}
	} elseif {$arg == "*"} {
		if {[bots] == ""} { putidx $idx "\[\002ERROR\002\] No linked bots found." ; return}
		set pending [llength [bots]]
		foreach 1bot [bots] {
			if {[matchattr $1bot bo} {
				catch {putbot $1bot "distroprep $distro_md5" ; incr pending -1}
				utimer $i "catch {dccsend $dfile.distro [hand2nick $1bot]}"
				utimer [expr $i + 1] "putidx $idx {\[\002DISTRO\002\] Sending '$dfile' to [hand2nick $1bot].}"
				utimer [expr $i + 1] "putdcc $idx {*** \002$pending\002 send(s) still pending.}"
				set i [expr $i + $delay]
			} else { putidx $idx "\[\002ERROR\002\] Can not send '$dfile' to non +bo bot(s)." ; return }
		}
	} else { return }
}
bind dcc n distro distro

proc got_distro {hand nick path}  {
	global distro_md5 distro_flag
	catch {unloadmodule filesys}
	if {[string match *.distro* $path] == 1} {
		catch {set gotfile_md5 "[md5sum [set dfile [file tail $path]]"}
		if {![info exists gotfile_md5]} {set gotfile_md5 "UNKNOWN"}
		if {[matchattr [nick2hand $nick] $distro_flag]}  {
			if {($distro_md5 == "UNKNOWN") || ($gotfile_md5 == "UNKNOWN")} {
				putlog "\[\002DISTRO\002\] MD5 sum unknown, check skipped."
			} else {
				if {$distro_md5 != $gotfile_md5} {
					putlog "\[\002DISTRO\002\] MD5 sum mismatch.  Original file '$distro_md5' vs downloaded file '$gotfile_md5'"
					putlog "*** Deleting '$dfile.distro', please re-distro."
					file delete -force $dfile.distro
					return
				}
			}
			file rename -force $dfile $dfile.old ; file rename -force $dfile.distro $dfile
			putlog "\[\002DISTRO\002\] Successfully recieved '$dfile' from [nick2hand $nick]."
			rehash
		} else {
			putlog "\[\002WARNING\002\] Recieved '$dfile' from unauthorized source : '\002$nick\002'."
			putlog " *** Deleting file from unauthorized source."
			file delete -force $dfile.distro
			return
		}
	} else { 
		putlog "\[\002WARNING\002\] Recieved unknown file '\002$path\002' from : '\002$nick\002'."
		putlog " *** Deleting file '\002$path\002'."
		file delete -force $path
		return
	}
}
bind rcvd b *  got_distro
