using namespace Belin.Sql
using namespace System.Data

<#
.SYNOPSIS
	Executes a parameterized SQL statement.
.OUTPUTS
	The number of rows affected.
#>
function Invoke-NonQuery {
	[CmdletBinding()]
	[OutputType([int])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The command to be executed.
		[Parameter(Mandatory, Position = 2)]
		[SqlCommand] $Command,

		# The parameters of the SQL statement.
		[Parameter(Position = 3)]
		[SqlParameterCollection] $Parameters
	)

	[DbConnectionExtensions]::Execute($Connection, $Command, $Parameters)
}
