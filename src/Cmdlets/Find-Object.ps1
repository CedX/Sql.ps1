using namespace System.Data
using module ../SqlCommandBuilder.psm1
using module ../SqlOrderHintCollection.psm1

<#
.SYNOPSIS
	Finds either an entity with the specified primary key, or all entities.
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

		# Value indicating whether to find all entities.
		[Parameter(ParameterSetName = "All")]
		[switch] $All,

		# The primary key value.
		[Parameter(Mandatory, ParameterSetName = "Id", Position = 2, ValueFromPipeline)]
		[object] $Id,

		# The list of columns to select. By default, all columns.
		[ValidateNotNull()]
		[string[]] $Columns = @(),

		# The hints describing the sort order of columns.
		[Parameter(ParameterSetName = "All")]
		[SqlOrderHintCollection] $OrderBy,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	process {
		$builder = [SqlCommandBuilder]::new($Connection)

		if ($PSCmdlet.ParameterSetName -eq "All") {
			$statement = $builder.GetFindAllCommand($Class, $OrderBy, $Columns)
			$statement[0].Timeout = $Timeout
			$statement[0].Transaction = $Transaction
			Invoke-SqlQuery $Connection -As $Class -Command $statement[0]
		}
		else {
			$statement = $builder.GetFindCommand($Class, $Id, $Columns)
			$statement[0].Timeout = $Timeout
			$statement[0].Transaction = $Transaction
			Get-SqlSingle $Connection -As $Class -Command $statement[0] -ErrorAction Ignore -Parameters $statement[1]
		}
	}
}
