#!/bin/sh
# -*- tcl -*-
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

namespace eval ::renameOmatic2007 {
    ## recurrsive glob
    proc globRec {{dir .} {filespec "*"} {types {b c f l p s}}} {
      set files [glob -nocomplain -types $types -dir $dir -- $filespec]
      foreach x [glob -nocomplain -types {d} -dir $dir -- *] {
        set files [concat $files [globRec [file join $dir $x] $filespec $types]]
      }; return $files
    }
    
    proc fixEm {} {
        puts "Generating file list...."
        ## get the full file list
        set fileList [globRec . *\(?\)*\.* f]
        puts "Finding largest file among duplicates..."
        ## find our biggest files among the dupes...
        set i 0; foreach file $fileList {
           if {[string equal -nocase [string trim [regsub {\((.+?)\)\.(.+?)$} $file {}]] \
                [string trim [regsub {\((.+?)\)\.(.+?)$} [set f2 [lindex $fileList [expr {$i+1}]]] {}]]]} {
                array set temps [list [file size $file] $file]
           } else {
                array set temps [list [file size $file] $file]
                lappend biggies $temps([lindex [lsort -decreasing -real [array names temps]] 0]); array unset temps
           }; incr i
        }
        puts "Renaming largest files..."
        ## rename them...
        if {[info exists biggies]} {
            foreach file $biggies {
                file rename -force -- $file [string trim [regsub {\((.+?)\)\.(.+?)$} $file {}]][file extension $file]
            }
            puts "Deleting leftovers..."
            ## delete the rest...
            foreach file [globRec . *\(?\)*\.* f] {
                file delete -force -- $file
            }
        }
    }
}

## do it...
::renameOmatic2007::fixEm