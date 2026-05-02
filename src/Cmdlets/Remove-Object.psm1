using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis
using module ../SqlCommand.psm1
using module ../SqlCommandBuilder.psm1

<#
.SYNOPSIS
	Deletes the specified entity.
.INPUTS
	The entity to delete.
.OUTPUTS
	`$true` if the specified entity has been deleted, otherwise `$false`.
#>
function Remove-Object {
	[CmdletBinding()]
	[OutputType([bool])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The entity to delete.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[object] $InputObject,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	process {
		$statement = [SqlCommandBuilder]::new($Connection).GetDeleteCommand($InputObject)

		$command = [SqlCommand]::new($statement.Item1.Text)
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction

		(Invoke-NonQuery $Connection -Command $command -Parameters $statement.Item2) -gt 0
	}
}
