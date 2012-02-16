## fbsql helper script
## no documentation or support other than provided herein
##
## commands:
##
## ::fbsql::connect <host> <user> <pass> <dbname>
## ^-- returns current fbsql session handle
##
## ::fbsql::disconnect <handle>
## ^-- disconnects given fbsql handle and marks it free
##
## ::fbsql::addslashes <text>
## ^-- escape characters that may cause problems in mysql queries
##
## that's it....just one setting below
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

namespace eval ::fbsql {

	## settings ##
	variable api "/usr/local/lib/fbsql.so"
	## end settings ##
	
	## export our commands
	namespace export connect addslashes
	## initialize our state array..all info stored here
	if {![info exists State] || ![array size State]} {
		variable State; for {set x 0} {$x <= 10} {incr x} {array set State [list $x 0]}
	}

	## lets load fbsql tcl mysql api if it is not already loaded
	if {![string match *sql* [info commands]]} {catch {load $::fbsql::api}}

	## handle db connections using fbsql sessions
	proc connect {host user pass name} {
		# take advantage of the sessions ability of fbsql
		foreach session [lsort -integer -increasing [array names ::fbsql::State]] {
			## take the first free session...if it's 1..lets move to the next
			if {$::fbsql::State($session)} {continue}
			## well we didn't continue...so let's take this one
			if {$session == 0} {set sqlcmd sql} else {set sqlcmd sql$session}; break
		}
		## make sure we got a sqlcmd set...if not we have used all of our sessions!!
		if {![info exists sqlcmd]} {return -code error "Error: all fbsql sessions in use..."}
		## otherwise..let's go on
		if {[catch {$sqlcmd connect $host $user $pass} cError] != 0} {
			return -code error "Error: handle '$sqlcmd' could not connect to $user@$host: $cError"
		} elseif {[catch {$sqlcmd selectdb $name} sError] != 0} {
			catch {$sqlcmd disconnect}; return -code error "Error: handle '$sqlcmd' cound not select database '$name': $sError"
		}
		array set ::fbsql::State [list $session 1]; return $sqlcmd
	}
	
	## handle database disconnects and free the session
	proc disconnect {handle} {
		## disconnect the handle...
		if {[catch {$handle disconnect} cError] != 0} {
			return -code error "Error: handle '$handle' failed to disconnect: $cError"
		}
		## well that went smooth...let's free it in our state array
		array set ::fbsql::State [list [string trim $handle sql] 0]; return 0
	}

	## escape out any characters that may cause problems
	proc addslashes {text} {string map {\\ \\\\ \| \\| \[ \\[  \] \\] \{ \\{ \} \\} $ \\$ \` \\` \' \\' \" \\"} $text}
}

## EOF ##
