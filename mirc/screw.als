screw {
  if ($1 !ison $chan) { echo 4 -a Error, $1 not on current channel. | halt }
  var %host = $address($1,5)
  var %len = $len(%host)
  var %i = 1
  var %odd = 1
  var %ban = $null
  while (%i <= %len) {
    var %mid = $mid(%host,%i,1)
    if ((%mid == $chr(64)) || (%mid == $chr(33))) {
      var %ban = %ban $+ %mid
    }
    elseif (%odd == 1) {
      var %ban = %ban $+ %mid
      var %odd = 0
    }
    elseif (%odd == 0) {
      var %ban = %ban $+ $chr(63)
      var %odd = 1
    }
    inc %i
  }
  mode $chan +b %ban
}
