using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis
using module ../SqlCommandBuilder.psm1
using module ../SqlMapper.psm1
using module ../SqlOrderHintCollection.psm1

<#
.SYNOPSIS
	Finds either an entity with the specified primary key, or all entities.
.OUTPUTS
	Either the entity with the specified primary key, or all entities.
#>
function Find-SqlObject {
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

		if ($All) {
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

<#
.SYNOPSIS
	Inserts the specified entity.
.INPUTS
	The entity to insert.
.OUTPUTS
	The generated primary key value.
#>
function Publish-SqlObject {
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
		$statement[0].Timeout = $Timeout
		$statement[0].Transaction = $Transaction

		$id = Get-SqlScalar $Connection -As ([long]) -Command $statement[0] -Parameters $statement[1]
		$column = [SqlMapper]::Instance.GetTable($InputObject.GetType()).IdentityColumn
		if ($column) { $column.SetValue($InputObject, [SqlMapper]::ChangeType($id, $column)) }
		$id
	}
}

<#
.SYNOPSIS
	Deletes the specified entity.
.INPUTS
	The entity to delete.
.OUTPUTS
	`$true` if the specified entity has been deleted, otherwise `$false`.
#>
function Remove-SqlObject {
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
		$statement[0].Timeout = $Timeout
		$statement[0].Transaction = $Transaction
		(Invoke-SqlNonQuery $Connection -Command $statement[0] -Parameters $statement[1]) -gt 0
	}
}

<#
.SYNOPSIS
	Checks whether an entity with the specified primary key exists.
.OUTPUTS
	`$true` if an entity with the specified primary key exists, otherwise `$false`.
#>
function Test-SqlObject {
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
		$statement[0].Timeout = $Timeout
		$statement[0].Transaction = $Transaction
		Get-SqlScalar $Connection -As ([bool]) -Command $statement[0] -Parameters $statement[1]
	}
}

<#
.SYNOPSIS
	Updates the specified entity.
.INPUTS
	The entity to update.
.OUTPUTS
	The number of rows affected.
#>
function Update-SqlObject {
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
		$statement[0].Timeout = $Timeout
		$statement[0].Transaction = $Transaction
		Invoke-SqlNonQuery $Connection -Command $statement[0] -Parameters $statement[1]
	}
}
