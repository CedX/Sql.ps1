using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Creates a new database connection.
.INPUTS
	The connection string used to open the database.
.OUTPUTS
	The newly created database connection.
#>
function New-Connection {
	[CmdletBinding()]
	[OutputType([System.Data.IDbConnection])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The type of connection class to instantiate.
		[Parameter(Mandatory, Position = 0)]
		[Type] $Type,

		# The connection string used to open the database.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[string] $ConnectionString,

		# Value indicating whether to open the connection.
		[switch] $Open
	)

	process {
		$connection = [IDbConnection] [Activator]::CreateInstance($Type, $ConnectionString)
		if ($Open) { $connection.Open() }
		$connection
	}
}
