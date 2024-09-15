function Edit-File {
	param (
		[Parameter(Mandatory = $true, Position = 0, ValueFromPipeline = $true)]
		[string[]]$Path,

		[Parameter(Mandatory = $false)]
		[DateTime]$Date = (Get-Date)
	)

	process {
		foreach ($file in $Path) {
			if (Test-Path -Path $file) {
                (Get-Item $file).LastWriteTime = $Date
			}
			else {
				New-Item -ItemType File -Path $file
                (Get-Item $file).LastWriteTime = $Date
			}
		}
	}
}
