using namespace Belin.Sql
using namespace System.Data

<#
.SYNOPSIS
	Executes a parameterized SQL query that selects a single value.
.OUTPUTS
	The first column of the first row.
#>
function Get-Scalar {
	[CmdletBinding()]
	[OutputType([object])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The command to be executed.
		[Parameter(Mandatory, Position = 2)]
		[SqlCommand] $Command,

		# The parameters of the SQL statement.
		[Parameter(Position = 3)]
		[SqlParameterCollection] $Parameters,

		# The type of object to return.
		[ValidateNotNull()]
		[Type] $As = [object]
	)

	[DbConnectionExtensions]::ExecuteScalar($Connection, $As, $Command, $Parameters)
}
