using namespace Belin.Sql
using namespace System.Data

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

		# An optional command builder used to build the SQL query to be executed.
		[SqlCommandBuilder] $Builder,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	begin {
		$Builder ??= New-CommandBuilder $Connection
	}

	process {
		$command = $Builder.GetInsertCommand($InputObject)
		$command.Item1.Timeout = $Timeout
		$command.Item1.Transaction = $Transaction

		$id = Get-Scalar $Connection -As ([long]) -Command $command.Item1 -Parameters $command.Item2
		$column = [SqlMapper]::Instance.GetTable($InputObject.GetType()).IdentityColumn
		if ($column) { $column.SetValue($InputObject, [SqlMapper]::Instance.ChangeType($id, $column)) }
		$id
	}
}
