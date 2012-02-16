proc color {{color {}}} {
	set esc [format %c 27]
	switch  -exact -- $color {
		plain     {return $esc\[0m}
		bold      {return $esc\[1m}
		underline {return $esc\[4m}
		blink     {return $esc\[5m}
		inverted  {return $esc\[7m}
		invisible {return $esc\[8m}

		fgblack   {return $esc\[30m}
		fgred     {return $esc\[31m}
		fggreen   {return $esc\[32m}
		fgyellow  {return $esc\[33m}
		fgblue    {return $esc\[34m}
		fgmagenta {return $esc\[35m}
		fgcyan    {return $esc\[36m}
		fgwhite   {return $esc\[37m}

		bgblack   {return $esc\[40m}
		bgred     {return $esc\[41m}
		bggreen   {return $esc\[42m}
		bgyellow  {return $esc\[43m}
		bgblue    {return $esc\[44m}
		bgmagenta {return $esc\[45m}
		bgcyan    {return $esc\[46m}
		bgwhite   {return $esc\[47m}

		default   {return $esc\[0m}
	}
}