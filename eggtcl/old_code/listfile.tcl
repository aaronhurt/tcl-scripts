###########################################
#   Listfile.tcl by leprechau@efnet       #
###########################################
#       Script Usage: <trigger> filename  #
###########################################
#       Listfile Script Settings          #
###########################################

## set this to the path of your files
set tpath "text/"
## set this to the character(s) you wish to trigger the script
set trigger "!list"
## set this to the common file extension of your files "" for no extension
set extension ".txt"
## valid options: "notice" or "privmsg"
set dtype "notice"
## maximum number of lines to display before halting
set maxlines 20
## log errors of nonexistent files, etc (1 = yes 0 = no)
set logerrors 1
## restrict access to channel ops/voices only (1 = yes 0 = no)
set restrict 1		

### DO NOT EDIT BELOW HERE ########## BEGIN MAIN SCRIPT ### DO NOT EDIT BELOW HERE ########
set lfver "1.2"
proc listfile {nick uhost hand chan args} {
global tpath extension dtype maxlines logerrors restrict
putcmdlog "#$nick# listfile"
set args [lindex $args 0]
set dtype [string toupper $dtype]
set listfile [string tolower [lindex $args 0]]

if {$restrict != 0} {
  if {![isop $nick $chan] && ![isvoice $nick $chan]} {
    puthelp "$dtype $nick :No you can't do that thing when you ain't got that swing!"
    puthelp "$dtype $nick :Command only available to +o users and channel ops." ; return
  }
}

if {![file isfile $tpath$listfile$extension]} {
   if {$logerrors != 0} {
     putlog "\[\002ERROR\002\] File '$tpath$listfile$extension' does not exist!" ; return
   } else {return}
}
if {[catch {set file [open $tpath$listfile$extension r]} open_error] != 0} {
   if {$logerrors != 0} {
     putlog "\[\002ERROR\002\] Could not open '$tpath$listfile$extension' for reading:  $open_error" ; return
   } else {return}
}
puthelp "$dtype $nick :\[\002 Current Contents: '$listfile$extension' \002\]"
set linecounter 0
set success 1
while {![eof $file]} {
   gets $file line
   if {$linecounter >= $maxlines} {
     if {[catch {close $file} close_error] != 0} {
       set success 0
       if {$logerrors != 0} {
         putlog "\[\002ERROR\002\] Error closing file :  $close_error"
       } else {return}
     }
     puthelp "$dtype $nick :File exceeds maximum length set by bot owner, list stopped."
     puthelp "$dtype $nick :\[\002$linecounter\002\] lines displayed."
     return $success
   }
   if {$line != ""} { puthelp "$dtype $nick :[string range $line 0 end]" }
   incr linecounter
}
if {[catch {close $file} close_error] != 0} {
   set success 0
   if {$logerrors != 0} {
     putlog "\[\002ERROR\002\] Error closing file :  $close_error"
   } else {return}
}
puthelp "$dtype $nick :\[\002EOF\002\] $linecounter lines displayed."
return $success
}
bind pub - $trigger listfile

putlog "Loaded listfile.tcl v$lfver by leprechau@efnet!"
