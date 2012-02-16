## my clean code version of an irc classic
## complete with diffuse stats and anti cheats/abuse...feeling lucky?
##
## by leprechau@Efnet
##
## channel settings: +/-timebomb ... bomb-flood bombs:seconds
##
## this script requires my floodcontrol namespace:
## http://woodstock.anbcs.com/scripts/eggtcl/floodcontol.tcl
##
## pub commands: !timebomb <nick> ?-evil? ... !cutwire <color> ... !bombstats <nick>
##
## 
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
#

## a few options you can customize if you wish
namespace eval ::timeBomb {

    ## begin settings ##

    ## our wire color options
    variable colors [list orange green lime blue teal brown tan white tope red pink black charcoal purple indigo yellow canary]
    ## minimum and maximum number of wires to have on a bomb (max:min)
    variable wlimit "5:3"
    ## minimum and maximum timer values (max:min)
    variable tlimit "60:15"
    ## floodcontrol setting (max bombs:seconds)
    ## this is the default value...channel flag overwrites this setting
    variable bflood "5:180"
    ## max idle time a person can have (in minutes) and still be bombed (this is to help prevent abuse)
    ## a setting of 0 will disable and allow anyone to be bombed regardless of idle time
    variable ilimit "3"
    ## full path and filename of our stats db
    variable statsdb "/home/ahurt/lepster/scripts/misc/timebomb.db"

    ## end settings ##
    
    ## our state array..we will cache all of our hosts/times/etc.. here
    variable STATE; array set STATE [list]
    ## stats array...all of our users stats are kept here
    variable STATS; array set STATS [list]
    ## set our channel flag/str
    setudef flag timebomb; setudef str bomb-flood
    ## require my floodcontrol namespace
    package require floodcontrol
}

## begin main script procs..nothing to do below here

## initialize our stats db/array
proc ::timeBomb::init {} {
    if {![file isfile $::timeBomb::statsdb]} {
        putlog "File '$::timeBomb::statsdb' does not exist, a new file will be created."
    } else {
        putlog "Loading timebomb stats database: $::timeBomb::statsdb ...."
        if {[catch {set fid [open $::timeBomb::statsdb r]} oError] != 0} {
            putlog "\[\002ERROR\002\] Could not open '$::timeBomb::statsdb' for reading:  $oError"; return
        }
        foreach line [split [read $fid] \n] {
            foreach {x y} $line {array set ::timeBomb::STATS [list $x $y]}
        }
        if {[catch {close $fid} cError] != 0} {
            putlog "\[\002ERROR\002\] Error closing $::timeBomb::statsdb:  $cError"; return
        }; putlog "Done - user statistics loaded!"
    }
}
## do it...
::timeBomb::init

## help set random numbers with definate min and max range
proc ::timeBomb::rand {max {min {0}}} {
    ## reseed the random number generator...this is horrid and not cryptographically secure
    ## however...it works for this little script
    expr {srand(int(abs(rand()*[clock clicks])))}
    ## return our semi-random number
    return [expr {int(rand()*($max-$min))+$min}]
}

## randomize a list
proc ::timeBomb::mixit {list} {
    foreach x $list {
        set rindex [::timeBomb::rand [llength $list]]
        lappend mixed [lindex $list $rindex]
        set list [lreplace $list $rindex $rindex]
    }; return $mixed
}

proc ::timeBomb::stats {nick type {yn {}}} {
    ## generate the users id
    set nid [md5 [string tolower $nick]]
    ## continue on
    switch -exact -- $type {
        GET {
            if {[string length [set svs $::timeBomb::STATS($nid,saves)]] && [string length [set bls $::timeBomb::STATS($nid,blows)]]} {
                return " Saves: $svs Blows: $bls -> [format %0.2f [expr {(($svs*1.00)/($bls+$svs))*100}]]\% Average Save Rate"
            } else {return {}}
        }
        SET {
            ## make sure the nick exists in stats array...if not create and zero entries
            if {![string length [array get ::timeBomb::STATS $nid,blows]]} {array set ::timeBomb::STATS [list $nid,blows 0]}
            if {![string length [array get ::timeBomb::STATS $nid,saves]]} {array set ::timeBomb::STATS [list $nid,saves 0]}
            ## continue on...
            switch -exact -- $yn {
                0 {incr ::timeBomb::STATS($nid,blows)}
                1 {incr ::timeBomb::STATS($nid,saves)}
                default {return}
            }
            if {[catch {set fid [open $::timeBomb::statsdb w]} oError] != 0} {
                putlog "\[\002ERROR\002\] Could not open '$::timeBomb::statsdb' for writing:  $oError"; return
            }
            foreach {x y} [array get ::timeBomb::STATS] {puts $fid [list $x $y]}
            if {[catch {close $fid} cError] != 0} {
                putlog "\[\002ERROR\002\] Error closing $::timeBomb::statsdb:  $cError"; return
            }
        }
        default {return}
    }
}

