using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis
using module ../SqlCommand.psm1
using module ../SqlParameterCollection.psm1

<#
.SYNOPSIS
	Creates a new command.
.OUTPUTS
	The newly created command.
#>
function New-Command {
	[CmdletBinding()]
	[OutputType([SqlCommand])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The text of the SQL statement.
		[Parameter(Mandatory, Position = 0, ValueFromPipeline)]
		[string] $Text,

		# The parameters of the SQL statement.
		[Parameter(Position = 1)]
		[ValidateNotNull()]
		[SqlParameterCollection] $Parameters = @(),

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction,

		# Value indicating how the command is interpreted.
		[CommandType] $Type = [CommandType]::Text
	)

	process {
		$command = [SqlCommand]::new($Text, $Parameters)
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction
		$command.Text = $Text
		$command
	}
}
