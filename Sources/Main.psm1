# Load all scripts.
Get-ChildItem $PSScriptRoot -File -Filter *.ps1 -Recurse | ForEach-Object { . $_.FullName }
