using namespace System.Data

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
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The entity to insert.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[object] $InputObject,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("Positive")]
		[int] $Timeout = 30,

		# The transaction to use, if any.
		[IDbTransaction] $Transaction
	)

	begin {
		if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }
	}

	process {
		$instance = $InputObject -is [psobject] ? $InputObject.BaseObject : $InputObject
		$method = [ConnectionExtensions].GetMethod("Insert").MakeGenericMethod($instance.GetType())
		$arguments = $Connection, $instance, [CommandOptions]@{ Timeout = $Timeout; Transaction = $Transaction }
		$method.Invoke($null, $arguments)
	}
}
