using namespace Belin.Sql
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Creates a new order hint collection.
.INPUTS
	The collection whose elements are copied to the order hint collection.
.OUTPUTS
	The newly created order hint collection.
#>
function New-OrderHintCollection {
	[CmdletBinding()]
	[OutputType([Belin.Sql.SqlOrderHintCollection])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The collection whose elements are copied to the order hint collection.
		[Parameter(Position = 1, ValueFromPipeline)]
		[ValidateNotNull()]
		[SqlOrderHint[]] $OrderHints = @()
	)

	process {
		Write-Output ([SqlOrderHintCollection]::new($OrderHints)) -NoEnumerate
	}
}