## blow the bomb and clean up array
proc ::timeBomb::blow {tgt chan} {
    ## check for cheaters...
    if {![onchan $tgt $chan]} {
        ## see if we can find them by host
        foreach nick [chanlist $chan] {
            if {[string equal -nocase [getchanhost $nick $chan] $::timeBomb::STATE([string tolower $tgt],uhost)]} {
                ## ahahah..we found them...
                puthelp "PRIVMSG $chan :You can run but you can't hide from me $tgt ..."; set kickee $nick; break
            }
        }
    }
    if {![info exists kickee]} {set kickee $tgt}
    ## record this poor attempt
    ::timeBomb::stats $tgt SET 0
    ## make sure we are opped...if so kick...if not settle for an action message
    if {[botisop $chan] && [onchan $kickee $chan]} {
        putserv "KICK $chan $kickee :KaBLOOWeeeeEEEE ... BlAAAmmmMM ... BooOOOoMMmmM \(should have cut the $::timeBomb::STATE([string tolower $tgt],wire) wire\)"
    } else {puthelp "PRIVMSG $chan :\001ACTION KaBLOOWeeeeEEEE ... BlAAAmmmMM ... BooOOOoMMmmM \($kickee should have cut the \
    $::timeBomb::STATE([string tolower $tgt],wire) wire\)\001"}
    ## show thier stats
    puthelp "PRIVMSG $chan :Current stats for $tgt: [::timeBomb::stats $tgt GET]"
    ## check our evil and interactive settings before we clear the STATE array
    if {$::timeBomb::STATE([string tolower $tgt],evil)} {set evil 1}
    if {$::timeBomb::STATE([string tolower $tgt],interactive)} {set interactive 1}
    ## clean up the STATE array...
    array unset ::timeBomb::STATE [string tolower $tgt],*
    ## was this an evil bomb...if so let's throw em another till they get it right
    if {[info exists evil]} {
        ## make sure this is a live target...not just some idle boob
        if {![info exists interactive]} {
            puthelp "PRIVMSG $chan :Looks like $tgt fell asleep standing up again...let's leave em alone for a bit."; return
        }
        ## continue on..and at least warn them we are being evil...
        puthelp "PRIVMSG $chan :Well...hope you have better luck next time...new bomb coming in 10 seconds!"
        ## simulate the pub command call thanks to a tricky proc declaration for ::timeBomb::pubCmds
        utimer 10 [list ::timeBomb::pubCmds $tgt - - $chan "$tgt -evil" !timebomb]
    }
}

