using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis
using module ../SqlCommand.psm1
using module ../SqlCommandBuilder.psm1

<#
.SYNOPSIS
	Updates the specified entity.
.INPUTS
	The entity to update.
.OUTPUTS
	The number of rows affected.
#>
function Update-Object {
	[CmdletBinding()]
	[OutputType([int])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The entity to update.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[object] $InputObject,

		# The list of columns to select. By default, all columns.
		[ValidateNotNull()]
		[string[]] $Columns = @(),

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	process {
		$statement = [SqlCommandBuilder]::new($Connection).GetUpdateCommand($InputObject, $Columns)

		$command = [SqlCommand]::new($statement.Item1.Text)
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction

		Invoke-NonQuery $Connection -Command $command -Parameters $statement.Item2
	}
}
