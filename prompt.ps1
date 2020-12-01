. "$(Split-Path $script:MyInvocation.MyCommand.Path)\formatting.ps1"
. "$(Split-Path $script:MyInvocation.MyCommand.Path)\python.ps1"

# Renders a 2 columns layout, with $left argument written to the extreme left of the console, and $right to the extreme
# right. The cursor is restored back to its position thus should not be impacted.
function Write-Layout ($left, $right) {
	Write-Host $left -NoNewline

	$origX = $Host.UI.RawUI.CursorPosition.X
	$origY = $Host.UI.RawUI.CursorPosition.Y

	$rightX = $Host.UI.RawUI.WindowSize.Width - (Length-Without-ANSI $right)
	$rightY = $Host.UI.RawUI.CursorPosition.Y
	$position = New-Object System.Management.Automation.Host.Coordinates $rightX, $rightY

	$Host.UI.RawUI.CursorPosition = $position
	Write-Host $right -NoNewLine

	$position = New-Object System.Management.Automation.Host.Coordinates $origX, $origY
	$Host.UI.RawUI.CursorPosition = $position
}

# Get the current directory. If at the root of a drive, the name of the file is returned without the slash, e.g: "C:"
function Current-Directory {
	return Split-Path (Get-Location) -Leaf
}

function New-Path($string) {
	return (Join-Path -Path $string -ChildPath ".").TrimEnd("\/.")
}

function Safe-Split-Path ($path) {
	$safe = New-Path $path
	if ($IsWindows) {
		return $safe.Split("\")
	}
	return $safe.Split("/")
}

function Count-Path ($path) {
	return (Safe-Split-Path $path).Length
}

# The "main" directory is roughly defined as a contextual directory name that helps understand what the "current
# directory" is. Depending what the current location is, the main directory can be the drive name, the parent directory,
# "Users\Sam", or nothing (in case where the current directory is a drive root).
function Current-Main-Directory {
	$fullname = (Get-Location).Path
	$split = @(Safe-Split-Path $fullname)

	$oneDrivePath = New-Path "${HOME}/OneDrive" # e.g: C:\Users\Sam\OneDrive
	if ($IsLinux -and (Test-Path "/mnt/c")) {
		# mounted path under WSL
		$oneDrivePath = New-Path "/mnt/c/Users/Sam/OneDrive"
	}

	$count = Count-Path $onedrivePath
	# deep in onedrive directory
	if ($fullname.StartsWith($oneDrivePath) -and ($split.Length -gt $count + 1)) {
		return [string](New-Path ("OneDrive/{0}" -f $split[$count]))
	}
	# in onedrive directory
	if ($fullname.StartsWith($oneDrivePath) -and ($split.Length -eq (Count-Path $oneDrivePath) + 1)) {
		return "OneDrive"
	}

	$count = Count-Path $HOME
	# deep in home directory
	if ($fullname.StartsWith($HOME) -and ($split.Length -gt $count + 1)) {
		return $split[$count]
	}
	# in home directory
	if ($fullname.StartsWith($HOME) -and ($split.Length -eq $count + 1)) {
		$parent = Split-Path (Split-Path $HOME -Parent) -Leaf
		$leaf = Split-Path $HOME -Leaf
		return [string](New-Path ("{0}/{1}" -f $parent, $leaf))
	}

	# top directory
	if ($split.Length -gt 2) {
		return Split-Path $fullname -Parent
	}

	# root level
	if (($split.Length -eq 1) -or ($split[-1] -eq "")) {
		return ""
	}

	# default
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
	if ($IsLinux -or $IsMacOS) {
		return ((id -u) -eq 0)
	}
	if ($IsWindows) {
		$user = [Security.Principal.WindowsIdentity]::GetCurrent()
		return ([Security.Principal.WindowsPrincipal] $user).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
	}
	return ""
}

# ZenMode
$global:ZenMode = [Boolean]::FalseString

function Start-ZenMode {
	Clear-Host
	$global:ZenMode = [Boolean]::TrueString

	Set-PSReadLineKeyHandler -Chord enter -ScriptBlock {
		[Microsoft.PowerShell.PSConsoleReadLine]::ClearScreen()
		[Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
		Write-Host "`n`n"
	}
}

function Stop-ZenMode {
	Clear-Host
	$global:ZenMode = [Boolean]::FalseString

	Set-PSReadLineKeyHandler -Chord enter -ScriptBlock {
		[Microsoft.PowerShell.PSConsoleReadLine]::AcceptLine()
	}
}

# Define the command prompt
function prompt {
	$lastCommandResult = $?

	if ($global:ZenMode -eq [Boolean]::TrueString) {
		$left = "{0}`t" -f "`n" * 3
		if ($Host.UI.RawUI.CursorPosition.Y -lt 2) {
			$left = "`t"
		}

		$right = " "
		if (!$lastCommandResult) {
			$right = With-Red "◆"
		}

		Write-Layout $left $right
		return " "
	}

	$left = ""
	$right = ""

	# Main and current directory
	$mainDir = (Current-Main-Directory)
	if ($mainDir -ne "") {
		$left += (With-Black $mainDir) + " | "
	}
	$left += With-Magenta (Current-Directory)

	# Git status
	$isInGitDir = $(git rev-parse --is-inside-work-tree 2>$null)
	if ($isInGitDir) {
		$left += " :: " + (With-Magenta (Git-Branch))
	}

	# Current time
	$time = Get-Date -Format "HH:mm:ss"
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
	Write-Layout $left $right

	# Python venv
	switch (Try-ActivatePython) {
		([PythonVenvStatus]::activated) {
			$msg = (With-Green "▶") + " Python venv activated"
			Write-Host "`n$msg"
			prompt
		}
		([PythonVenvStatus]::deactivated) {
			$msg = (With-Yellow "▶") + " Python venv deactivated"
			Write-Host "`n$msg"
			prompt
		}
	}

	return " "
}
