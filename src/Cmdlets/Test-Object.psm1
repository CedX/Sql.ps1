using namespace System.Data
using module ../SqlCommand.psm1
using module ../SqlCommandBuilder.psm1

<#
.SYNOPSIS
	Checks whether an entity with the specified primary key exists.
.OUTPUTS
	`$true` if an entity with the specified primary key exists, otherwise `$false`.
#>
function Test-Object {
	[CmdletBinding()]
	[OutputType([bool])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The type of object to check.
		[Parameter(Mandatory, Position = 1)]
		[Type] $Class,

		# The primary key value.
		[Parameter(Mandatory, Position = 2, ValueFromPipeline)]
		[object] $Id,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	process {
		$statement = [SqlCommandBuilder]::new($Connection).GetExistsCommand($Class, $Id)

		$command = [SqlCommand]::new($statement.Item1.Text)
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction

		Get-Scalar $Connection -As ([bool]) -Command $command -Parameters $statement.Item2
	}
}
