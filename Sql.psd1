@{
	DefaultCommandPrefix = "Sql"
	ModuleVersion = "4.0.0"
	PowerShellVersion = "7.6"
	RootModule = "Binaries/Belin.Sql.PowerShell.dll"

	Author = "Cédric Belin <cedx@outlook.com>"
	CompanyName = "Cedric-Belin.fr"
	Copyright = "© Cédric Belin"
	Description = "A simple micro-ORM, based on ADO.NET and data annotations."
	GUID = "d2b1c123-e1bc-4cca-84c5-af102244e3c5"

	AliasesToExport = @()
	RequiredAssemblies = , "Binaries/Belin.Sql.dll"
	VariablesToExport = @()

	CmdletsToExport = @(
		"Complete-Transaction"
		"Get-Mapper"
		"Start-Transaction"
		"Undo-Transaction"
	)

	FunctionsToExport = @(
		"Close-Connection"
		"New-Connection"
		"Open-Connection"
		"Find-Object"
		"Get-First"
		"Get-Scalar"
		"Get-Single"
		"Invoke-NonQuery"
		"Invoke-Query"
		"Measure-Object"
		"New-Command"
		"New-CommandBuilder"
		"New-OrderHint"
		"New-OrderHintCollection"
		"New-Parameter"
		"New-ParameterCollection"
		"Publish-Object"
		"Remove-Object"
		"Test-Object"
		"Update-Object"
	)

	RequiredModules = @(
		@{ ModuleName = "Belin.FSharp"; ModuleVersion = "10.1.401" }
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
