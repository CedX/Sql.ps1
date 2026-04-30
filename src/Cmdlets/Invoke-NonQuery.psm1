using namespace System.Data
using module ../SqlParameterCollection.psm1

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

	$commandOptions = [CommandOptions]@{ Timeout = $Timeout; Transaction = $Transaction; Type = $CommandType }
	[ConnectionExtensions]::Execute($Connection, $Command, $Parameters, $commandOptions)
}
