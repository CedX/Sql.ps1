using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis
using module ../SqlCommandBuilder.psm1
using module ../SqlMapper.psm1
using module ../SqlOrderHintCollection.psm1

<#
.SYNOPSIS
	Finds either an entity with the specified primary key, or all entities.
.INPUTS
	The primary key value.
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

		# The primary key value.
		[Parameter(Mandatory, ParameterSetName = "Id", Position = 2, ValueFromPipeline)]
		[object] $Id,

		# Value indicating whether to find all entities.
		[Parameter(ParameterSetName = "All")]
		[switch] $All,

		# An optional command builder used to build the SQL query to be executed.
		[SqlCommandBuilder] $Builder,

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

	begin {
		$Builder ??= [SqlCommandBuilder]::new($Connection)
	}

	process {
		if ($All) {
			$command, $parameters = $Builder.GetFindAllCommand($Class, $OrderBy, $Columns)
			$command.Timeout = $Timeout
			$command.Transaction = $Transaction
			Invoke-SqlQuery $Connection -As $Class -Command $command
		}
		else {
			$command, $parameters = $Builder.GetFindCommand($Class, $Id, $Columns)
			$command.Timeout = $Timeout
			$command.Transaction = $Transaction
			Get-SqlSingle $Connection -As $Class -Command $command -ErrorAction Ignore -Parameters $parameters
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

		# An optional command builder used to build the SQL query to be executed.
		[SqlCommandBuilder] $Builder,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	begin {
		$Builder ??= [SqlCommandBuilder]::new($Connection)
	}

	process {
		$command, $parameters = $Builder.GetInsertCommand($InputObject)
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction

		$id = Get-SqlScalar $Connection -As ([long]) -Command $command -Parameters $parameters
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

		# An optional command builder used to build the SQL query to be executed.
		[SqlCommandBuilder] $Builder,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	begin {
		$Builder ??= [SqlCommandBuilder]::new($Connection)
	}

	process {
		$command, $parameters = $Builder.GetDeleteCommand($InputObject)
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction
		(Invoke-SqlNonQuery $Connection -Command $command -Parameters $parameters) -gt 0
	}
}

<#
.SYNOPSIS
	Checks whether an entity with the specified primary key exists.
.INPUTS
	The primary key value.
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

		# An optional command builder used to build the SQL query to be executed.
		[SqlCommandBuilder] $Builder,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	begin {
		$Builder ??= [SqlCommandBuilder]::new($Connection)
	}

	process {
		$command, $parameters = $Builder.GetExistsCommand($Class, $Id)
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction
		Get-SqlScalar $Connection -As ([bool]) -Command $command -Parameters $parameters
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

		# An optional command builder used to build the SQL query to be executed.
		[SqlCommandBuilder] $Builder,

		# The list of columns to update. By default, all columns.
		[ValidateNotNull()]
		[string[]] $Columns = @(),

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	begin {
		$Builder ??= [SqlCommandBuilder]::new($Connection)
	}

	process {
		$command, $parameters = $Builder.GetUpdateCommand($InputObject, $Columns)
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction
		Invoke-SqlNonQuery $Connection -Command $command -Parameters $parameters
	}
}
