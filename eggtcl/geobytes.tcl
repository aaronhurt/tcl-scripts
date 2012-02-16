## geobytes ip locator script
## fetch ip/hostname information from geobytes.com
## no documentation or support other than provided herein
## 
## by leprechau@EFnet
##
## channel settings: .chanset #chan +/-geobytes
## ^-- toggle public commands per channel
##
## public commands: !geo <ip|host|nick>
##
## NOTE: This script uses my http package
## http://woodstock.anbcs.com/scripts/tcl/lephttp.tcl
## download and source before this script
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::geobytes {
	
	## begin settings ##

	variable messagetarget "chan";
	## target for messages on pub commands (nick or chan)

	## end settings ##
	variable version 0.1

	## get my http package from
	## http://woodstock.anbcs.com/scripts/tcl/lephttp.tcl
	package require lephttp
	
	## defines
	setudef flag geobytes

	## out geobytes text tags
	variable geoTags; set geoTags \
	[list cc cnt rc rg ctc ct ctid cert lat lon cap tz nats pop natp prx cia cur mb crc]
	
	## our callback handler
	proc callback {lhost target token} {
		if {[catch {::lephttp::status $token} status] != 0} {return}
		if {![string equal -nocase {OK} $status]} {
			switch -exact -- [string tolower $status] {
				timeout {
					putlog "\[\002GeoBytes\002\] Timeout (60 seconds) on connection to server."
					putserv "PRIVMSG $target :\[\002ERROR\002\] Timeout (60 seconds) on connection to server."
				}
				"not found" {
					putserv "PRIVMSG $target :Sorry, nothing found for: $lhost"
				}
				default {
					putlog "\[\002GeoBytes\002\] Unknown error occured, server output of the error is as follows: $status"
					putserv "PRIVMSG $target :\[\002ERROR\002\] Unknown error occured."
				}
			}
			::lephttp::cleanup $token; return
		}
		set outs [::lephttp::data $token]; ::lephttp::cleanup $token
		
		if {![string match "*unable to locate the address * at this time*" $outs]} { 
			foreach line [split $outs \n] {
				if {[regexp {<input name="(.+?)" value="(.+?)" size="(.+?)" readonly></td>} $line x inam ival isiz]} {
					lappend geoDat [string trim $ival]
				}
			}
			if {![info exists geoDat]} {
				putserv "PRIVMSG $target :\002GeoBytes:\002 Sorry we are unable to locate the address $lhost at this time."; return
			}
			foreach tag $::geobytes::geoTags val $geoDat {
				array set temps [list $tag $val]
			}
			putserv "PRIVMSG $target :\002$lhost\002: Country \($temps(cnt) \($temps(cc)\)\) ~ Region \($temps(rg)\) ~ City \($temps(ct)\) ~ \
			Certainty \($temps(cert)\%\) ~ Latitude \($temps(lat)\) ~ Longitude \($temps(lon)\) ~ Capitol \($temps(cap)\) ~ TimeZone \($temps(tz)\) ~ \
			Population \($temps(pop)\) ~ Map Reference \($temps(cia)\) ~ Currency \($temps(cur)\)"
		} else {
			putserv "PRIVMSG $target :\002GeoBytes:\002 Sorry we are unable to locate the address $lhost at this time."
		}
	}

	## public commands handler
	proc pubCmds {nick uhost hand chan text} {
		if {![channel get $chan geobytes]} {return}
		if {![string length $text]} {
			putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: $::lastbind <ip|host|nick>"; return
		}
		switch -exact -- $::geobytes::messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002GeoBytes\002\] Error, unknown messagetarget specified in script!"; return}
		}
		if {[onchan [string trim [lindex [split $text] 0]] $chan]} {
			set lhost [lindex [split [getchanhost $text $chan] @] end]
		} else {set lhost [string trim [lindex [split $text] 0]]}
		::lephttp::fetch http://geobytes.com/IpLocator.htm?GetLocation -query \
		[::lephttp::formatQuery cid 0 c 0 Template iplocator.htm ipaddress $lhost] \
		-command [list ::geobytes::callback $lhost $target] -timeout 60000
	}
	bind pub - !geo ::geobytes::pubCmds
}
##package provide geobytes $::geobytes::version

putlog "geobytes.tcl v$::geobytes::version by leprechau@EFNet loaded!"
