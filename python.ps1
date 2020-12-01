$global:currentVenv = ""

enum PythonVenvStatus {
	inactive
	active
	activated
	deactivated
}

function ActivatePython () {
	if ($global:currentVenv) { & "$global:currentVenv\Scripts\Activate.ps1" }
}

function DeactivatePython () {
	if ($global:currentVenv) {deactivate}
}

function Try-ActivatePython () {
	$currentDir = (Get-Location).Path
	$venvDir = ""
	$venvDirs = ".venv", "venv"
	foreach ($dir in $venvDirs) {
		if (Test-Path "$currentDir\$dir" -PathType Container) {
			$venvDir = $dir
			break
		}
	}
	if (!$venvDir -and $global:currentVenv) {
		DeactivatePython
		$global:currentVenv = ""
		return [PythonVenvStatus]::deactivated
	}
	if (!$venvDir) {
		return [PythonVenvStatus]::inactive
	}
	if ($global:currentVenv) {
		return [PythonVenvStatus]::active
	}
	$global:currentVenv = "$currentDir\$venvDir"
	ActivatePython
	return [PythonVenvStatus]::activated
}
