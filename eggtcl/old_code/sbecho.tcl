#######################
# site bot echo v 1.4 #
# by leprechau@EFnet  #
#######################
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

set sbecho(bothost) "*!*@*"
# sitebot host you want to monitor

set sbecho(from) "#bahhzer"
# source sitebots channel

set sbecho(to) ""
# channel you are relaying to

set sbecho(db) "/blah/blah/blah.txt"
# full path and filename for dupecheck db

set sbecho(trig) ""
# pub trigger used to trigger dupecheck

set sbecho(trigon) ""
# channels on which you can use pub dupecheck

# wildcard strings that the bot will echo/log
set sbecho(matches) {
 *PRE*
}

# wildcard strings that the bot will ignore
set sbecho(ignores) {
 *NUKE*
 *PRED*
}

## begin script ## do not edit ## begin script ##

proc sindex { string index } { return [lindex [split [string trim $string] " "] $index] }
proc srange { string start end } { return [join [lrange [split [string trim $string] " "] $start $end]] }

proc stripall { text } {
   regsub -all -- {\003[0-9]{0,2}(,[0-9]{0,2})?|\017|\037|\002|\026} $text {} stripped
   return $stripped
}

## logging proc
proc sbecho_log { text } {
global sbecho
   if {$text == ""} { return }
   if {[catch {set file [open $sbecho(db) a 0600]} open_error] != 0} {
      putlog "\[\002ERROR\002\] Could not open dupe db for writing: $open_error" ; return
   }
   if { [catch { puts $file "$text" } write_error] != 0} {
      putlog "\[\002ERROR\002\] Could not write to dupe db file: $write_error"
   }
   if {[catch {close $file} close_error] != 0} {
      putlog "\[\002ERROR\002\] Error closing dupe db file:  $close_error"
   }
}

## monitor proc
proc sbecho_watch { nick uhost hand chan text } {
global sbecho
   if {![string match -nocase "$sbecho(bothost)" "[sindex ${nick}!${uhost} 0]"]} { return }
   if {![string match -nocase "$sbecho(from)" "[sindex $chan 0]"]} { return }
   set text [stripall $text]
   foreach 1match "$sbecho(matches)" {
      if {[string match "$1match" "$text"]} {
         set foundignore 0
         foreach 1ignore "$sbecho(ignores)" {
            if {[string match "$1ignore" "$text"]} { set foundignore 1 }
         }
         if {$foundignore == 0} {
            set index [lsearch [split $text] "*.*-*"]
            if {$index == -1} {
               set index [lsearch [split $text] "*_*-*"]
            }
            if {$index == -1} {
               return
            } else {
               regsub -all -- {\[|\]} [sindex $text $index] {} output
               if {[string equal {} $output]} { return }
               append output " @ [ctime [unixtime]]"
               sbecho_log "$output"
            }
         } else { return }
      }
   }
}
bind pubm - * sbecho_watch

## convert seconds to boolean time
proc sbecho_gettime { seconds } {
  set minutes ""
  set hours ""
  set days ""
  set weeks ""
  set years ""
  if {$seconds >= 31536000} {
    set years "[expr $seconds / 31536000]"
    set seconds "[expr $seconds - [expr 31536000 * $years]]"
  }
  if {$seconds >= 604800} {
    set weeks "[expr $seconds / 604800]"
    set seconds "[expr $seconds - [expr 604800 * $weeks]]"
  }
  if {$seconds >= 86400} {
    set days "[expr $seconds / 86400]"
    set seconds "[expr $seconds - [expr 86400 * $days]]"
  }
  if {$seconds >= 3600} {
    set hours "[expr $seconds / 3600]"
    set seconds "[expr $seconds - [expr 3600 * $hours]]"
  }
  if {$seconds >= 60} {
    set minutes "[expr $seconds / 60]"
    set seconds "[expr $seconds - [expr 60 * $minutes]]"
  }
  set returns ""
  if {$years != ""} {append returns "$years years, "}
  if {$weeks != ""} {append returns "$weeks weeks, "}
  if {$days != ""} {append returns "$days days, "}
  if {$hours != ""} {append returns "$hours hours, "}
  if {$minutes != ""} {append returns "$minutes minutes, "}
  if {$seconds > 0} {append returns "$seconds seconds"}
  return $returns
}

## pub dupecheck
proc sbecho_dupecheck { nick uhost hand chan text } {
global sbecho
   set text [sindex $text 0]
   if {($text == "") || (![string match -nocase "*$chan*" "$sbecho(trigon)"])} { return }
   if {[catch {set file [open $sbecho(db) r]} open_error] != 0} {
      putlog "\[\002ERROR\002\] Could not open dupe db for reading: $open_error" ; return
   }
   set foundmatch 0
   while {(![eof $file]) && ($foundmatch == 0)} {
      gets $file line
      if {$line != ""} {
         if {[string match -nocase [sindex "$line" 0] $text]} {
            set foundmatch 1
            set elapsed "[sbecho_gettime [expr [unixtime] - [clock scan [srange $line 2 end]]]] ago"
            putserv "PRIVMSG $chan :[sindex $line 0] Released: $elapsed"
         }
      }
   }
}
bind pub - $sbecho(trig) sbecho_dupecheck

putlog "Loaded: sbecho.tcl v1.4 by leprechau@EFnet!"
#EOF
 
