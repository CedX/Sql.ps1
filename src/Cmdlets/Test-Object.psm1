using namespace System.Data

<#
.SYNOPSIS
	Checks whether an entity with the specified primary key exists.
.OUTPUTS
	`$true` if an entity with the specified primary key exists, otherwise `$false`.
#>
function Test-Object {
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
		[Parameter(Mandatory, Position = 2)]
		[object] $Id,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("Positive")]
		[int] $Timeout = 30,

		# The transaction to use, if any.
		[IDbTransaction] $Transaction
	)

	if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }
	$method = [ConnectionExtensions].GetMethod("Exists").MakeGenericMethod($Class)
	$arguments = $Connection, $Id, [CommandOptions]@{ Timeout = $Timeout; Transaction = $Transaction }
	$method.Invoke($null, $arguments)
}
