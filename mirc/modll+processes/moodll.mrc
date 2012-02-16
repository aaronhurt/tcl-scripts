; moo.dll
; Procedures which make use of the dll follow, defined as aliases
; 
; [aliases]
; System Statistics
; 
; ::NOTE: should you wish, you can easily prevent the rambar from appearing by changing the line 
; "set %rb_size 10" to "set %rb_size 0"
;
; this uses juzzy's processes.dll as well as moo.dll
; script updated by leprechau@efnet
; removed lame colorcode chars in script and replaced with proper formatting alias
; enjoy...

on *:load:{
  ; this enables or disables color codes in output (1 for color/0 for no color)
  set %moo_use_color 1
  ; this is the color to use for text header and rambar (number 0-15)
  set %moo_color 2
}

on *:start:{
  timer.record_uptime 0 60 set_record_uptime
}

on *:unload:{
  timer.record_uptime off
}

alias moof {
  if ($1- != $null) {
    if (%moo_use_color == 1) {
      return $chr(3) $+ %moo_color $+ $1 $+ $chr(3) $+ $chr(31) $+ $chr(91) $+ $chr(31) $+ $2- $+ $chr(31) $+ $chr(93) $+ $chr(31)
    }
    else { return $1 $+ $chr(91) $+ $2- $+ $chr(93) }
  }
}

alias rambar {
  if ( %rb_size == 0 ) { return }
  set %rb_used $round($calc($dll(moo.dll,rambar,_) / 100 * %rb_size),0)
  set %rb_unused $round($calc(%rb_size - %rb_used),0)
  set %rb_usedstr $str(|,%rb_used)
  set %rb_unusedstr $str(-,%rb_unused)
  if (%moo_use_color == 1) {
     return $chr(160) $+ $chr(40) $+ $chr(3) $+ %moo_color $+ %rb_usedstr $+ $chr(3) $+ %rb_unusedstr $+ $chr(41)
  }
  else { return $chr(160) $+ $chr(40) $+ %rb_usedstr $+ %rb_unusedstr $+ $chr(41) }
}

alias get_record_uptime {
  set_record_uptime
  return %record_uptime
}

alias set_record_uptime {
  set %ticks $ticks
  if ((%record_uptime != $null) && (%ticks > %record_uptime)) {
    set %record_uptime %ticks
  }
  elseif (%record_uptime == $null) {
    set %record_uptime %ticks
  }
  else { continue }
}

alias moodll.error {
  echo -a $moof(moo.dll error,$1-)
}

alias moodll.getcmd {
  set %moodll.cmd $1-
  if (%moodll.cmd == $null) { set %moodll.cmd say }
}

alias getmbm5info {
  set %mbm5_info_temps $dll(moo.dll,mbm5info,1)
  set %mbm5_info_voltages $dll(moo.dll,mbm5info,2)
  set %mbm5_info_fans $dll(moo.dll,mbm5info,3)
  set %mbm5_info_cpuspeed $dll(moo.dll,mbm5info,4)
  set %mbm5_info_cpuusage $dll(moo.dll,mbm5info,5)
  
  set %mbm5_cpus $calc($numtok(%mbm5_info_cpuspeed,44) / 2)
  set %mbm5_cpuspeed $gettok(%mbm5_info_cpuspeed,2,44)

  ; cpu
  set %mbm5_output_cpu $null
  if ( %mbm5_cpus == 1 ) {
    set %mbm5_output_cpu %mbm5_cpuspeed $+ MHz
  }
  else {
    set %mbm5_output_cpu %mbm5_cpus CPUs @ %mbm5_cpuspeed $+ MHz
  }

  ; temps  
  set %mbm5_output_temps $null
  set %reps 1
  while (%reps <= $calc($numtok(%mbm5_info_temps,44)/2)) {
    if ( $gettok(%mbm5_info_temps,$calc((%reps * 2)),44) == 0 || $gettok(%mbm5_info_temps,$calc((%reps * 2)),44) == 255 ) {
      ; do nothing
    }
    else {
      set %mbm5_output_temps %mbm5_output_temps $+ , $gettok(%mbm5_info_temps,$calc((%reps * 2) - 1),44) $gettok(%mbm5_info_temps,$calc((%reps * 2)),44) $+ $chr(176) $+ C
    }
    inc %reps
  }
  
  ; fans  
  set %mbm5_output_fans $null
  set %reps 1
  while (%reps <= $calc($numtok(%mbm5_info_fans,44)/2)) {
    if ( $gettok(%mbm5_info_fans,$calc((%reps * 2)),44) == 0 || $gettok(%mbm5_info_fans,$calc((%reps * 2)),44) == 255 ) {
      ; do nothing
    }
    else {
      set %mbm5_output_fans %mbm5_output_fans $+ , $gettok(%mbm5_info_fans,$calc((%reps * 2) - 1),44) $gettok(%mbm5_info_fans,$calc((%reps * 2)),44) $+ RPM
    }
    inc %reps
  }  
  
  ; voltages
  set %mbm5_output_volts $null
  set %reps 1
  while (%reps <= $calc($numtok(%mbm5_info_voltages,44)/2)) {
    if ( $gettok(%mbm5_info_voltages,$calc((%reps * 2)),44) == 0 || $gettok(%mbm5_info_voltages,$calc((%reps * 2)),44) == 255 ) {
      ; do nothing
    }
    else {
      set %mbm5_output_volts %mbm5_output_volts $+ , $gettok(%mbm5_info_voltages,$calc((%reps * 2) - 1),44) $gettok(%mbm5_info_voltages,$calc((%reps * 2)),44) $+ v
    }
    inc %reps
  }
}

