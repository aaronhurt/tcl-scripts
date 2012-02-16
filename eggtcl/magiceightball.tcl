## first revision..no comments or help
## by leprechau@EFnet
##
## NOTE: always check for new code/updates at http://woodstock.anbcs.com/scripts/
## this is the only official location for any of my scripts
##
namespace eval ::magicEight {

	setudef flag magiceightball

	proc ball {} {
		switch -exact -- [expr {round(rand()*20)}] {
			0 - 1 {return "Signs point to yes."}
			2 {return "Yes."}
			3 {return "Reply hazy, try again."}
			4 {return "Without a doubt."}
			5 {return "My sources say no."}
			6 {return "As I see it, yes."}
			7 {return "You may rely on it."}
			8 {return "Concentrate and ask again."}
			9 {return "Outlook not so good."}
			10 {return "It is decidedly so."}
			11 {return "Better not tell you now."}
			12 {return "Very doubtful."}
			13 {return "Yes - definitely."}
			14 {return "It is certain."}
			15 {return "Cannot predict now."}
			16 {return "Most likely."}
			17 {return "Ask again later."}
			18 {return "My reply is no."}
			19 {return "Outlook good."}
			20 {return "Don't count on it."}
		}
	}

	proc pubCatch {nick uhost hand chan text} {
		if {(![channel get $chan magiceightball]) || (![string match -nocase *$::botnick* $text]) || (![string equal "[string trim $text {?}]?" $text])} {return}
		putserv "PRIVMSG $chan :$nick, [::magicEight::ball]"
	}
	bind pubm - * ::magicEight::pubCatch
}
package provide magicEight 0.1

putlog "Public Magic Eight Ball v0.1 by leprechau LOADED!"
