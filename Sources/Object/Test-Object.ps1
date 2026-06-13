using namespace Belin.Sql
using namespace System.Data

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

	begin { $Builder ??= New-CommandBuilder $Connection }
	process { [DbConnectionExtensions]::Exists($Connection, $Class, $Id, $Timeout, $Transaction, $Builder) }
}
