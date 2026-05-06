using namespace System.Data

<#
.SYNOPSIS
	Closes the specified database connection.
.INPUTS
	The connection to the data source.
#>
function Close-Connection {
	[CmdletBinding()]
	[OutputType([void])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0, ValueFromPipeline)]
		[IDbConnection] $InputObject
	)

	process {
		$InputObject.Close()
	}
}
