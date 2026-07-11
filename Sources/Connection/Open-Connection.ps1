using namespace System.Data

<#
.SYNOPSIS
	Opens the specified database connection.
.INPUTS
	The connection to the data source.
#>
function Open-Connection {
	[CmdletBinding()]
	[OutputType([void])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[IDbConnection] $InputObject
	)

	process {
		$InputObject.Open()
	}
}
