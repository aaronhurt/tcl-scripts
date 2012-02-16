############################
## search.tcl by          ##
## phrek@efnet &&         ## 
## leprechau@efnet        ##
set search_version "1.2"
############################

## Begin user settings ## 
# set this to the trigger to start a search
set cmd_ "!search"
# set this to the trigger to request a file
set get_cmd "!get"
# you must keep the trailing / here
set search_path "./nfo/"
# set this to an extension in wildcard format
set search_extension "*.nfo"
## End user settings ##

#######################################################
### BEGIN MAIN SCRIPT...DO NOT EDIT BELOW THIS LINE ###
#######################################################

set search_active 0

proc Search { nick userhost hand chan text } {
global search_path search_extension
   set text [lindex $text 0]
   set search_active "0"
   if {$search_active == 1} {
      putserv "PRIVMSG $nick :Another search is currently in progress.  Please try again in a few seconds" ; return
   }
   if {$text == ""} {
      putserv "PRIVMSG $nick :You did not enter a string for me to search for." ; return
   }
   set search_active  1
   putserv "PRIVMSG $nick :Beginning search for '$text'"
   set num_matches "0"
   set tmp_line ""
   set results ""
   set file ""
   foreach file [glob -nocomplain $search_path$search_extension] {
      set found_result "0"
      if {[catch {set tmp_file [open $file r]} open_error] != 0} {
         putlog "\[\002ERROR\002\] Could not open '$file' for reading:  $open_error" ; return
      }
      while {(![eof $tmp_file]) && ($found_result != 1)} {
         gets $tmp_file tmpline
         if {[string match -nocase *$text* $tmpline]} {
            set found_result 1
	    incr num_matches
            lappend results [string range $file [string length $search_path] end]
         }
      }
      if {[catch {close $tmp_file} close_error] != 0} {
         putlog "\[\002ERROR\002\] Error closing file '$tmp_file':  $close_error" ; return
      }
   }
   if {$num_matches == 0} {
      puthelp "PRIVMSG $nick :Your search for '$text' returned 0 results"
   } else {
      puthelp "PRIVMSG $nick :Your search for '$text' returned $num_matches results:"
      foreach 1result $results { puthelp "PRIVMSG $nick :$1result" }
      puthelp "PRIVMSG $nick :--------------"
      puthelp "PRIVMSG $nick :End of Results"
      puthelp "PRIVMSG $nick : "
      puthelp "PRIVMSG $nick :To request a file, msg me '!get complete.exact.filename.nfo' or simply type it in the query window."
   }
}
bind pub - $cmd_ Search

proc md5sum {input} {
   if {[catch {exec md5sum} error] != 0} {
      return [lindex [exec md5 $input] 3]
   } else { return [lindex [exec md5sum $input] 0] }
}

proc Search_send { nick uhost handle text } {
global search_path search_extension
   set file [lindex $text 0]
   if {[string match *transfer* [modules]] == 0} {
      puthelp "PRIVMSG $nick :Sorry, but I am unable to send your file at this time."
      puthelp "PRIVMSG $nick :To correct this problem, please contact the owner of this bot and tell them to load the transfer module."
      return
   }
   if {![file exists $search_path$file]} {
      puthelp "PRIVMSG $nick :Sorry, but I am unable to find that file, please check your spelling and that you have used the correct case."
      return
   }
   puthelp "PRIVMSG $nick :Sending '$file' - [file size $search_path$file] bytes / md5sum = [md5sum $search_path$file]."
   dccsend $search_path$file $nick
}
bind msg - $get_cmd Search_send

putlog "Search.tcl v$search_version by phrek@efnet and leprechau@efnet Loaded"