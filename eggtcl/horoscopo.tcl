## fetch spanish horoscopes from terra.cl
## initial version...no documentation/support
## other than provided herein
##
## read the code....
##

## declare our namespace
namespace eval ::horoscopo {
    ## we will use http package here
    package require http
    ## set our channel flag
    setudef flag horoscopo
}

## convert strings to url numbers for terra.cl
proc ::horoscopo::sign2num {sign} {
    switch -exact -- [string tolower $sign] {
        acuario {return 1}
        aries {return 2}
        cancer {return 3}
        capricornio {return 4}
        escorpion {return 6}
        geminis {return 7}
        leo {return 10}
        libra {return 11}
        piscis {return 14}
        sagitario {return 16}
        tauro {return 19}
        virgo {return 22}
        default {return -1}
    }
}

## our main proc....
proc ::horoscopo::doIt {nick uhost hand chan text} {
    ## not active here...return
    if {![channel get $chan horoscopo]} {return}
    ## here we go...check for sanity
    if {![string length $text] || ([set num [::horoscopo::sign2num $text]] == -1)} {
        putserv "NOTICE $nick :Uso: !horoscopo <signo>, Ej: !horoscopo aries"
        putserv "NOTICE $nick :SIGNO NO VÁLIDO!. Válidos: aries, tauro, geminis, cancer, leo, virgo, libra, escorpion, sagitario, capricornio, acuario y piscis."; return
    }
    ## set our user agent...
    http::config -useragent "Mozilla/1.0"
    ## that's it..let's go....
    set data [http::data [set token [http::geturl http://www.terra.cl/astrologia/include/pop_h_diario.cfm?signo=$num]]]
    ## parse out what we need...
    if {[regexp -- {<span class="txt_2_10"><b></b><br>(.+?)<br></span>} $data x horoscopo]} {
        ## send it to the channel
        putserv "PRIVMSG $chan :\00312$text:\003 $horoscopo"
    }
    ## clean up our token...
    http::cleanup $token
}
## our bind...
bind pub - !horoscopo ::horoscopo::doIt
