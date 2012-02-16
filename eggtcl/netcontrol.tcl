## simple control of a botnet + some needs support
## initial version...no documentation or support other than provided herein
##
## by leprechau@EFnet
## 
##
## dcc commands:
##
## .net <join|part|say|set|tcl> ?args?
## ^- type command with no arguments for more info
## example: .net join
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::netControl {
    variable version 0.1
    variable nkey "da6e9a94f1e8c99c37dcc54b81c2f329"
}

## handle all of our commands
proc ::netControl::doit {cmd text} {
    ## do what we were supposed to....
    switch -exact -- $cmd {
        JOIN {
            foreach {chan key} $text {}
            if {![validchan $chan] || ![botonchan $chan]} {channel add $chan; putserv "JOIN $chan $key"}
        }
        PART {
            if {[validchan [set chan [lindex $text 0]]]} {channel remove $chan; putserv "PART $chan"}
        }
        SAY {
            if {[string length $text]} {puthelp "PRIVMSG [lindex $text 0] :[join [lrange $text 1 end]]"}
        }
        SET {
            if {[string length $text]} {catch {eval channel set [join [set text]]} eRROR; dccbroadcast "SET: $eRROR"}
        }
        TCL {
            if {[string length $text]} {catch {eval [join [set text]]} eRROR; dccbroadcast "TCL: $eRROR"}
        }
        NEED {
            foreach {bnick chan need} $text {}; if {![validchan $chan] || ![botonchan $chan]} {return}
            switch -exact -- $need {
                op {if {[botisop $chan]} {pushmode $chan +o $bnick}}
                unban {
                    if {![botisop $chan]} {return}
                    foreach cban [chanbans $chan] {
                        foreach {bmask x y} $cban {
                            if {[string match -nocase $bmask [getchanhost $bnick]]} {pushmode $chan -b $bmask}
                        }
                    }
                }
                invite {if {[botisop $chan]} {putserv "INVITE $bnick $chan"}}
                limit {
                    if {![botisop $chan]} {return}
                    foreach {modes x y} [split [getchanmode $chan]] {}
                    if {[string match *k* $modes]} {set limit [expr {$y + 5}]} else {set limit [expr {$x + 5}]}
                    pushmode $chan +l $limit
                }
                key {
                    foreach {modes key y} [split [getchanmode $chan]] {}
                    if {[string match *k* $modes]} {putallbots [list netControl [encrypt ::netControl::nkey "JOIN $chan $key"]]}
                }
            }
        }
        default {return}
    }
}

## our dcc command handler
proc ::netControl::dccCmds {hand idx text} {
    switch -glob -- [lindex [split $text] 0] {
        jo* {
            if {![string length [lindex [split $text] 1]]} {putdcc $idx "Usage: $::lastbind join <#channel> ?key?"; return}
            putdcc $idx "Joining net to [lindex [split $text] 1] ..."
            ::netControl::doit JOIN [list [lindex [split $text] 1] [lindex [split $text] 2]]
            putallbots [list netControl [encrypt ::netControl::nkey "JOIN [list [lindex [split $text] 1] [lindex [split $text] 2]]"]]
        }
        pa* {
            if {![string length [lindex [split $text] 1]]} {putdcc $idx "Usage: $::lastbind part <#channel>"; return}
            putdcc $idx "Parting net from [lindex [split $text] 1] ..."
            ::netControl::doit PART [lindex [split $text] 1]
            putallbots [list netControl [encrypt ::netControl::nkey "PART [lindex [split $text] 1]"]]
        }
        sa* {
            if {![string length [lindex [split $text] 1]]} {putdcc $idx "Usage: $::lastbind say <target> <text>"; return}
            putdcc $idx "Said '[join [lrange [split $text] 2 end]]' to [lindex [split $text] 1] ..."
            ::netControl::doit SAY [list [lindex [split $text] 1] [join [lrange [split $text] 2 end]]]
            putallbots [list netControl [encrypt ::netControl::nkey "SAY [list [lindex [split $text] 1] [join [lrange [split $text] 2 end]]]"]]
        }
        se* {
            if {![string length [lindex [split $text] 1]]} {putdcc $idx "Usage: $::lastbind set <#channel> <setting> ?value?"; return}
            putdcc $idx "Setting '[join [lrange [split $text] 1 end]]' on all bots ..."
            ::netControl::doit SET [lrange [split $text] 1 end]
            putallbots [list netControl [encrypt ::netControl::nkey "SET [join [lrange [split $text] 1 end]]"]]
        }
        tc* {
            if {![string length [lindex [split $text] 1]]} {putdcc $idx "Usage: $::lastbind tcl <code>"; return}
            putdcc $idx "Evaluating '[join [lrange [split $text] 1 end]]' on all bots ..."
            ::netControl::doit TCL [lrange [split $text] 1 end]
            putallbots [list netControl [encrypt ::netControl::nkey "TCL [lrange [split $text] 1 end]"]]
        }
        default {putdcc $idx "Usage: $::lastbind <join|part|say|set|tcl> ?args?"; return}
    }
}
bind dcc n net ::netControl::dccCmds

## bot commmand handler
proc ::netControl::getCmd {from cmd text} {
    ## decrypt text and pass on...
    ::netControl::doit [lindex [set text [decrypt ::netControl::nkey $text]] 0] [lrange $text 1 end]
}
bind bot - netControl ::netControl::getCmd

proc ::netControl::needs {chan need} {
    ## make sure we have some bots linked...else this is pointless
    if {![llength [bots]]} {return}
    ## only send to one bot at a time (at random) to prevent flooding
    putallbots [list netControl [encrypt ::netControl::nkey "NEED [list $::botnick $chan $need]"]]
}
bind need - * ::netControl::needs

putlog "netcontrol.tcl v$::netControl::version by leprchau@EFnet loaded."

## EOF ##