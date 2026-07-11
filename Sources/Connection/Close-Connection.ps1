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
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[IDbConnection] $InputObject,

		# Value indicating whether the connection should also be disposed.
		[switch] $Dispose
	)

	process {
		try { $InputObject.Close() }
		catch { Write-Error $_ }
		finally { if ($Dispose) { $InputObject.Dispose() } }
	}
}
