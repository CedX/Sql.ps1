using namespace System.Data
using namespace System.Dynamic

<#
.SYNOPSIS
	An array of types representing the number, order, and type of the parameters of the underlying method to invoke.
#>
$ParameterTypes = [IDbConnection], [string], [ParameterCollection], [CommandOptions]

<#
.SYNOPSIS
	Executes a parameterized SQL query and returns the first row.
.OUTPUTS
	The first row.
#>
function Get-First {
	[CmdletBinding()]
	[OutputType([object])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The SQL query to be executed.
		[Parameter(Mandatory, Position = 1)]
		[string] $Command,

		# The parameters of the SQL query.
		[Parameter(Position = 2)]
		[ParameterCollection] $Parameters = @(),

		# The type of objects to return.
		[Type] $As = [ExpandoObject],

		# Value indicating how the command is interpreted.
		[CommandType] $CommandType = [CommandType]::Text,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("Positive")]
		[int] $Timeout = 30,

		# The transaction to use, if any.
		[IDbTransaction] $Transaction
	)

	try {
		$method = [ConnectionExtensions].GetMethod("QueryFirst", 1, $Script:ParameterTypes).MakeGenericMethod($As)
		$arguments = $Connection, $Command, $Parameters, [CommandOptions]@{ Timeout = $Timeout; Transaction = $Transaction; Type = $CommandType }
		$method.Invoke($null, $arguments)
	}
	catch [InvalidOperationException] {
		Write-Error $_.Exception
	}
}
