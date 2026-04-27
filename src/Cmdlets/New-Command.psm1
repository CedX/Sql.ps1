using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Creates a new command associated with the specified connection.
.OUTPUTS
	The newly created command.
#>
function New-Command {
	[CmdletBinding()]
	[OutputType([System.Data.IDbCommand])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
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

		# Value indicating how the command is interpreted.
		[CommandType] $CommandType = [CommandType]::Text,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("Positive")]
		[int] $Timeout = 30,

		# The transaction to use, if any.
		[IDbTransaction] $Transaction
	)

	$commandOptions = [CommandOptions]@{ Timeout = $Timeout; Transaction = $Transaction; Type = $CommandType }
	[ConnectionExtensions]::CreateCommand($Connection, $Command, $Parameters, $commandOptions)
}
