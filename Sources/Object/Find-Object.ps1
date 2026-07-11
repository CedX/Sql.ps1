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
	[OutputType([System.Collections.Generic.IList[object]])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The type of object to find.
		[Parameter(Mandatory, Position = 2)]
		[Type] $Class,

		# The primary key value.
		[Parameter(Mandatory, ParameterSetName = "Id", Position = 3, ValueFromPipeline)]
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

	begin { $Builder ??= New-CommandBuilder $Connection }
	process {
		if ($All) { [DbConnectionExtensions]::FindAll($Connection, $Class, $OrderBy, $Columns, $Timeout, $Transaction, $Builder) }
		else { [DbConnectionExtensions]::Find($Connection, $Class, $Id, $Columns, $Timeout, $Transaction, $Builder) }
	}
}
