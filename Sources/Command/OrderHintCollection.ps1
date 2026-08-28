using namespace Belin.Sql
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Creates a new order hint.
.INPUTS
	The name of the column for which the hint is being provided.
.OUTPUTS
	The newly created order hint.
#>
function New-OrderHint {
	[CmdletBinding()]
	[OutputType([Belin.Sql.SqlOrderHint])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The name of the column for which the hint is being provided.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[string] $Column,

		# The sort order of the column.
		[Parameter(Position = 2)]
		[SortOrder] $SortOrder = [SortOrder]::Ascending
	)

	process {
		[SqlOrderHint]::new($Column, $SortOrder)
	}
}

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
