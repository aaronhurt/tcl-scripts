##########################
# ezbnc.tcl by leprechau #
##########################
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

## settings start here ##

# connect using the bnc (1=yes / 0=no)
set proxybot 1

# the username you use to connect to your bnc
set proxyUser "username"

# the password you use to connect to your bnc
set proxyPass "proxy_pass"

# the hostname of your bnc
set proxy { some.box.net:15580 }

# a list of vhosts to use with your bnc (one will be chosen at random)
set proxyVhosts {
   some.box.net
   someother.box.net
}

# a list of real irc servers to connect to through your bnc
# you MUST specify both servername and port
# you may also use ssl servers if your ezbounce supports it
# see examples below
set realservers {
   irc.realserver.com:6667
   irc.realserver2.com:6667
   ssl:irc.sslserver.com:7000
}

############################################################
## end settings ## do not edit below here ## end settings ##
############################################################

if {$proxybot == 1} {
   set servers $proxy
   proc notice_lepProxy {from keyword text} {
      global realservers proxyUser proxyPass proxyVhosts
      if {(([string match "(ezbounce)!srv" "$from"]) && ([string match "NOTICE" "$keyword"]))} {
         if {[string match "*awaiting login/pass command*" "$text"]} {
            putlog "\[\002lep-EzBNC\002\] Sending \"LOGIN $proxyUser ******\" to BNC..."
            putserv "LOGIN $proxyUser $proxyPass"
            return 0
         }
         if {[string match "*use /quote CONN*" "$text"]} {
            if {(([info exists proxyVhosts]) && ([llength $proxyVhosts] >= 1))} {
               set vhost "[lindex $proxyVhosts [rand [llength $proxyVhosts]]]"
               putlog "\[\002lep-EzBNC\002\] Sending \"VHOST $vhost\" to BNC..."
               putserv "VHOST $vhost"
            }
            set bncserver "[split [lindex $realservers [rand [llength $realservers]]] :]"
            if {[string match "ssl" [lindex $bncserver 0]]} {
               set using_ssl "1"
               set server "[lindex $bncserver 1]"
               set port "[lindex $bncserver 2]"
            } else {
               set using_ssl "0"
               set server "[lindex $bncserver 0]"
               set port "[lindex $bncserver 2]"
            }
            if {$using_ssl == 1} {
               putlog "\[\002lep-EzBNC\002\] Sending \"CONN -ssl $server $port\"..."
               putserv "CONN -ssl $server $port"
               return 0
            } else {
               putlog "\[\002lep-EzBNC\002\] Sending \"CONN $server  $port\"..."
               putserv "CONN $server $port"
               return 0
            }
         }
         if {[string match "*onnection attempt*failed*" "$text"]} {
            putlog "\002\lep-EzBNC\002\] [string range $text [expr [string first : $text] +1] end]"
            return 0
         }
         if {[string match "*ow connected to*" "$text"]} {
            putlog "\002\lep-EzBNC\002\] [string range $text [expr [string first : $text] +1] end]"
            return 0
         }
      }
   }
}
bind raw - NOTICE notice_lepProxy

putlog "Loaded ezbnc.tcl by leprechau@efnet!"

#EOF