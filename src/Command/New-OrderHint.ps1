using namespace System.Diagnostics.CodeAnalysis
using module ../SortOrder.psm1
using module ../SqlOrderHint.psm1

<#
.SYNOPSIS
	Creates a new order hint.
.OUTPUTS
	The newly created order hint.
#>
function New-SqlOrderHint {
	[CmdletBinding()]
	[OutputType([SqlOrderHint])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The name of the column for which the hint is being provided.
		[Parameter(Mandatory, Position = 0, ValueFromPipeline)]
		[string] $Column,

		# The sort order of the column.
		[Parameter(Position = 1)]
		[SortOrder] $SortOrder = [SortOrder]::Ascending
	)

	process {
		[SqlOrderHint]::new($Column, $SortOrder)
	}
}
