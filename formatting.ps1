# Colors and text style, based on https://en.wikipedia.org/wiki/ANSI_escape_code
enum TextStyles {
	reset
	bold
	thin
	italic
	underline
	slowBlink
	rapidBlink
	inverse
	conceal
	crossedOut
	fontPrimary
	fontAlt1
	fontAlt2
	fontAlt3
	fontAlt4
	fontAlt5
	fontAlt6
	fontAlt7
	fontAlt8
	fontAlt9
	fraktur
	underlineDouble
	resetItalic
	resetFraktur
	resetUnderline
	resetBlink
	resetInverse
	resetConceal
	resetCrossedOut
}

enum TextColors {
	fgDarkBlack = 30
	fgDarkRed
	fgDarkGreen
	fgDarkYellow
	fgDarkBlue
	fgDarkMagenta
	fgDarkCyan
	fgDarkWhite
	bgDarkBlack = 40
	bgDarkRed
	bgDarkGreen
	bgDarkYellow
	bgDarkBlue
	bgDarkMagenta
	bgDarkCyan
	bgDarkWhite
	fgBlack = 90
	fgRed
	fgGreen
	fgYellow
	fgBlue
	fgMagenta
	fgCyan
	fgWhite
	bgBlack = 100
	bgRed
	bgGreen
	bgYellow
	bgBlue
	bgMagenta
	bgCyan
	bgWhite
}

function Try-Styles {
	[TextStyles].GetEnumNames() | ForEach-Object {
		$style = [int]([TextStyles]::$_)
		$escaped = (escape $style)
		$reset = "$([char]27)[m"
		"$escaped{0,-20}$reset{1,3}" -f $_, $style
	}
}

function Try-Colors {
	[TextColors].GetEnumNames() | ForEach-Object {
		$style = [int]([TextColors]::$_)
		$escaped = (escape $style)
		$reset = "$([char]27)[m"
		"$escaped{0,-20}$reset{1,3}" -f $_, $style
	}
}

function escape ($attr) {
	return "$([char]27)[$([int]$attr)m"
}

function Length-Without-ANSI([string] $str) {
	return ($str -replace "`e[\[0-9]*m").Length
}

function With-Style([TextStyles] $style, $message) {
	return "{0}{1}{2}" -f (escape $style), $message, (escape $reset)
}

function With-Color ([TextColors] $color, $message) {
	return "{0}{1}{2}" -f (escape $color), $message, (escape $reset)
}

# Styles
function With-Reset ($message) {
	return With-Style reset $message
}
function With-Bold ($message) {
	return With-Style bold $message
}
function With-Thin ($message) {
	return With-Style thin $message
}
function With-Italic ($message) {
	return With-Style italic $message
}
function With-Underline ($message) {
	return With-Style underline $message
}
function With-SlowBlink ($message) {
	return With-Style slowBlink $message
}
function With-RapidBlink ($message) {
	return With-Style rapidBlink $message
}
function With-Inverse ($message) {
	return With-Style inverse $message
}
function With-Conceal ($message) {
	return With-Style conceal $message
}
function With-CrossedOut ($message) {
	return With-Style crossedOut $message
}
function With-FontPrimary ($message) {
	return With-Style fontPrimary $message
}
function With-FontAlt1 ($message) {
	return With-Style fontAlt1 $message
}
function With-FontAlt2 ($message) {
	return With-Style fontAlt2 $message
}
function With-FontAlt3 ($message) {
	return With-Style fontAlt3 $message
}
function With-FontAlt4 ($message) {
	return With-Style fontAlt4 $message
}
function With-FontAlt5 ($message) {
	return With-Style fontAlt5 $message
}
function With-FontAlt6 ($message) {
	return With-Style fontAlt6 $message
}
function With-FontAlt7 ($message) {
	return With-Style fontAlt7 $message
}
function With-FontAlt8 ($message) {
	return With-Style fontAlt8 $message
}
function With-FontAlt9 ($message) {
	return With-Style fontAlt9 $message
}
function With-Fraktur ($message) {
	return With-Style fraktur $message
}
function With-UnderlineDouble ($message) {
	return With-Style underlineDouble $message
}
function With-ResetItalic ($message) {
	return With-Style resetItalic $message
}
function With-ResetFraktur ($message) {
	return With-Style resetFraktur $message
}
function With-ResetUnderline ($message) {
	return With-Style resetUnderline $message
}
function With-ResetBlink ($message) {
	return With-Style resetBlink $message
}
function With-ResetInverse ($message) {
	return With-Style resetInverse $message
}
function With-ResetConceal ($message) {
	return With-Style resetConceal $message
}
function With-ResetCrossedOut ($message) {
	return With-Style resetCrossedOut $message
}

# Foreground colors
function With-Black ($message) {
	return With-Color  fgBlack $message
}
function With-Red ($message) {
	return With-Color fgRed $message
}
function With-Green ($message) {
	return With-Color fgGreen $message
}
function With-Yellow ($message) {
	return With-Color fgYellow $message
}
function With-Blue ($message) {
	return With-Color fgBlue $message
}
function With-Magenta ($message) {
	return With-Color fgMagenta $message
}
function With-Cyan ($message) {
	return With-Color fgCyan $message
}
function With-White ($message) {
	return With-Color fgWhite $message
}

# Dark foreground colors
function With-DarkBlack ($message) {
	return With-Color fgDarkBlack $message
}
function With-DarkRed ($message) {
	return With-Color fgDarkRed $message
}
function With-DarkGreen ($message) {
	return With-Color fgDarkGreen $message
}
function With-DarkYellow ($message) {
	return With-Color fgDarkYellow $message
}
function With-DarkBlue ($message) {
	return With-Color fgDarkBlue $message
}
function With-DarkMagenta ($message) {
	return With-Color fgDarkMagenta $message
}
function With-DarkCyan ($message) {
	return With-Color fgDarkCyan $message
}
function With-DarkWhite ($message) {
	return With-Color fgDarkWhite $message
}

# Background colors
function With-Background-Black ($message) {
	return With-Color bgBlack $message
}
function With-Background-Red ($message) {
	return With-Color bgRed $message
}
function With-Background-Green ($message) {
	return With-Color bgGreen $message
}
function With-Background-Yellow ($message) {
	return With-Color bgYellow $message
}
function With-Background-Blue ($message) {
	return With-Color bgBlue $message
}
function With-Background-Magenta ($message) {
	return With-Color bgMagenta $message
}
function With-Background-Cyan ($message) {
	return With-Color bgCyan $message
}
function With-Background-White ($message) {
	return With-Color bgWhite $message
}

# Dark background colors
function With-Background-DarkBlack ($message) {
	return With-Color bgDarkBlack $message
}
function With-Background-DarkRed ($message) {
	return With-Color bgDarkRed $message
}
function With-Background-DarkGreen ($message) {
	return With-Color bgDarkGreen $message
}
function With-Background-DarkYellow ($message) {
	return With-Color bgDarkYellow $message
}
function With-Background-DarkBlue ($message) {
	return With-Color bgDarkBlue $message
}
function With-Background-DarkMagenta ($message) {
	return With-Color bgDarkMagenta $message
}
function With-Background-DarkCyan ($message) {
	return With-Color bgDarkCyan $message
}
function With-Background-DarkWhite ($message) {
	return With-Color bgDarkWhite $message
}
