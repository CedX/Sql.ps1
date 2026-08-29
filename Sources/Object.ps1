using namespace Belin.Sql
using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

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

<#
.SYNOPSIS
	Counts all entities.
.INPUTS
	The type of object to count.
.OUTPUTS
	The total number of entities.
#>
function Measure-Object {
	[CmdletBinding()]
	[OutputType([int])]
	[SuppressMessage("PSAvoidOverwritingBuiltInCmdlets", "")]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The type of object to count.
		[Parameter(Mandatory, Position = 2, ValueFromPipeline)]
		[Type] $Class,

		# Value indicating whether to count all entities.
		[Parameter(Mandatory)]
		[switch] $All,

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
		if ($All) { [DbConnectionExtensions]::CountAll($Connection, $Class, $Timeout, $Transaction, $Builder) }
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
function Publish-Object {
	[CmdletBinding()]
	[OutputType([long])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The entity to insert.
		[Parameter(Mandatory, Position = 2, ValueFromPipeline)]
		[object] $InputObject,

		# An optional command builder used to build the SQL query to be executed.
		[SqlCommandBuilder] $Builder,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	begin { $Builder ??= New-CommandBuilder $Connection }
	process { [DbConnectionExtensions]::Insert($Connection, $InputObject, $Timeout, $Transaction, $Builder) }
}

<#
.SYNOPSIS
	Deletes either the specified entity, or all entities.
.INPUTS
	The entity to delete.
.OUTPUTS
	[bool] `$true` if the specified entity has been deleted, otherwise `$false`.
.OUTPUTS
	[void] None when the command has been invoked with the `-All` parameter.
#>
function Remove-Object {
	[CmdletBinding(DefaultParameterSetName = "InputObject")]
	[OutputType([bool])]
	[OutputType([void])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The entity to delete.
		[Parameter(Mandatory, ParameterSetName = "InputObject", Position = 2, ValueFromPipeline)]
		[object] $InputObject,

		# The type of object to delete.
		[Parameter(Mandatory, ParameterSetName = "All", Position = 2)]
		[Type] $Class,

		# Value indicating whether to delete all entities.
		[Parameter(ParameterSetName = "All")]
		[switch] $All,

		# Value indicating whether to truncate the underlying table.
		[Parameter(ParameterSetName = "All")]
		[switch] $Truncate,

		# An optional command builder used to build the SQL query to be executed.
		[SqlCommandBuilder] $Builder,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	begin { $Builder ??= New-CommandBuilder $Connection }
	process {
		if ($All) { [DbConnectionExtensions]::DeleteAll($Connection, $Class, $Truncate, $Timeout, $Transaction, $Builder) }
		else { [DbConnectionExtensions]::Delete($Connection, $InputObject, $Timeout, $Transaction, $Builder) -gt 0 }
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
function Test-Object {
	[CmdletBinding()]
	[OutputType([bool])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The type of object to check.
		[Parameter(Mandatory, Position = 2)]
		[Type] $Class,

		# The primary key value.
		[Parameter(Mandatory, Position = 3, ValueFromPipeline)]
		[object] $Id,

		# An optional command builder used to build the SQL query to be executed.
		[SqlCommandBuilder] $Builder,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction
	)

	begin { $Builder ??= New-CommandBuilder $Connection }
	process { [DbConnectionExtensions]::Exists($Connection, $Class, $Id, $Timeout, $Transaction, $Builder) }
}

<#
.SYNOPSIS
	Updates the specified entity.
.INPUTS
	The entity to update.
.OUTPUTS
	The number of rows affected.
#>
function Update-Object {
	[CmdletBinding()]
	[OutputType([int])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The entity to update.
		[Parameter(Mandatory, Position = 2, ValueFromPipeline)]
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

	begin { $Builder ??= New-CommandBuilder $Connection }
	process { [DbConnectionExtensions]::Update($Connection, $InputObject, $Columns, $Timeout, $Transaction, $Builder) }
}
