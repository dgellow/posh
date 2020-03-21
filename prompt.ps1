. "$(Split-Path $script:MyInvocation.MyCommand.Path)\formatting.ps1"

# Renders a 2 columns layout, with $left argument written to the extreme left of the console, and $right to the extreme
# right. The cursor is restored back to its position thus should not be impacted.
function Layout ($left, $right) {
	Write-Host $left -NoNewline

	$origX = $Host.UI.RawUI.CursorPosition.X
	$origY = $Host.UI.RawUI.CursorPosition.Y
	$rightX = $Host.UI.RawUI.WindowSize.Width - $right.Length
	$rightY = $Host.UI.RawUI.CursorPosition.Y
	$position = New-Object System.Management.Automation.Host.Coordinates $rightX, $rightY
	$Host.UI.RawUI.CursorPosition = $position
	Write-Host $right -NoNewLine

	$position = New-Object System.Management.Automation.Host.Coordinates $origX, $origY
	$Host.UI.RawUI.CursorPosition = $position

	return " "
}

# Get the current directory. If at the root of a drive, the name of the file is returned without the slash, e.g: "C:"
function Current-Directory {
	$location = (Get-Location).Path
	$split = $location.Split("\")

	if ($split[-1] -eq "") {
		return $split[0]
	}
	return $split[-1]
}

# The "main" directory is roughly defined as a contextual directory name that helps understand what the "current
# directory" is. Depending what the current location is, the main directory can be the drive name, the parent directory,
# "Users\Sam", or nothing (in case where the current directory is a drive root).
function Current-Main-Directory {
	$fullname = (Get-Location).Path
	$split = $fullname.Split("\")

	if ($fullname.StartsWith("C:\Users\Sam\OneDrive") -and ($split.Length -gt 5)) {
		return "OneDrive\" + $split[4]
	}

	if ($fullname.StartsWith("C:\Users\Sam\") -and ($split.Length -gt 4)) {
		return $split[3]
	}

	if ($fullname.StartsWith("C:\Users\Sam\") -and ($split.Length -eq 4)) {
		return "Users\Sam"
	}

	if ($fullname.StartsWith("C:\Users\Sam\OneDrive") -and ($split.Length -eq 5)) {
		return "OneDrive"
	}

	if ($split[-1] -eq "") {
		return ""
	}

	if ($split.Length -gt 2) {
		return $split[1]
	}

	return $split[0]
}

# Get the current git branch name
function Git-Branch {
	$raw = git status --porcelain --branch
	$branch = $raw.Split(" ").Split("...")[1]
	return $branch
}

# Check if current user is an administrator
function Test-Administrator {
	$user = [Security.Principal.WindowsIdentity]::GetCurrent()
	return ([Security.Principal.WindowsPrincipal] $user).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
}

# Define the command prompt
function prompt {
	$lastCommandResult = $?
	$left = ""
	$right = ""

	# Main and current directory
	$mainDir = (Current-Main-Directory)
	if ($mainDir -ne "") {
		$left += (With-Grey $mainDir) + " | "
	}
	$left += With-Magenta (Current-Directory)

	# Git status
	$isInGitDir = $(git rev-parse --is-inside-work-tree 2>$null)
	if ($isInGitDir) {
		$left += " :: " + (With-Magenta (Git-Branch))
	}

	# Current time
	$time = Get-Date -Format "%H:%m:%s"
	if ($lastCommandResult) {
		$right += " " + (With-Green $time)
	}
	else {
		$right += " " + (With-Red $time)
	}

	# When admin user
	if (Test-Administrator) {
		$left = " " + (With-Underline "Admin") + " :: " + $left + " > "
	}
	else {
		$left += " {0} " -f ("$([char]0x25B7)" * ($nestedPromptLevel + 1)) # character ▷. Some nice options: ⪧⫸▷▶♪
	}

	# Renders the prompt
	Layout $left $right
	return ""
}