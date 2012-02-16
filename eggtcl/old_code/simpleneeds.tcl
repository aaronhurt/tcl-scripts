##################################################
## simple needs tcl version 1.5                 ##
## by leprechau@efnet                           ##
## Friday, June 13, 2003                        ##
##################################################
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

##################################################
# User Defined Settings                          #
##################################################
# a space deliminated list of bots
# to msg to fulfill needs
# channel names must be all lowercase
set needsbots(#channel1) "bot1 bot2 bot3 bot4"
set needsbots(#channel2) "bot1 bot2 bot3 bot4"
set needsbots(#channel3) "bot1 bot2 bot3 bot4"
set needsbots(#channel4) "bot1 bot2 bot3 bot4"

# a space deliminated list of channels
# forwhich to try and fullfill op needs
set simpleneeds(ops) "#channel1 #channel2 #channel3"

# a space deliminated list of channels
# forwhich to try and fullfill invite needs
set simpleneeds(invite) "#channel1 #channel2 #channel3"

# password used in msg commands to other bots
# should be somehthing long and hard to crack
set simpleneeds(password) "[decrypt HSL9ohw7Y2B633iUo6cD O1P0X.AnufC1pyqGI.Q1YHJ0/ec5C/LqJdC0]"

##################################################
##          DO NOT EDIT THIS SCRIPT             ##
##         DOING SO IS NOT SUPPORTED            ##
##################################################
set simpleneeds_ver "1.5"

proc kill_utimer { command } {    
   set timer_id [lindex $command 0]  
   set killed 0
   foreach 1utimer [utimers] {
      if {[lindex $1utimer 1] == $timer_id} {
         killutimer [lindex $1utimer 2]
         set killed 1
      }
   }
   return $killed
}

proc setutimer { seconds command } {
   if {$seconds < 1} { set seconds 1 }
   kill_utimer "$command"
   utimer $seconds "$command"
}

proc simpleneeds_fill { chan need } {
global botnick simpleneeds needsbots
   set chan [string tolower $chan]
   set need [string tolower $need]
   set searchid [array startsearch needsbots]
   set element [array nextelement needsbots $searchid]
   while {(![string equal {} $element]) && ([info exists searchid])} {
      if {[string equal -nocase $chan $element]} {
         set simpleneeds(bots) "$needsbots($element)"
         array donesearch needsbots $searchid
         catch {unset searchid}
      }
      if {[info exists searchid]} { set element [array nextelement needsbots $searchid] }
   }
   if {[info exists searchid]} { array donesearch needsbots $searchid ; unset searchid }
   if {[string equal "$need" "op"]} {
      if {(![string match -nocase "*$chan*" "$simpleneeds(ops)"]) || ([isop $botnick $chan])} { return 0 }
      set randbot "[lindex [split $simpleneeds(bots)] [rand [llength [split $simpleneeds(bots)]]]]"
      if {([onchan $randbot $chan]) && ([isop $randbot $chan])} {
         putlog "\[\002simpleneeds\002\] Requesting ops from '$randbot' on '$chan' ..."
         putserv "PRIVMSG $randbot :op $simpleneeds(password)"
         setutimer 15 "simpleneeds_fill $chan op"
      }
   } elseif {[string equal "$need" "invite"]} {
      if {(![string match -nocase "*$chan*" "$simpleneeds(invite)"]) || ([onchan $botnick $chan])} { return 0 }
      set randbot "[lindex [split $simpleneeds(bots)] [rand [llength [split $simpleneeds(bots)]]]]"
      putlog "\[\002simpleneeds\002\] Requesting invite to '$chan' from '$randbot' ..."
      putserv "PRIVMSG $randbot :invite $simpleneeds(password) $chan"
      setutimer 15 "simpleneeds_fill $chan invite"
   } else { return 0 }
}

## initialize eggdrop needs system to use this script ##
foreach 1channel $simpleneeds(ops) {
   channel set $1channel need-op {simpleneeds_fill $1channel op}
}
foreach 1channel $simpleneeds(invite) {
   channel set $1channel need-invite {simpleneeds_fill $1channel invite}
}

## check needs (cause eggdrop needs are really slow) ##
proc simpleneeds_checkneeds {} {
global botnick simpleneeds
   setutimer 15 "simpleneeds_checkneeds"
   foreach 1chan $simpleneeds(channels) {
      if {![onchan $botnick $1chan]} {
         simpleneeds_fill $1chan invite
      } elseif {![isop $botnick $1chan]} {
         simpleneeds_fill $1chan op
      } else { return }
   }
}
setutimer 15 "simpleneeds_checkneeds"

putlog "simpleneeds.tcl v$simpleneeds_ver by leprechau@efnet loaded."
