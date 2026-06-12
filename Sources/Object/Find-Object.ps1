using namespace Belin.Sql
using namespace System.Data

<#
.SYNOPSIS
	Finds either an entity with the specified primary key, or all entities.
.INPUTS
	The primary key value.
.OUTPUTS
	Either the entity with the specified primary key, or all entities.
#>
function Find-Object {
	[CmdletBinding(DefaultParameterSetName = "Id")]
	[OutputType([object])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The type of object to find.
		[Parameter(Mandatory, Position = 1)]
		[Type] $Class,

		# The primary key value.
		[Parameter(Mandatory, ParameterSetName = "Id", Position = 2, ValueFromPipeline)]
		[object] $Id,

		# Value indicating whether to find all entities.
		[Parameter(ParameterSetName = "All")]
		[switch] $All,

		# The hints describing the sort order of columns.
		[Parameter(ParameterSetName = "All")]
		[SqlOrderHintCollection] $OrderBy,

		# An optional command builder used to build the SQL query to be executed.
		[SqlCommandBuilder] $Builder,

		# The list of columns to select. By default, all columns.
		[ValidateNotNull()]
		[string[]] $Columns = @(),

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
		if ($All) {
			$command = $Builder.GetFindAllCommand($Class, $OrderBy, $Columns)
			$command.Item1.Timeout = $Timeout
			$command.Item1.Transaction = $Transaction
			Invoke-Query $Connection -As $Class -Command $command.Item1
		}
		else {
			$command = $Builder.GetFindCommand($Class, $Id, $Columns)
			$command.Item1.Timeout = $Timeout
			$command.Item1.Transaction = $Transaction
			Get-Single $Connection -As $Class -Command $command.Item1 -ErrorAction Ignore -Parameters $command.Item2
		}
	}
}
