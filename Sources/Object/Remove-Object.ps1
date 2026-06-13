using namespace Belin.Sql
using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

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
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The entity to delete.
		[Parameter(Mandatory, ParameterSetName = "InputObject", Position = 1, ValueFromPipeline)]
		[object] $InputObject,

		# The type of object to delete.
		[Parameter(Mandatory, ParameterSetName = "All", Position = 1)]
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
