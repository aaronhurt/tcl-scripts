###########################################################
# example eggdrop tcl for channel invite from mysql dbase #
# leprechau@Efnet 07.25.2003                              #
###########################################################
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

### mysql settings ###

set mysql(host) "localhost"
# hostname of the mysql server
set mysql(dbase) "phpbb"
# name of the mysql dbase
set mysql(user) "phpbb"
# name of the mysql user
set mysql(pass) "password"
# password for the mysql user
set mysql(fbsql) "/home/blahh/fbsql/fbsql.so"
# path to the fbsql.so tcl mysql api

### other settings ###

set invite(cmd) "!invite"
# message command to use
set invite(chan) "#testing123"
# channel to invite to

### end settings ###

# lets load fbsql tcl mysql api if it is not already loaded
if {![string match *sql* [info commands]]} { catch {load $mysql(fbsql)} }

# lets initialize our sqlsessions (see next proc for how sessions are managed)
if {(![info exists sqlsession]) || ($sqlsession > 10)} { set sqlsession 0 }

# now, lets make a nice proc to take advantage of the fbsql sessions
proc sql:connect {} {
global mysql sqlsession
   if {($sqlsession == 0) || ($sqlsession > 10)} {
      set sqlsession 0 ; set sqlcmd "sql"
   } else { set sqlcmd "sql$sqlsession" }
   if {[catch {$sqlcmd connect $mysql(host) $mysql(user) $mysql(pass)} connect_error] != 0} {
      if {[string match {*already connected*} "$connect_error"]} {
         catch {$sqlcmd disconnect} ; sql:connect
      } else {
         putlog "\[\002ERROR\002\] Could not connect do database: $connect_error"
         catch {$sqlcmd disconnect} ; return
      }
   }
   if {[catch {$sqlcmd selectdb $mysql(dbase)} select_error] != 0} {
      putlog "\[\002ERROR\002\] Count not select database: $select_error"
      catch {$sqlcmd disconnect} ; return
   }
   incr sqlsession
   return "$sqlcmd"
}

# okie...here it is, the actual invite proc
proc do:invite { nick uhost hand text } {
global invite botnick
   if {[llength [split $text]] != 2} {
      putserv "PRIVMSG $nick :\[\002ERROR\002\] Syntax: /msg $botnick $invite(cmd) <username> <password>"
      return
   }
   set msguser [lindex [split $text] 0]
   set msgpass [lindex [split $text] 1]
   set sqlcmd [sql:connect]
   set dbuser [$sqlcmd "SELECT `username` FROM `phpbb_users` WHERE binary `username` = '$msguser'"]
   set dbpass [$sqlcmd "SELECT `user_password` FROM `phpbb_users` WHERE binary `username` = '$msguser'"]
   catch {$sqlcmd disconnect}
   if {(![string equal {} $dbuser]) && (![string equal {} $dbpass])} {
      if {[string equal [md5 $msgpass] $dbpass]} {
         putserv "PRIVMSG $invite(chan) :\[\002INVITE\002\] Inviting '$dbuser' with irc nick '$nick' to channel."
         putserv "INVITE $nick $invite(chan)"
      } else {
         putserv "PRIVMSG $invite(chan) :\[\002INVITE FAILED\002\] IRC nick '$nick' attempted to invite as board user '$dbuser' and failed!"
         putserv "PRIVMSG $nick :\[\002ERROR\002\] Sorry, invalid username or password, please try again (attempt logged)"
         putserv "PRIVMSG $nick :\002*******\002 Remember, username and password are case sensitive."
         return
      }
   } else {
      putserv "PRIVMSG $nick :\[\002ERROR\002\] Sorry, invalid username or password, please try again (attempt logged)"
      putserv "PRIVMSG $nick :\002*******\002 Remember, username and password are case sensitive."
      return
   }
}
bind msg - $invite(cmd) do:invite