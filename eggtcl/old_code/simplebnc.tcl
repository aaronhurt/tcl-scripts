##############################
# simplebnc.tcl              #
# by leprechau@EFnet         #
##############################
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##

## settings start here ##

# connect using the bnc (1=yes / 0=no)
set proxybot 1
# the password you use to connect to your bnc
set proxyPass "proxy_pass"
# the hostname of your bnc
set proxy { some.box.net:1080 }
# a list of vips to use with your bnc
set proxyVips { some.box.net someother.box.net }
# a list of real irc servers to connect to through your bnc
set realservers { irc.realserver.com irc.realserver2.com }

## end settings ## do not edit below here ## end settings ##

if {$proxybot == 1} {
   set servers $proxy
   proc notice_lepProxy {from keyword arg} {
      global group realservers proxyPass proxyVips
      if {(("$from" == "") && ("$keyword" == "NOTICE") && ("[lindex [split $arg] 0]" == "AUTH"))} {
         if {[string match "*You need to say /quote PASS <password>*" "$arg"]} {
            putlog "\[\002leprechau-BNC\002\] Sending \"PASS *****\" to BNC..."
            putserv "PASS $proxyPass"
            return 0
         }
         if {[string match "*Level two, lets connect to something real now*" "$arg"]} {
            if {(([info exists proxyVips]) && ([llength $proxyVips] >= 1))} {
               set vip "[lindex [split $proxyVips { }] [rand [llength [split $proxyVips { }]]]]"
               putlog "\[\002leprechau-BNC\002\] Sending \"VIP $vip\" to BNC..."
               putserv "VIP $vip"
            }
            set bncserver "[split [lindex [split $realservers { }] [rand [llength [split $realservers { }]]]] :]"
            set port "[lindex [lindex $bncserver 1] 0]"
            set server "[lindex $bncserver 0]"
            putlog "\[\002leprechau-BNC\002\] Sending \"CONN $server $port\" to BNC..."
            putserv "CONN $server $port"
            return 0
         }
      }
   }
   bind raw - NOTICE notice_lepProxy
}

putlog "Loaded simplebnc.tcl by leprechau@efnet!"