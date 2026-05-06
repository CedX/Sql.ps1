using namespace System.Diagnostics.CodeAnalysis
using module ../SqlOrderHint.psm1
using module ../SqlOrderHintCollection.psm1

<#
.SYNOPSIS
	Creates a new order hint collection.
.OUTPUTS
	The newly created order hint collection.
#>
function New-SqlOrderHintCollection {
	[CmdletBinding()]
	[OutputType([SqlOrderHintCollection])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The collection whose elements are copied to the order hint collection.
		[Parameter(Position = 0, ValueFromPipeline)]
		[ValidateNotNull()]
		[SqlOrderHint[]] $OrderHints = @()
	)

	process {
		[SqlOrderHintCollection]::new($OrderHints)
	}
}
