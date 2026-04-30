using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

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

	begin {
		if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }
	}

	process {
		$instance = $InputObject -is [psobject] ? $InputObject.BaseObject : $InputObject
		$method = [ConnectionExtensions].GetMethod("Update").MakeGenericMethod($instance.GetType())
		$arguments = $Connection, $instance, $Columns, [CommandOptions]@{ Timeout = $Timeout; Transaction = $Transaction }
		$method.Invoke($null, $arguments)
	}
}