## handle our pub commands...little extra bit in declaration is explained above in ::timeBomb::blow
proc ::timeBomb::pubCmds {nick uhost hand chan text {force {}}} {
    ## make sure we are on an active channel
    if {![channel get $chan timebomb]} {return}
    ## this is needed for when we are being evil and calling this proc manually
    if {![string length $force]} {set switchvar $::lastbind} else {set switchvar $force}
    switch -exact -- $switchvar {
        !timebomb {
            ## give em some usage info
            if {![string length $text]} {puthelp "PRIVMSG $chan :Usage: $::lastbind <nick> ?-evil?"; return}
            ## check/fetch our flood settings
            if {![string length [set flood [channel get $chan bomb-flood]]]} {
                ## the string is not set...let's use our default from above
                set ::floodcontrol::flimits(bombFlood) $::timeBomb::bflood
            } else {set ::floodcontrol::flimits(bombFlood) $flood}
            ## see if we are in a flood state...if so...stop...if not continue on
            if {[::floodcontrol::check bombFlood]} {
                puthelp "PRIVMSG $chan :Sorry, im all out of explosives...you trigger happy kiddies will have to wait for the supply truck."; return
            }
            ## make sure nobody is trying to bomb a bomb on the bot or other bots
            if {[string equal -nocase $::botnick [set tgt [lindex [split $text] 0]]] || [matchattr $tgt b]} {
                puthelp "NOTICE $nick :Silly terrorist, you cannot bomb the bomber or his crew!"; return
            }
            ## make sure this nick isn't already being bombed and they are on the channel...also make sure we aren't abusing the idle...
            if {![onchan $tgt $chan]} {
                puthelp "PRIVMSG $chan :Sorry, I couldn't find anyone named '$tgt' to bomb."; return
            } elseif {($::timeBomb::ilimit != 0) && ([set itime [getchanidle $tgt $chan]] >= $::timeBomb::ilimit)} {
                puthelp "PRIVMSG $chan :Come on now...let's play fair $tgt has been idle for $itime minutes."; return
            } elseif {[string length [array get ::timeBomb::STATE [string tolower $tgt],*]]} {
                puthelp "PRIVMSG $chan :Are you kidding me...$tgt already has a bomb to deal with!"; return
            }
            ## see if we are being evil...if so record it...also, don't let anyone but ops be evil
            if {[string equal -nocase {-evil} [lindex [split $text] 1]]} {
                if {(![isop $nick $chan] && ![matchattr $hand o|o $chan]) && ![string length $force]} {
                    puthelp "PRIVMSG $chan :Sorry, but only ops get to be evil around here...better get some tight fitting pants."; return
                }
                array set ::timeBomb::STATE [list [string tolower $tgt],evil 1]
            } else {array set ::timeBomb::STATE [list [string tolower $tgt],evil 0]}
            ## pick a timer value and make the announcement
            set tval [eval ::timeBomb::rand [split $::timeBomb::tlimit {:}]]
            puthelp "PRIVMSG $chan :\001ACTION Stuffs a bomb in ${tgt}'s pants.  The timer is set for \002$tval\002 seconds.\001"
            ## pick our wire colors options and diffuse color and tell them how to diffuse it
            set wcols [lrange [::timeBomb::mixit $::timeBomb::colors] 0 [eval ::timeBomb::rand [split $::timeBomb::wlimit {:}]]]
            puthelp "PRIVMSG $chan :Diffuse the bomb by cutting the correct wire with: !cutwire <color>.  You have [llength $wcols] choices: [join $wcols {, }]"
            ## let's keep track of who actually tries to cut a wire...set initial state to 0
            array set ::timeBomb::STATE [list [string tolower $tgt],interactive 0]
            ## since we seem to have cheaters...let's store a hostmask just incase they try to hide from us
            array set ::timeBomb::STATE [list [string tolower $tgt],uhost [getchanhost $tgt $chan]]
            ## set the actual timer and record the ID in our state array along with the diffuse wire...so we can cancel on a correct cut
            array set ::timeBomb::STATE [list [string tolower $tgt],wire [lindex $wcols [::timeBomb::rand [llength $wcols]]]]
            array set ::timeBomb::STATE [list [string tolower $tgt],tid [utimer $tval [list ::timeBomb::blow $tgt $chan]]]
            ## okay now that we are through all of that junk...let's go ahead and record this to our floodcounter
            ::floodcontrol::record bombFlood $uhost
        }
        !cutwire {
            ## give em some usage info..
            if {![string length $text]} {puthelp "PRIVMSG $chan :Usage: $::lastbind <color>"; return}
            ## check if we have any bombs actually placed
            if {![array size ::timeBomb::STATE]} {
                puthelp "PRIVMSG $chan :Sorry, I can't find any active bombs at the moment...maybe you would like to set one?"; return
            }
            ## next make sure the person cutting the wire has a bomb set for them..
            if {![string length [array get ::timeBomb::STATE [string tolower $nick],*]]} {
                puthelp "PRIVMSG $chan :Sorry, I didn't place a bomb in your pants...so stop trying to cut wires."; return
            }
            ## okay...done with that junk...now lets see if they saved themselves or not
            if {[string equal -nocase [lindex [split $text] 0] $::timeBomb::STATE([string tolower $nick],wire)]} {
                ## wow nice work...let's tell em the get to live and cancel the timer...also cleanup the STATE array
                puthelp "PRIVMSG $chan :\001ACTION Click....${nick}'s bomb has been diffused!\001"
                killutimer $::timeBomb::STATE([string tolower $nick],tid); array unset ::timeBomb::STATE [string tolower $nick],*
                ## record it for the record...
                ::timeBomb::stats $nick SET 1
                ## show em thier stats...
                if {[string length [set stats [::timeBomb::stats $nick GET]]]} {
                    puthelp "PRIVMSG $chan :Current stats for $nick: $stats"
                }
            } else {
                ## they are interacting...so let's at least mark that they gave it a try
                array set ::timeBomb::STATE [list [string tolower $nick],interactive 1]
                ## they still didn't quite make it though...let's blow the bomb (and unset the timer)
                killutimer $::timeBomb::STATE([string tolower $nick],tid); ::timeBomb::blow $nick $chan
            }
        }
        !bombstats {
            ## give em some usage info
            if {![string length $text]} {puthelp "PRIVMSG $chan :Usage: $::lastbind <nick>"; return}
            if {[string length [set stats [::timeBomb::stats [lindex [split $text] 0] GET]]]} {
                puthelp "PRIVMSG $chan :Current stats for [lindex [split $text] 0]: $stats"
            } else {puthelp "PRIVMSG $chan :Sorry, I couldn't find any stats for [lindex [split $text] 0]."}
        }
        default {return}
    }
}
## all the pub binds that goto the proc above...
bind pub - !timebomb ::timeBomb::pubCmds
bind pub - !cutwire ::timeBomb::pubCmds
bind pub - !bombstats ::timeBomb::pubCmds

## if the kiddie parts or quits clean the array and unset any timers
proc ::timeBomb::getQuitters {nick uhost hand chan {msg {}}} {
    ## make sure this nick is an offender
    if {[string length [set data [array get ::timeBomb::STATE [string tolower $nick],*]]]} {
        ## clean the array and unset any pinding timers
        killutimer $::timeBomb::STATE([string tolower $nick],tid); array unset ::timeBomb::STATE [string tolower $nick],*
        ## also just let them know they are being watched...
        puthelp "PRIVMSG $chan :\001ACTION Hunts $nick down and guts them like the dirty motherless goat they are!\001"
    }
}
bind part - * ::timeBomb::getQuitters
bind sign - * ::timeBomb::getQuitters

putlog "timebomb.tcl v1.0 by leprechau@EFnet loaded!"

## EOF ##