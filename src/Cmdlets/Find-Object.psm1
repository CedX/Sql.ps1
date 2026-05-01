using namespace System.Data

<#
.SYNOPSIS
	Finds an entity with the specified primary key.
.OUTPUTS
	The entity with the specified primary key, or `$null` if not found.
#>
function Find-Object {
	[CmdletBinding()]
	[OutputType([object])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The type of object to find.
		[Parameter(Mandatory, Position = 1)]
		[Type] $Class,

		# The primary key value.
		[Parameter(Mandatory, Position = 2)]
		[object] $Id,

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

	end {
		$method = [ConnectionExtensions].GetMethod("Find").MakeGenericMethod($Class)
		$arguments = $Connection, $Id, $Columns, [CommandOptions]@{ Timeout = $Timeout; Transaction = $Transaction }
		$method.Invoke($null, $arguments)
	}
}
