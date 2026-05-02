using namespace System.Data
using module ../SqlCommand.psm1
using module ../SqlCommandBuilder.psm1

<#
.SYNOPSIS
	Finds an entity with the specified primary key.
.OUTPUTS
	The entity with the specified primary key, or `$null` if not found.
#>
function Find-Object {
	[CmdletBinding()]
	[OutputType([object])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The type of object to find.
		[Parameter(Mandatory, Position = 1)]
		[Type] $Class,

		# The primary key value.
		[Parameter(Mandatory, Position = 2, ValueFromPipeline)]
		[object] $Id,

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
		$statement = [SqlCommandBuilder]::new($Connection).GetFindCommand($Class, $Id, $Columns)

		$command = [SqlCommand]::new($statement.Item1.Text)
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction

		Get-SqlSingle $Connection -As $Class -Command $command -ErrorAction Ignore -Parameters $statement.Item2
	}
}
