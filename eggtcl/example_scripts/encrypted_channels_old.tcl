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
	switch -exact $trigger {
		!help {pub_help_proc $nick $uhost $hand $chan $text}
		!list {pub_list_proc $nick $uhost $hand $chan $text}
		!blah {pub_blah_proc $nick $uhost $hand $chan $text}
		## no match..lets stop
		default {return}
	}
}
bind pub - +OK pubTriggers

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
	## strip the +OK off of our string...pubm passes the whole string
	set text [lindex [split $text] end]
	## start the switch to handle your commands...these normally would have thier own binds
	## we also include the channel in the glob...to match as close as possible to a real pubm bind
	## note the text is also decrypted here as well
	switch -glob "$chan[set text [decrypt $bkey $text]]" {
		"*#bob*hello*" {pubm_proc $nick $uhost $hand $chan $text}
		"*hello world*" {another_pubm_proc $nick $uhost $hand $chan $text}
		## no match..lets stop
		default {return}
	}
}
bind pubm - *+OK* pubmTriggers

## same story with the bind here...

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