using namespace Belin.Sql
using namespace System.Data

<#
.SYNOPSIS
	Executes a parameterized SQL query and returns a sequence of objects whose properties correspond to the columns.
.OUTPUTS
	The sequence of object tuples whose properties correspond to the columns.
#>
function Invoke-Query {
	[CmdletBinding()]
	[OutputType([System.Collections.Generic.IList[object]])]
	[OutputType([System.Collections.Generic.IList[System.Runtime.CompilerServices.ITuple]])]
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
		[ValidateCount(1, 7)]
		[Type[]] $As = @([psobject]),

		# The fields from which to split and read the next objects.
		[ValidateCount(0, 6)]
		[string[]] $SplitOn = @()
	)

	if ($As.Count -gt 1) { [DbConnectionExtensions]::Query($Connection, $As, $Command, $Parameters, $SplitOn) }
	else { [DbConnectionExtensions]::Query($Connection, $As[0], $Command, $Parameters) }
}
