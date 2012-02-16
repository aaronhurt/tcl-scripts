proc ip2long {ip} {
   foreach {a b c d} [split $ip .] {}
   set long [expr {$a * pow(256,3)} + {$b * pow(256,2)} + {$c * 256} + $d]
   return [format %0.f $long]
}

proc long2ip {long} {
   for {set i 3} {$i > 0} {incr i -1} {
      set num [expr {int($long / pow(256,$i))}]
      set long [expr {int($long - ($num * pow(256,$i)))}]
      lappend ip $num
      if {$i == 1} { lappend ip $long }
   }
   return [join $ip .]
}