alias gfx {
  moodll.getcmd $1-
  if ($dll(moo.dll,gfxinfo,_) == -1) {
    moodll.error Could not find GFX card info in registry
  }
  else {
    %moodll.cmd $moof(gfx,$dll(moo.dll,gfxinfo,_))
  }
}

alias mbm {
  moodll.getcmd $1-
  if ($gettok($dll(moo.dll,mbm5info,1),1,44) == error) {
    moodll.error $gettok($dll(moo.dll,mbm5info,1),2,44)
  }
  else {
    getmbm5info
    %moodll.cmd $moof(cpu,%mbm5_output_cpu) $moof(temps,$right(%mbm5_output_temps,-2)) $moof(fans,$right(%mbm5_output_fans,-2))
    ;; %moodll.cmd $moof(voltages,$right(%mbm5_output_volts,-2))
  }
}

alias ni {
  moodll.getcmd $1-
  %moodll.cmd $moof(Network Interfaces,$dll(moo.dll,interfaceinfo,_))
}

alias stat {
  moodll.getcmd $1-
  set %rb_size 10
; To use OLD CPU Speed calculation for previous alias, change "$dll(moo.dll,cpuinfo,_)" to "$dll(moo.dll,cpuinfo,old)"
  %moodll.cmd $moof(os,$dll(moo.dll,osinfo,_)) $moof(cpu,$dll(moo.dll,cpuinfo,_)) $moof(processes,$dll(processes.dll,procs,0)) $moof(mem,$dll(moo.dll,meminfo,_) $+ $rambar()) $moof(uptime,$duration($calc($ticks / 1000)))
}

alias connstat {
  moodll.getcmd $1-
  if ($dll(moo.dll,connection,_) == -1) {
    moodll.error Could not get RAS info on this OS
  }
  else {
    %moodll.cmd $moof(dialup,$dll(moo.dll,connection,_))
  }
}

alias screenstat {
  moodll.getcmd $1-
  %moodll.cmd $moof(screen,$dll(moo.dll,screeninfo,_))
}

alias os {
  moodll.getcmd $1-
  %moodll.cmd $moof(os,$dll(moo.dll,osinfo,_))
}

alias uptime {
  moodll.getcmd $1-
  if (*Windows 2000* iswm $dll(moo.dll,osinfo,_)) { var %file = c:\winnt\inf\machine.pnf }
  else { %file = c:\windows\inf\machine.pnf }
  %moodll.cmd $moof(uptime,$duration($calc($ticks / 1000))) $moof(record,$duration($calc($get_record_uptime() / 1000))) $moof(installed,$duration($calc($ctime - $file(%file).ctime)))
}

menu channel,query {
   System Info
   .General Info
   ..Public:$stat(say)
   ..Echo:$stat(echo)
   .Network Info
   ..Public:$ni(say)
   ..Echo:$ni(echo)
   .Uptime
   ..Public:{
      if (*Windows 2000* iswm $dll(moo.dll,osinfo,_)) { var %file = c:\winnt\inf\machine.pnf }
      else { %file = c:\windows\inf\machine.pnf }
      say $moof(uptime,$duration($calc($ticks / 1000))) $moof(record,$duration($calc($get_record_uptime() / 1000))) $moof(installed,$duration($calc($ctime - $file(%file).ctime)))
   }
   ..Echo:{
      if (*Windows 2000* iswm $dll(moo.dll,osinfo,_)) { var %file = c:\winnt\inf\machine.pnf }
      else { %file = c:\windows\inf\machine.pnf }
      echo $moof(uptime,$duration($calc($ticks / 1000))) $moof(record,$duration($calc($get_record_uptime() / 1000))) $moof(installed,$duration($calc($ctime - $file(%file).ctime)))
   }
   .Motherboard Monitor
   ..Public:$mbm(say)
   ..Echo:$mbm(echo)
   .Monitor Info
   ..Public:$screenstat(say)
   ..Echo:$screenstat(echo)
   .Operating System
   ..Public:$os(say)
   ..Echo:$os(echo)
   .Graphics Info
   ..Public:$gfx(say)
   ..Echo:$gfx(echo)
   .Dialup Info
   ..Public:$connstat(say)
   ..Echo:$connstat(echo)
   .Stats Settings
   ..Toggle Color
   ...On:set %moo_use_color 1
   ...Off:set %moo_use_color 0
   ..Color Code:{
     :ask
     var %cc = $?="Enter the color code you would like to use for text headers and rambar (0 - 15)"
     if ((%cc < 0) || (%cc > 15)) {
       echo 4 -a ERROR: Must enter a valid number 0 - 15
       goto ask
     }
     set %moo_color %cc
   }
}
