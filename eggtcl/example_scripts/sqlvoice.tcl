###########################################################
# example eggdrop tcl for channel voice from mysql dbase  #
# leprechau@Efnet                                         #
###########################################################
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

### mysql settings ###

set mysql(host) "localhost"
# hostname of the mysql server
set mysql(dbase) "database"
# name of the mysql dbase
set mysql(user) "mysqluser"
# name of the mysql user
set mysql(pass) "password"
# password for the mysql user
set mysql(fbsql) "/home/yourlogin/fbsql/fbsql.so"
# path to the fbsql.so tcl mysql api

### other settings ###
set sqlvoice(channels) "#channelA #channelB #channelC"
# channels that script should check nicks on join
set sqlvoice(case) "1"
# should we be case sensitive (1 = yes | 0 = no)
set sqlvoice(greetings) {
	{Welcome $name, you have seat number $seat, there are $count other people registered.}
	{Sup $name, your p0w4h-seat is no. $seat, and you have $count n00bz to 0wn.}
}
# greetings for your users, a random message will be shown on join
# '$name' (users real name) '$seat' (users seat) and '$count' (total users)


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

# okie...here it is, the actual voice on join proc
proc do:voice { nick uhost hand chan } {
global sqlvoice botnick
	set sqlcmd [sql:connect]
	if {$sqlvoice(case)} {
		foreach {name seat} [lindex [$sqlcmd "SELECT `Navn`, `Seat` FROM `Deltakere` WHERE binary `Nick` = '$nick'"] 0] {}
	} else {
		foreach {name seat} [lindex [$sqlcmd "SELECT `Navn`, `Seat` FROM `Deltakere` WHERE `Nick` = '$nick'"] 0] {}
	}
	set count [$sqlcmd "SELECT COUNT(*) FROM `Deltakere`"]; catch {$sqlcmd disconnect}
	if {((([info exists name]) && (![string equal {} $name])) && (([info exists seat]) && (![string equal {} $seat])))} {
		puthelp "PRIVMSG $chan :[subst [join [lindex $sqlvoice(greetings) [rand [expr [llength $sqlvoice(greetings)] -1]]]]]"
		puthelp "MODE $chan +v $nick"
	}
}
bind join - * do:voice
