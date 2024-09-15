function Show-FilesUnixStyle {
	<#
    .SYNOPSIS
    Lists directory contents with color-coding.

    .DESCRIPTION
    This function lists directory contents with color-coding for different item types.
    It vaguely mimics the behavior of Unix 'ls' command.

    .PARAMETER Path
    Specifies the path to list. If not provided, it uses the current directory.

    .PARAMETER IncludeHidden
    Include hidden files and directories in the listing.

    .EXAMPLE
    Show-FilesUnixStyle

    .EXAMPLE
    Show-FilesUnixStyle -Path C:\Users -IncludeHidden
    #>

	param (
		[Parameter(Position = 0, ValueFromPipeline = $true)]
		[string[]]$Path = (Get-Location).Path,
		[Alias("a")]
		[switch]$IncludeHidden
	)

	Get-ChildItem -Path "$Path" -Force | ForEach-Object {
		if ($_.Attributes -band [System.IO.FileAttributes]::Hidden) {
			if (!$IncludeHidden) {
				return
			}
			$name = With-Black $_.Name
		}
		elseif ($_.Attributes -band [System.IO.FileAttributes]::System) {
			$name = With-Red $_.Name
		}
		elseif ($_.Attributes -band [System.IO.FileAttributes]::ReparsePoint) {
			$name = ((With-Blue $_.Name) + " → " + (Get-Item $_.FullName).Target)
		}
		elseif ($_ -is [System.IO.DirectoryInfo]) {
			$name = With-Yellow $_.Name
		}
		elseif ($_ -is [System.IO.FileInfo]) {
			$name = With-Cyan $_.Name
		}
		else {
			$name = $_.Name
		}

		if ($_ -is [System.IO.DirectoryInfo]) {
			$name += "/"
		}

		$name
	}
}
