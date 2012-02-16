## parse out dbf files in pure tcl
## handle multiple records...display info
## and convert into standard CSV or SQL statements
## no documentation or support..read the code for more info
## 
## by leprechau@EFnet 2008
#
namespace eval ::dbf2xxx {
    proc dbf2xxx {ifname type {info {0}}} {
        ## open file and configure channel
        set fid [open $ifname r]; fconfigure $fid -encoding binary -translation binary
        ## read in our binary header and assign to variables...
        if {![binary scan [read $fid 32] cccciss verNum yy mm dd numRecs hdrLen recLen]} {
            return -code error "Unable to read header...cannot continue"
        }
        ## dbf sanity checks...records
        if {!($recLen > 1) || !($recLen < 4000)} {
            return -code error "Record length inconsistency...corrupt DBF structure"
        }
        if {!($numRecs >= 0)} {
            return -code error "Invalid number of records...corrupt DBF structure"
        }
        ## dbf sanity checks...calculate number of fields
        if {!([set numFields [expr {int(($hdrLen-1)/32)-1}]] >= 1)} {
            return -code error "Invalid number of fields...corrupt DBF structure"
        }
        ## dbf sanity checks...file size
        if {[file size $ifname] != [set calcSize [expr {($hdrLen+1)+($numRecs*$recLen)}]]} {
            return -code error "Invalid file size...size should be $calcSize...corrupt DBF structure"
        }
        ## initialize our record format map
        set recFmt A; set scanMap v0
        ## populate our initial field data array
        array set fieldData [list nam,0 {} typ,0 "C" ofs,0 0 len,0 1 dcnt,0 0 flg,0 0]
        ## read all field descriptors
        for {set i 1} {$i <= $numFields} {incr i} {
            ## scan in our binary field data
            if {![binary scan [read $fid 32] A11aiccc fieldData(nam,$i) fieldData(typ,$i) fieldData(ofs,$i) \
            fieldData(len,$i) fieldData(dcnt,$i) fieldData(flg,$i)]} {
                return -code error "Unable to read data field...cannot continue"
            }
            ## strip cr/nl from field names
            array set fieldData [list nam,$i [string map {\r "" \n ""} $fieldData(nam,$i)]]
            ## build record format map...this will not work for some field types
            ## however..we only have C, D and N type fields in our DBFs...fix if you have other types
            append recFmt A$fieldData(len,$i); lappend scanMap v$i
        }
        ## show DBF info and stop...
        if {$info} {
            ## calc year from dbf header...zero pad dd and mm
            if {$yy < 78} {set yy [expr {$yy+2000}]} else {set yy [expr {$yy+1900}]}
            foreach var {dd mm} {set [set var] [format %02d [set [set var]]]}
            ## aight...let's show it...
            lappend outs "File Information:"
            ## convert header version to human readable string
            switch -exact -- 0x[format %02x $verNum] {
                0x02 {set comVer "FoxBase \(without memo\)"}
                0x03 {set comVer "FoxBase+\/dBASE III+ \(without memo\)"}
                0x04 {set comVer "dBASE IV \(without memo\)"}
                0x05 {set comVer "dBASE 5.0 \(without memo\)"}
                0x83 {set comVer "FoxBase+/dBASE III+"}
                0x8b {set comVer "dBASE IV"}
                0x30 {set comVer "Visual FoxPro \(without memo\)"}
                0xf5 {set comVer "FoxPro 2.0 \(with memo\)"}
                default {set comVer "Unknown \(code 0x[format %02x $verNum]\)"}
            }
            lappend outs "xBase file version....:\t\t$comVer"
            lappend outs "Date of last update...:\t\t${yy}-${mm}-${dd}"
            lappend outs "Number of records.....:\t\t$numRecs \(0x[format %08x $numRecs]\)"
            lappend outs "Length of header......:\t\t$hdrLen \(0x[format %04x $hdrLen]\)"
            lappend outs "Record length.........:\t\t$recLen \(0x[format %04x $recLen]\)"
            lappend outs "Number of fields......:\t\t$numFields"
            lappend outs "+---------------+------+---------+-----------+---------+"
            lappend outs "| Field Name    | Type | Offset  | Length    | Decimal |"
            lappend outs "+---------------+------+---------+-----------+---------+"
            for {set i 1} {$i <= $numFields} {incr i} {
                foreach var {nam typ ofs len dcnt flg} {
                    switch -exact -- $var {
                        nam {set temp "| [format %-13s $fieldData(nam,$i)] |"}
                        typ {set temp " [format %-4s $fieldData(typ,$i)] |"}
                        ofs {set temp " [format %-7s 0x[format %02x $fieldData(ofs,$i)]] |"}
                        len {set temp " [format %-9u $fieldData(len,$i)] |"}
                        dcnt {set temp " [format %-7u $fieldData(dcnt,$i)] |"}
                        default {continue}
                    }; append temps $temp
                }; lappend outs $temps; unset temps
            }
            lappend outs "+---------------+------+---------+-----------+---------+"
            ## that's it..we showed them the info...let's stop
            close $fid; return [join $outs \n]
        }
        ## setup our final output based on type...
        switch -exact -- $type {
            csv {
                ## build csv column header
                for {set i 1} {$i <= $numFields} {incr i} {
                    lappend temps $fieldData(nam,$i)
                }
                ## set our initial csv output buffer...
                lappend outPut [join $temps {,}]; unset temps
            }
            sql {
                ## set our table name....
                set tname [file rootname $ifname]
                ## build create table statement
                for {set i 1} {$i <= $numFields} {incr i} {
                    switch -exact -- $fieldData(typ,$i) {
                        C {lappend temps "\t$fieldData(nam,$i)\tvarchar\($fieldData(len,$i)\),"}
                        D {lappend temps "\t$fieldData(nam,$i)\tdate,"}
                        N {
                            ## int or numeric?
                            if {$fieldData(dcnt,$i) == 0} {
                                lappend temps "\t$fieldData(nam,$i)\tint\,"
                            } else {
                                lappend temps "\t$fieldData(nam,$i)\tnumeric\($fieldData(len,$i),$fieldData(dcnt,$i)\),"
                            }
                        }
                        default {return -code error "Unhandled data type \($fieldData(typ,$i)\) encountered!"}
                    }
                }
                ## set our initial sql output buffer...
                lappend outPut "DROP TABLE $tname\;\n" "CREATE TABLE $tname \(" "[join $temps \n]\n\)\;\n"; unset temps
            }
        }
        ## read last bit of headers into bit heaven...
        set lhBit [read $fid 1]; unset lhBit
        ## alright..almost there let's read the records...
        for {set i 1} {$i <= $numRecs} {incr i} {
            ## read it...let's hope it works...
            eval binary scan [list [read $fid $recLen]] $recFmt $scanMap
            ## start building output buffer..skip the first null byte...
            foreach var [lrange $scanMap 1 end] {
                lappend temps [string trim [set [set var]]]
            }
            ## one more switch for our output type...
            switch -exact -- $type {
                csv {lappend outPut [join $temps {,}]; unset temps}
                sql {lappend outPut "INSERT INTO $tname VALUES \([join $temps {,}]\)\;"; unset temps}
            }
        }
        ## we are done...close our DBF file...and return out data...
        close $fid; return [join $outPut \n]
    }
}
