using namespace Belin.Sql
using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Creates a new command.
.INPUTS
	The text of the SQL statement.
.OUTPUTS
	The newly created command.
#>
function New-Command {
	[CmdletBinding()]
	[OutputType([Belin.Sql.SqlCommand])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The text of the SQL statement.
		[Parameter(Mandatory, Position = 0, ValueFromPipeline)]
		[string] $Text,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction,

		# Value indicating how the command is interpreted.
		[CommandType] $Type = [CommandType]::Text
	)

	process {
		$command = [SqlCommand]::new($Text)
		# TODO ???? $command.NoEnumerate = $true
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction
		$command.Type = $Type
		$command
	}
}
