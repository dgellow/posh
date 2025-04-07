function Start-VsDevEnv {
	<#
    .SYNOPSIS
        Launches a Visual Studio Dev env while preserving the current working directory.

    .DESCRIPTION
        Find the latest VS installation folder and setup a dev env with all necessary build tools,
        compiler paths, and env vars.

    .NOTES
        Requires vswhere.exe to be available in the system path.
    #>

	param(
		[switch]$Debug = $false
	)

	if ( $Debug ) {
		$DebugPreference = "Continue"
	}

	$originalLocation = Get-Location
	Write-Debug "Current directory: $originalLocation"

	$vsInstallPath = vswhere.exe -latest -format json | ConvertFrom-Json | Select-Object -ExpandProperty installationPath
	Write-Debug "VS Install Path: $vsInstallPath"

	$launchPath = Join-Path $vsInstallPath "Common7\Tools\Launch-VsDevShell.ps1"
	Write-Debug "Launch Path: $launchPath"

	try {
		if (Test-Path $launchPath) {
			Write-Debug "Launching VS Dev prompt..."
			& $launchPath -SkipAutomaticLocation

			Write-Host "`n✨ Visual Studio env ready" -ForegroundColor Cyan
			Write-Host "`nCompilers and tools:" -ForegroundColor Yellow
			Write-Host "   C++ Compiler: " -NoNewline
			Write-Host (Get-Command cl.exe).Path -ForegroundColor Green
			Write-Host "   CMake: " -NoNewline
			Write-Host (Get-Command cmake.exe).Path -ForegroundColor Green

			Write-Host "`nEnvironment paths:" -ForegroundColor Yellow
			Write-Host "   VS Install: " -NoNewline
			Write-Host "$env:VSINSTALLDIR" -ForegroundColor Green
			Write-Host "   VC Tools: " -NoNewline
			Write-Host "$env:VCToolsVersion" -ForegroundColor Green
			Write-Host "   Windows SDK: " -NoNewline
			Write-Host "$env:WindowsSdkDir" -ForegroundColor Green
			Write-Host ""
		}
		else {
			Write-Host "Could not find Launch-VsDevShell.ps1 at expected location: $launchPath"
			return $false
		}
	}
	finally {
		# Ensure we return to the original directory, in case Launch-VsDevShell.ps1 failed while in a different location
		Set-Location -Path $originalLocation.Path -ErrorAction SilentlyContinue
	}
}
