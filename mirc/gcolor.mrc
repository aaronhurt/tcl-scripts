;; gay color alias
;;
;; NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
;; this is the only official location for any of my scripts
;;

; /gcolor #lines #times/line what to say
alias gcolor {
  var %l = $1
  var %r = $2
  var %t = $3-
  var %k = $chr(3)
  var %text = $null
  var %lines = 1
  var %repeat = 1
  while (%lines <= %l) {
    while (%repeat <= %r) {
      var %text = %k $+ $rand(1,15) $+ , $+ $rand(1,15) $+ %t $+ %text
      inc %repeat
    }
    say %text
    var %text = $null
    var %repeat = 1
    inc %lines
  }
}