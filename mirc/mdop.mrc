; my raw mode massdeop
mdop {
  if ($me !isop $chan) { echo 4 -a Error, you are not opped. | halt }
  var %total = $opnick($chan,0)
  var %deolist = $null
  var %deopline = $null
  var %skiplist = lepster ch4rlie frank1in l1nus lvcy marcie pig_pen schroeder woodstock animals
  ;;var %skiplist = $null
  var %i = 1
  while (%i <= %total) {
    var %deonick = $opnick($chan,%i)
    if ((%deonick isop $chan) && (%deonick != $me) && (%deonick !isin %skiplist)) {
      if (%deolist == $null) {
        var %deolist = %deonick
      }
      else {
        var %deolist = %deolist %deonick
      }  
    }
    inc %i
  }
  var %i = 1
  var %nummode = $numtok(%deolist,32)
  while (%i <= %nummode) {
    if ($calc($numtok(%deolist,32) - %i) >= 4) {
      var %deopline = %deopline mode $chan -oooo $gettok(%deolist,%i - $calc(%i + 3),32) $cr
      inc %i 4
    }
    else {
      var %deopline = %deopline mode $chan - $+ $str(o,$numtok($gettok(%deolist,%i -,32),32)) $gettok(%deolist,%i -,32)
      inc %i $numtok($gettok(%deolist,%i -,32),32)
    }
  }
  if (%deopline != $null) {
    raw %deopline
  }
  else { echo 4 -a Error, no nicks found to deop. | halt } 
}
