using namespace System.Data
using module ../SqlParameterCollection.psm1

<#
.SYNOPSIS
	An array of types representing the number, order, and type of the parameters of the underlying method to invoke.
#>
$ParameterTypes = [IDbConnection], [string], [SqlParameterCollection], [CommandOptions]

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
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The SQL query to be executed.
		[Parameter(Mandatory, Position = 1)]
		[string] $Command,

		# The parameters of the SQL query.
		[Parameter(Position = 2)]
		[SqlParameterCollection] $Parameters = @(),

		# Value indicating how the command is interpreted.
		[CommandType] $CommandType = [CommandType]::Text,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("Positive")]
		[int] $Timeout = 30,

		# The transaction to use, if any.
		[IDbTransaction] $Transaction
	)

	if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }

	$method = [ConnectionExtensions].GetMethod("ExecuteScalar", 1, $Script:ParameterTypes).MakeGenericMethod([object])
	$arguments = $Connection, $Command, $Parameters, [CommandOptions]@{ Timeout = $Timeout; Transaction = $Transaction; Type = $CommandType }
	$method.Invoke($null, $arguments)
}
