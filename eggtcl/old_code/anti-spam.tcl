##################################################
## selectable anti-spam mask ban version 1.0    ##
## by leprechau@efnet saturday, oct. 5 2002     ##
##################################################
##          DO NOT EDIT THIS SCRIPT             ##
##         DOING SO IS NOT SUPPORTED            ##
##################################################

proc sindex { string index } { return [lindex [split [string trim $string] " "] $index] }

proc add_spammasks { handle idx args } {
global spamban_masks nameban_masks
   if {[matchattr $handle d] || (![matchattr $handle n])} { putdcc $idx "What?  You need '.help'" ; return }
   if {$args == ""} { putdcc $idx "\002Usage:\002 .+spamban <hostmask> <realname mask>" ; return }
   set banmask "[sindex $args 0]"
   set namemask "[sindex $args 1]"
   if {![string match *!*@* $arg]} { putdcc $idx "Invalid ban - hostmask must be of the form:  nick!ident@host" ; return }
   if {(![info exists spamban_masks]) || ([llength $spamban_masks] == 0)} {
      set spamban_masks $banmask
   } elseif {[lsearch -exact $spamban_masks $banmask] == -1} {
      lappend spamban_masks $banmask
   } else { putdcc $idx "Sorry, but that spamban mask already exists." ; putdcc $idx "Current spamban masks: $spamban_masks" ; return }
   if {(![info exists nameban_masks]) || ([llength $nameban_masks] == 0)} { set nameban_masks $arg } else { lappend nameban_masks $arg }
   putdcc $idx "New spamban mask '$banmask' and nameban mask '$namemask' added." ; return
}
bind dcc n|- +spamban add_spammasks

proc rem_spammasks { handle idx arg } {
global spamban_masks nameban_masks
   if {[matchattr $handle d] || (![matchattr $handle n])} { putdcc $idx "What?  You need '.help'" ; return }
   set arg "[sindex $arg 0]"
   if {$arg == ""} { putdcc $idx "\002Usage:\002 .-spamban <hostmask> <realname mask>" ; return }
   set banmask "[sindex $args 0]"
   set namemask "[sindex $args 1]"
   if {![string match *!*@* $arg]} { putdcc $idx "Invalid ban - hostmask must be of the form:  nick!ident@host" ; return }
   if {(![info exists spamban_masks]) || ([llength $spamban_masks] == 0)} { set spamban_masks $arg } else { lappend spamban_masks $arg }
   if {(![info exists nameban_masks]) || ([llength $nameban_masks] == 0)} { set nameban_masks $arg } else { lappend nameban_masks $arg }
   putdcc $idx "New spamban mask '$banmask' and nameban mask '$namemask' added." ; return
}
bind dcc n|- +spamban add_spammask
