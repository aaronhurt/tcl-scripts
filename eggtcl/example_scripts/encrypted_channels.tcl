#########################
### READ ALL COMMENTS ###
#########################

## note...this is an enhancement of the existing
## encrypted_channels.tcl that exists in this same webspace but has been renamed
#### if you are looking for that script try: http://woodstock.anbcs.com/scripts/encrypted_channels_old.tcl
## this version has been made more 'source and forget' friendly
## for those that are either too impatient or lack the experience
## to implement the original in thier code that being said
## you should still read the comments if you would like to increase your knowledge

## this code still requires you to search/replace your putserv with eputserv
## in the scripts and locations where you want it to function for output

## in #tcl and #eggtcl on efnet we always get people asking
## how to deal with encrypted channels
## if you read through all this and have some knowledge of tcl
## this should solve most of your problems..if you still have questions
## feel free to pop in on efnet and ask ;}
## leprechau@EFnet

##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::encChans {
	## first, set a few user defines
	##
	setudef flag encrypted
	## this is used to 'mark' your encypted channels
	setudef str blowkey
	## this is the encyrption key to use for the channel

	### these defines are used like this:
	## .chanset #channel +encrypted
	## .chanset #channel blowkey key

	## here is a nice little switch that handles your pub commands
	proc pubTriggers {nick uhost hand chan text} {
		## check that user is not +X and the channel is marked as encrypted and that we have a key set for it
		if {([matchattr $hand X|X]) || (![channel get $chan encrypted]) || (![string length [set bkey [channel get $chan blowkey]]])} {return}
		## decrypt the text and seperate out the trigger from the arguments
		set trigger [lindex [split [set text [decrypt $bkey $text]]] 0]
		set text [join [lrange [split $text] 1 end]]
		## start the switch to handle your commands...these normally would have thier own binds
		## all the switch is automatically created by some code down below
		switch -exact $trigger [array get ::encChans::pubBinds]; return
	}
	bind pub - +OK ::encChans::pubTriggers

	## notice the bind...we are binding to +OK which is the most common blowfish channel prefix
	## we also bind to all flags...we sort this out up top with a custom flag X...this allows us to exclude certain users/things
	## example:
	## .adduser somebot
	## .chattr somebot +X
	## this bot will now not trigger this bind

	## another common question...how to handle pubm binds...much the same manner...see below

	## here is a nice little switch that handles your pubm commands
	proc pubmTriggers {nick uhost hand chan text} {
		## check that user is not +X and the channel is marked as encrypted and that we have a key set for it
		if {([matchattr $hand X|X]) || (![channel get $chan encrypted]) || (![string length [set bkey [channel get $chan blowkey]]])} {return}
		## strip the +OK off of our string...pubm passes the whole string...we decrypt the text here as well
		set text [decrypt $bkey [lindex [split $text] end]]
		## start the switch to handle your commands...these normally would have thier own binds
		## we also include the channel in the glob...to match as close as possible to a real pubm bind
		switch -glob "$chan$text" [array get ::encChans::pubmBinds]; return
	}
	bind pubm - *+OK* ::encChans::pubmTriggers
	## same story with the bind here...
	
	## and here it is at the bottom of the namespace...the little magic bit that makes it all easier
	## this will cycle through all your binds setup a nice array that will work for your encrypted channels
	## furthermore...the binds will still work as normal in non encrypted channels
	## take a carefull look how we do this...we pass variable names here as escaped strings so they are not parsed
	## however in our proc above the escape is removed and the vars are present in that proc so they will work as planed
	
	## initialize our array and populate it
	variable pubBinds; array set pubBinds [list]
	foreach pub [binds pub] {
		foreach {type flag trig hits cmd} $pub {array set ::encChans::pubBinds [list $trig "$cmd \$nick \$uhost \$hand \$chan \$text"]}
	}
	## same thing for our pubm binds
	variable pubmBinds; array set pubmBinds [list]
	foreach pubm [binds pubm] {
		foreach {type flag trig hits cmd} $pub {array set ::encChans::pubmBinds [list $trig "$cmd \$nick \$uhost \$hand \$chan \$text"]}
	}	
}

## next...lets's see what we should do with putting text out..
## this is pretty straightforward...make a simple proc....you can do the same for putserv/putquick also if you need
## then just search/replace putserv with eputserv where you need it
## notice the join oddness at the end...if your text happend to have more than one colon (:) in it, this should fix it
## hopefully ;}

## if you just need one channel and one key try this...else, look right below for something a bit fancier
## here it is assumed that 'blowfishkey' is a global variable
proc eputserv {text} {putserv "[lindex [split $text {:}] 0] :+OK [encrypt $::blowfishkey [join [lrange [split $text {:}] 1 end] {:}]]"}

## this is just for channels as it is assumed that private messages would not be encrypted...if that is not the case
## then just make the appropriate changes below
proc eputserv {text} {
	## check if we got a valid channel...if not call normal queue and stop
	if {![validchan [set chan [lindex [split $text {:}] 0]]]} {putserv $text; return}
	## check our channel and pull in the set flags and keys..if not found stop
	if {(![channel get $chan encypted]) || (![string length [set bkey [channel get $chan blowkey]]])} {return}
	## continue on and output our encrypted text using the defined key from the channel string
	putserv "$chan :+OK [encrypt $bkey [join [lrange [split $text {:}] 1 end] {:}]]"
	## that's it...we are done
}

### NOTE: there are some scripts out there that you can just 'source and forget' ... these may work for you
## the only problem with these is that they usually affect ALL your channel and server interactions by renaming your
## eggdrop queue commands (puthelp/putserv/putquick) etc...
## unless you are sure this is what you want and you have no non-encrypted channels, please consider doing it this way

## EOF