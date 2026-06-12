using namespace Belin.Sql
using namespace System.Data

<#
.SYNOPSIS
	Executes a parameterized SQL query and returns the single row.
.OUTPUTS
	The single row.
#>
function Get-Single {
	[CmdletBinding()]
	[OutputType([object])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The command to be executed.
		[Parameter(Mandatory, Position = 1)]
		[SqlCommand] $Command,

		# The parameters of the SQL statement.
		[Parameter(Position = 2)]
		[SqlParameterCollection] $Parameters,

		# The type of objects to return.
		[ValidateNotNull()]
		[Type] $As = [psobject]
	)

	try { [DbConnectionExtensions]::QuerySingle($Connection, $As, $Command, $Parameters) }
	catch [InvalidOperationException] { Write-Error $_ }
}
