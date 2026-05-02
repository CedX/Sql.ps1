using namespace System.Data
using module ../SqlCommand.psm1
using module ../SqlCommandBuilder.psm1
using module ../SqlMapper.psm1

<#
.SYNOPSIS
	Inserts the specified entity.
.INPUTS
	The entity to insert.
.OUTPUTS
	The generated primary key value.
#>
function Publish-Object {
	[CmdletBinding()]
	[OutputType([long])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The entity to insert.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[object] $InputObject,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	process {
		$statement = [SqlCommandBuilder]::new($Connection).GetInsertCommand($InputObject)

		$command = [SqlCommand]::new($statement.Item1.Text)
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction

		$id = Get-Scalar $Connection -As ([long]) -Command $command -Parameters $statement.Item2
		$column = [SqlMapper]::Instance.GetTable($InputObject.GetType()).IdentityColumn
		if ($column) { $column.SetValue($InputObject, [SqlMapper]::ChangeType($id, $column)) }
		$id
	}
}
