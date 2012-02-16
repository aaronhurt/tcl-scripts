#################################################################################
##  Automated Crontab (taken from www.juzzycode.com modified by leprechau)
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
catch {set cronstat [exec crontab -l]}
if {![info exists cronstat] || $cronstat == ""} { putlog "\002NO CRONTAB SET\002" }
##if {[string match  *${botnet-nick}.botchk* $cronstat] == 1} { putlog "\002 BOT CRONTABBED\002" }
proc crontab { handle idx args } {
   global nick botnet-nick userfile chanfile
   set args [lindex $args 0]
   set botdir [pwd]
   set binary [lindex $args 0]
   set params [lrange $args 1 end]
   putlog "#$handle# crontab $binary $params"
   if {$binary == ""} {
      putdcc $idx "\002Usage:\002 .crontab  \[binary conf\]"
      putdcc $idx " "
      putdcc $idx "*** Current crontab status for ${botnet-nick}:"
      catch {set cronstat [exec crontab -l]}
      if {![info exists cronstat] || $cronstat == ""} { set cronstat "NO CRONTAB SET" }
      putdcc $idx "$cronstat"
      return
   }
   if {![file exists $binary]} { putdcc $idx "*** Eggdrop binary ($binary) not found" ; return }
   if {![file exists $params]} { putdcc $idx "*** Eggdrop config ($params) not found" }
   if {$botdir == ""} { putlog "Crontab setup error:  cannot determine current directory" ; return }
   if {[catch {set botchk [open "${botnet-nick}.botchk" w 0700]} open_error] != 0} {
      putlog "\[\002ERROR\002\] Unable to open botchk file:  $open_error"
      dccputchan 5 "\[\002ERROR\002\] Unable to open botchk file:  $open_error"
      catch {close $botchk}
      return
   }
   if {[catch {
      puts $botchk "#!/bin/sh"
      puts $botchk "dir=\"$botdir\""
      if {$params == ""} {
         puts $botchk "script=\"$binary\""
      } else {
         puts $botchk "script=\"$binary $params\""
      }
      puts $botchk "name=\"${botnet-nick}\""
      puts $botchk "userfile=\"${userfile}\""
      puts $botchk "chanfile=\"${chanfile}\""
      puts $botchk "PATH=.:\$PATH"
      puts $botchk "export PATH"
      puts $botchk "cd \$dir"
      puts $botchk "if test -s pid.\$name; then"
      puts $botchk "  pid=`cat pid.\$name`"
      puts $botchk "  if `kill -0 \$pid >/dev/null 2>&1`; then"
      puts $botchk "    exit 0"
      puts $botchk "  fi"
      puts $botchk "  echo \"\""
      puts $botchk "  echo \"Stale pid.\$name file (erasing)\""
      puts $botchk "  rm -f pid.\$name"
      puts $botchk "fi"
      puts $botchk "echo \"\""
      puts $botchk "echo \"Reloading...\""
      puts $botchk "echo \"\""
      puts $botchk "if test -s \$userfile; then"
      puts $botchk "  if test -s \$chanfile; then"
      puts $botchk "    \$script"
      puts $botchk "    exit 0"
      puts $botchk "  fi"
      puts $botchk "fi"
      puts $botchk "if test -s \$chanfile; then"
      puts $botchk "    false"
      puts $botchk "else"
      puts $botchk "  if test -s \$chanfile~new; then"
      puts $botchk "    echo \"Channelfile missing.  Using last saved channelfile...\""
      puts $botchk "    mv \$chanfile~new \$chanfile"
      puts $botchk "  fi"
      puts $botchk "fi"
      puts $botchk "if test -s \$userfile~new; then"
      puts $botchk "   echo \"Userfile missing.  Using last saved userfile...\""
      puts $botchk "   mv \$userfile~new \$userfile"
      puts $botchk "  \$script"
      puts $botchk "  exit 0"
      puts $botchk "fi"
      puts $botchk "if test -s \$userfile~bak; then"
      puts $botchk "   echo \"Userfile missing.  Using backup userfile...\""
      puts $botchk "   cp \$userfile~bak \$userfile"
      puts $botchk "  \$script"
      puts $botchk "  exit 0"
      puts $botchk "fi"
      puts $botchk "echo \"Could not reload.\""
      puts $botchk "exit 0"
   } write_error] != 0} {
      putlog "ERROR Unable to write relaunch info to botchk file:  $write_error"
      dccputchan 5 "ERROR Unable to write relaunch info to botchk file:  $write_error"
   }
   catch {close $botchk}
   if {[catch {set cron [open "${botnet-nick}.cron" w 0700]} open_error] != 0} {
      putlog "ERROR: Unable to open ${botnet-nick}.cron file:  $open_error"
      dccputchan 5 "ERROR: Unable to open ${botnet-nick}.cron file:  $open_error"
      catch {close $cron}
      return
   }
   if {[catch {
      puts $cron "3,8,13,18,23,28,33,38,43,48,53,58 * * * *   $botdir/${botnet-nick}.botchk > /dev/null 2>1&"
   } write_error] != 0} {
      putlog "ERROR: Unable to write crontab info to ${botnet-nick}.cron file:  $write_error"
      catch {close $cron}
      return
   }
   catch {close $cron}
   if {[catch {exec crontab -l} error] == 0} {
      putlog "Appending current crontab to end of new file."
      if {[catch {exec crontab -l >> ${botnet-nick}.cron} error] != 0} {
         putlog "ERROR: Unable to append old crontab:  $error"
         return
      }
   }
   if {[catch {exec crontab ${botnet-nick}.cron} error] != 0} {
      putlog "ERROR: Unable to complete crontab setup:  $error"
      return
   }
   if {[catch {exec rm ${botnet-nick}.cron} error] != 0} {
      putlog "ERROR: Unable to remove crontab setup file:  $error"
      return
   }
   catch {exec chmod -R 700 ../}
   putlog "*** Crontab setup for \002${botnet-nick}\002 completed."
}
bind dcc n crontab crontab
