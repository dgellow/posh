# Colors and text style
$fgGrey = "$([char]27)[90m"
$fgRed = "$([char]27)[91m"
$fgGreen = "$([char]27)[92m"
$fgYellow = "$([char]27)[93m"
$fgBlue = "$([char]27)[94m"
$fgMagenta = "$([char]27)[95m"
$underline = "$([char]27)[24m"
$reset = "$([char]27)[m"

function With-Color ($color, $message) {
	return "{0}{1}{2}" -f $color, $message, $reset
}

function With-Grey ($message) {
	return With-Color $fgGrey $message
}

function With-Red ($message) {
	return With-Color $fgRed $message
}


function With-Green ($message) {
	return With-Color $fgGreen $message
}

function With-Yellow ($message) {
	return With-Color $fgYellow $message
}


function With-Blue ($message) {
	return With-Color $fgBlue $message
}

function With-Magenta ($message) {
	return With-Color $fgMagenta $message
}

function With-Underline ($message) {
	return With-Color $underline $message
}
