@{
	ModuleVersion = "1.3.0"
	PowerShellVersion = "7.6"
	RootModule = "Sources/Main.psm1"

	Author = "Cédric Belin <cedx@outlook.com>"
	CompanyName = "Cedric-Belin.fr"
	Copyright = "© Cédric Belin"
	Description = "A simple micro-ORM, based on ADO.NET and data annotations."
	GUID = "d2b1c123-e1bc-4cca-84c5-af102244e3c5"

	AliasesToExport = @()
	CmdletsToExport = @()
	VariablesToExport = @()

	FunctionsToExport = @(
		"Approve-SqlTransaction"
		"Close-SqlConnection"
		"Deny-SqlTransaction"
		"Find-SqlObject"
		"Get-SqlFirst"
		"Get-SqlMapper"
		"Get-SqlScalar"
		"Get-SqlSingle"
		"Invoke-SqlNonQuery"
		"Invoke-SqlQuery"
		"New-SqlCommand"
		"New-SqlCommandBuilder"
		"New-SqlConnection"
		"New-SqlOrderHint"
		"New-SqlOrderHintCollection"
		"New-SqlParameter"
		"New-SqlParameterCollection"
		"New-SqlTransaction"
		"Publish-SqlObject"
		"Remove-SqlObject"
		"Test-SqlObject"
		"Update-SqlObject"
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
