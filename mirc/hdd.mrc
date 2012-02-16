;; hdd.mrc
;; by leprechau@EFnet
;;
;; NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
;; this is the only official location for any of my scripts
;;
alias cfp2 { if ($1- != $null) { return $chr(2) $+ $chr(3) $+ 02 $+ ( $+ $chr(3) $+ $chr(2) $+ $1- $+ $chr(2) $+ $chr(3) $+ 02 $+ ) $+ $chr(3) $+ $chr(2) } }
alias cfb2 { if ($1- != $null) { return $chr(2) $+ $chr(3) $+ 02 $+ $chr(91) $+ $chr(3) $+ $chr(2) $+ $1- $+ $chr(2) $+ $chr(3) $+ 02 $+ $chr(93) $+ $chr(3) $+ $chr(2) } }

alias getsize { if ($1 < 1024) return $1 $+ b
  elseif (($1 > 1024) && ($1 < 1048576)) return $round($calc($1 / 1024),1) $+ k
  elseif (($1 < 1073741824)) return $round($calc($1 / 1048576),2) $+ mb
  else return $round($calc($1 / 1073741824),2) $+ gb
}

alias getratio {
  return $round($calc(($disk($1).free / $disk($1).size) * 100),2) $+ %
}

alias getdiskspace {
  .unset %c | set %c $null
  .unset %num [ $+ [ $1 ] $+ ] disks | set %num [ $+ [ $1 ] $+ ] disks 0
  var %alphabet = A.B.C.D.E.F.G.H.I.J.K.L.M.N.O.P.Q.R.S.T.U.V.W.X.Y.Z
  var %i = 1
  while (%i <= 26) {
    var %disk = $gettok(%alphabet,%i,46)
    if ($disk(%disk).type == $1) { inc %num [ $+ [ $1 ] $+ ] disks | set %c %c $+ $chr(32) $+ $chr(3) $+ 14 $+ %disk $+ $chr(58) $+ $chr(32) $+ Total $+ $chr(3) $+ $cfp2($getsize($disk(%disk).size)) $+ $chr(32) $+ $chr(3) $+ 14 $+ Free $+ $chr(3) $+ $cfp2( $getsize($disk(%disk).free) ) $+ $chr(32) $+ $cfb2( $getratio(%disk) ) $+ ! }
    inc %i
  }
  return %c
}

alias getdisktotal {
  .unset %c | set %c 0
  var %alphabet = A.B.C.D.E.F.G.H.I.J.K.L.M.N.O.P.Q.R.S.T.U.V.W.X.Y.Z
  var %i = 1
  while (%i <= 26) {
    var %disk = $gettok(%alphabet,%i,46)
    if ($disk(%disk).type == $1) { set %c $calc($disk(%disk).size + %c) }
    inc %i
  }
  return %c
}

alias getdisktotalspace {
  .unset %c | set %c 0
  var %alphabet = A.B.C.D.E.F.G.H.I.J.K.L.M.N.O.P.Q.R.S.T.U.V.W.X.Y.Z
  var %i = 1
  while (%i <= 26) {
    var %disk = $gettok(%alphabet,%i,46)
    if ($disk(%disk).type == $1) { set %c $calc($disk(%disk).free + %c) }
    inc %i
  }
  return %c
}

alias splitstring {
  var %i = 1
  while ($gettok($2-,%i,33) != $null) {
    msg $1 $gettok($2-,%i,33)
    inc %i
  }
}

alias hdd {
  say $cfp2($chr(32) $+ $me $+ $chr(39) $+ s $+ $chr(32) $+ Free $+ $chr(32) $+ Disk $+ $chr(32) $+ Space $+ $chr(32))
  say $cfb2(Local $+ $chr(32) $+ Disks)
  $splitstring($active,$getdiskspace(fixed))
  var %remotespace = $getdiskspace(remote)
  if (%remotespace != $null) {
     say $cfb2(Remote $+ $chr(32) $+ Disks)
     $splitstring($active,%remotespace)
  }
  if ((%numfixeddisks >= 2) && (%numremotedisks >= 1)) {
     say $chr(3) $+ 03 $+ Fixed $+ $chr(32) $+ Total $+ $chr(3) $+ $cfp2($getsize($getdisktotal(fixed))) $+ $chr(32) $+ $chr(3) $+ 03 $+ Free $+ $chr(3) $+ $cfp2($getsize($getdisktotalspace(fixed))) $+ $chr(32) $+ $cfb2($round($calc(($getdisktotalspace(fixed) / $getdisktotal(fixed)) * 100),2) $+ %)
  }
  if ((%numremotedisks >= 2) && (%numfixeddisks >= 1)) {
     say $chr(3) $+ 03 $+ Remote $+ $chr(32) $+ Total $+ $chr(3) $+ $cfp2($getsize($getdisktotal(remote))) $+ $chr(32) $+ $chr(3) $+ 03 $+ Free $+ $chr(3) $+ $cfp2($getsize($getdisktotalspace(remote))) $+ $chr(32) $+ $cfb2($round($calc(($getdisktotalspace(remote) / $getdisktotal(remote)) * 100),2) $+ %)
  }
  say $chr(3) $+ 07 $+ Total $+ $chr(3) $+ $cfp2($getsize($calc($getdisktotal(fixed) + $getdisktotal(remote)))) $+ $chr(32) $+ $chr(3) $+ 07 $+ Free $+ $chr(3) $+ $cfp2($getsize($calc($getdisktotalspace(fixed) + $getdisktotalspace(remote)))) $+ $chr(32) $+ $cfb2($round($calc((($getdisktotalspace(fixed) + $getdisktotalspace(remote)) / ($getdisktotal(fixed) + $getdisktotal(remote))) * 100),2) $+ %)
}
