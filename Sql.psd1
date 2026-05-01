@{
	DefaultCommandPrefix = "Sql"
	ModuleVersion = "1.0.0"
	PowerShellVersion = "7.6"

	Author = "Cédric Belin <cedx@outlook.com>"
	CompanyName = "Cedric-Belin.fr"
	Copyright = "© Cédric Belin"
	Description = "A simple micro-ORM, based on ADO.NET and data annotations."
	GUID = "d2b1c123-e1bc-4cca-84c5-af102244e3c5"

	AliasesToExport = @()
	CmdletsToExport = @()
	VariablesToExport = @()

	FunctionsToExport = @(
		"Approve-Transaction"
		"Close-Connection"
		"Deny-Transaction"
		# "Find-Object"
		"Get-First"
		"Get-Mapper"
		"Get-Scalar"
		"Get-Single"
		"Invoke-NonQuery"
		"Invoke-Query"
		"New-Command"
		"New-Connection"
		"New-Parameter"
		"New-ParameterCollection"
		"New-Transaction"
		# "Publish-Object"
		# "Remove-Object"
		# "Test-Object"
		# "Update-Object"
	)

	NestedModules = @(
		"src/Cmdlets/Approve-Transaction.psm1"
		"src/Cmdlets/Close-Connection.psm1"
		"src/Cmdlets/Deny-Transaction.psm1"
		# "src/Cmdlets/Find-Object.psm1"
		"src/Cmdlets/Get-First.psm1"
		"src/Cmdlets/Get-Mapper.psm1"
		"src/Cmdlets/Get-Scalar.psm1"
		"src/Cmdlets/Get-Single.psm1"
		"src/Cmdlets/Invoke-NonQuery.psm1"
		"src/Cmdlets/Invoke-Query.psm1"
		"src/Cmdlets/New-Command.psm1"
		"src/Cmdlets/New-Connection.psm1"
		"src/Cmdlets/New-Parameter.psm1"
		"src/Cmdlets/New-ParameterCollection.psm1"
		"src/Cmdlets/New-Transaction.psm1"
		# "src/Cmdlets/Publish-Object.psm1"
		# "src/Cmdlets/Remove-Object.psm1"
		# "src/Cmdlets/Test-Object.psm1"
		# "src/Cmdlets/Update-Object.psm1"
	)

	PrivateData = @{
		PSData = @{
			LicenseUri = "https://github.com/cedx/sql.ps1/blob/main/License.md"
			ProjectUri = "https://github.com/cedx/sql.ps1"
			ReleaseNotes = "https://github.com/cedx/sql.ps1/releases"
			Tags = "ado.net", "data", "database", "mapper", "mapping", "orm", "query", "sql"
		}
	}
}
