## hexillion ip locator script
## fetch whois information from hexillion.com via xml
## no documentation or support other than provided herein
## 
## by leprechau@EFnet
##
## channel settings: .chanset #chan +/-whois
## ^-- toggle public commands per channel
##
## public commands: !whois <ip|host>
##
## NOTE: This script uses my http package
## http://woodstock.anbcs.com/scripts/tcl/lephttp.tcl
## download and source before this script
##
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::hexillion {
	
	## begin settings ##

	variable messagetarget "chan";
	## target for messages on pub commands (nick or chan)

	## end settings ##
	variable version 0.1

	## get my http package from
	## http://woodstock.anbcs.com/scripts/tcl/lephttp.tcl
	package require lephttp
	
	## defines
	setudef flag whois

	## our callback handler
	proc callback {lhost target token} {
		## error/sanity checks...
		if {[catch {::lephttp::status $token} status] != 0} {return}
		## uhhh ohhh...did something go wrong? ... let them know if it did
		if {![string equal -nocase {OK} $status]} {
			switch -exact -- [string tolower $status] {
				timeout {
					putlog "\[\002HEXILLION\002\] Timeout (60 seconds) on connection to server."
					putserv "PRIVMSG $target :\[\002ERROR\002\] Timeout (60 seconds) on connection to server."
				}
				"not found" {
					putserv "PRIVMSG $target :Sorry, nothing found for: $lhost"
				}
				default {
					putlog "\[\002HEXILLION\002\] Unknown error occured, server output of the error is as follows: $status"
					putserv "PRIVMSG $target :\[\002ERROR\002\] Unknown error occured."
				}
			}
			## we had an error...cleanup our token and get out of here...
			::lephttp::cleanup $token; return
		}
		## get our output and cleanup our token and cut out some crap...
		set outs [lindex [regexp -inline -- {<QueryResult>(.+?)</QueryResult>} [::lephttp::data $token]] end]; ::lephttp::cleanup $token
		## was the lookup okay?
		if {![string equal {Success} [lindex [regexp -inline -- {<ErrorCode>(.+?)</ErrorCode>} $outs] end]] || \
		![string equal {Yes} [lindex [regexp -inline -- {<FoundMatch>(.+?)</FoundMatch>} $outs] end]]} {
			putserv "PRIVMSG $target :\002HEXILLION:\002 Sorry we are unable to process $lhost at this time."; return
		}
		## this is ugly but we have to do it so we don't get any errors with missing information below
		foreach key {querystring servername name,regt address,regt city,regt stateprovince,regt postalcode,regt countrycode,regt \
		name,net name,dom createddate,net createddate,dom updateddate,net updateddate,dom expiresdate,dom email,tcon email,abcon email,ncon \
		name,regr email,adcon email,zcon} {array set temps [list $key N/A]}
		## start our parsing loop...
		foreach line [split $outs \n] {
			## skip blank lines....
			if {![string length [set line [string trim $line]]]} {continue}
			## some of our xml tags are re-used in different sections...let's make them unique
			## also break when we hit HeaderText...nothing else we need after that
			if {![info exists sect]} {set sect {}}; switch -exact -- $line {
				<Registrant> {set sect regt}
				</Registrant> {set sect {}}
				<Registrar> {set sect regr}
				</Registrar> {set sect {}}
				<Network> {set sect net}
				</Network> {set sect {}}
				<Domain> {set sect dom}
				</Domain> {set sect {}}
				<TechContact> {set sect tcon}
				</TechContact> {set sect {}}
				<AbuseContact> {set sect abcon}
				</AbuseContact> {set sect {}}
				<NOCContact> {set sect ncon}
				</NOCContact> {set sect {}}
				<ZoneContact> {set sect zcon}
				</ZoneContact> {set sect {}}
				<AdminContact> {set sect adcon}
				</AdminConcact> {set sect {}}
				<HeaderText> {break}
			}
			## get our data from our tags...
			foreach {x stag data etag} [regexp -all -inline -- {<(.+?)>(.+?)</(.+?)>} $line] {}
			## we don't want any empty strings
			if {![info exists data] || ![string length $data]} {continue}
			## build our temp array..special case for 'nameserver' ...
			if {[string equal -nocase nameserver $stag]} {
				lappend temps([string tolower [join "$stag $sect" {,}]]) $data
			} else {array set temps [list [string tolower [join "$stag $sect" {,}]] $data]}
		}
		## change output based on lhost...
		if {[regexp -- {^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$} $lhost]} {
			puthelp "PRIVMSG $target :\002$temps(querystring)\002: Registrant: $temps(name,regt) \
			~ Address: $temps(address,regt), $temps(city,regt), $temps(stateprovince,regt) $temps(postalcode,regt) $temps(countrycode,regt) \
			~ Network: $temps(name,net) ~ CIDR $temps(cidr,net) ~ Range: $temps(iprange,net) ~ Status: $temps(status,net) \
			~ Created: $temps(createddate,net) ~ Tech Contact: $temps(email,tcon) \
			~ Abuse Contact: $temps(email,abcon) ~ NOC Contact: $temps(email,ncon)"
		} else {
			puthelp "PRIVMSG $target :\002$temps(querystring)\002: Registrant: $temps(name,regt) \
			~ Address: $temps(address,regt), $temps(city,regt), $temps(stateprovince,regt) $temps(postalcode,regt) $temps(countrycode,regt) \
			~ Domain: $temps(name,dom) ~ Created: $temps(createddate,dom) ~ Expires: $temps(expiresdate,dom) \
			~ Registrar: $temps(name,regr) ~ Nameserver(s) [join [lsort -unique $temps(nameserver,dom)] {, }] \
			~ Admin Contact: $temps(email,adcon) ~ Tech Contact: $temps(email,tcon) ~ Zone Contact: $temps(email,zcon)"
		}
	}

	## public commands handler
	proc pubCmds {nick uhost hand chan text} {
		## check our channel definition
		if {![channel get $chan whois]} {return}
		## make sure we actually got an argument
		if {![string length $text]} {
			putserv "PRIVMSG $chan :\[\002$nick\002\] Usage: $::lastbind <ip|host|nick>"; return
		}
		## are we sending this to the channel or a person?
		switch -exact -- $::hexillion::messagetarget {
			nick {set target $nick}
			chan {set target $chan}
			default {putlog "\[\002HEXILLION\002\] Error, unknown messagetarget specified in script!"; return}
		}
		## set/format our host argument
		set lhost [::lephttp::encode [string trim [lindex [split $text] 0]]]
		## do the fetch...
		::lephttp::fetch http://hexillion.com/samples/WhoisXML/?query=${lhost} \
		-command [list ::hexillion::callback $lhost $target] -timeout 30000
	}
	## bind away...
	bind pub - !whois ::hexillion::pubCmds
}
##package provide hexillion $::hexillion::version

putlog "hexillion.tcl v$::hexillion::version by leprechau@EFNet loaded!"
