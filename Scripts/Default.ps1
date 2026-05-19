& "$PSScriptRoot/Clean.ps1"
& "$PSScriptRoot/Version.ps1"
if (-not $Release) { & "$PSScriptRoot/Build.ps1" }
