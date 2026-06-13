using namespace Belin.Sql
using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

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
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The type of object to count.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
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

	begin { $Builder ??= New-CommandBuilder $Connection }
	process { [DbConnectionExtensions]::CountAll($Connection, $Class, $Timeout, $Transaction, $Builder) }
}
