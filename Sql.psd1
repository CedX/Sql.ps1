@{
	DefaultCommandPrefix = "Sql"
	ModuleVersion = "3.1.0"
	PowerShellVersion = "7.6"
	RootModule = "Sources/Main.psm1"

	Author = "Cédric Belin <cedx@outlook.com>"
	CompanyName = "Cedric-Belin.fr"
	Copyright = "© Cédric Belin"
	Description = "A simple micro-ORM, based on ADO.NET and data annotations."
	GUID = "d2b1c123-e1bc-4cca-84c5-af102244e3c5"

	AliasesToExport = @()
	CmdletsToExport = @()
	RequiredAssemblies = , "Binaries/Belin.Sql.dll"
	VariablesToExport = @()

	FunctionsToExport = @(
		"Close-Connection"
		"Complete-Transaction"
		"Find-Object"
		"Get-First"
		"Get-Mapper"
		"Get-Scalar"
		"Get-Single"
		"Invoke-NonQuery"
		"Invoke-Query"
		"Measure-Object"
		"New-Command"
		"New-CommandBuilder"
		"New-Connection"
		"New-OrderHint"
		"New-OrderHintCollection"
		"New-Parameter"
		"New-ParameterCollection"
		"Open-Connection"
		"Publish-Object"
		"Remove-Object"
		"Start-Transaction"
		"Test-Object"
		"Undo-Transaction"
		"Update-Object"
	)

	PrivateData = @{
		PSData = @{
			LicenseUri = "https://github.com/CedX/Sql.ps1/blob/main/License.md"
			ProjectUri = "https://github.com/CedX/Sql.ps1"
			ReleaseNotes = "https://github.com/CedX/Sql.ps1/releases"
			Tags = "ado.net", "data", "database", "mapper", "mapping", "orm", "query", "sql"
		}
	}
}
