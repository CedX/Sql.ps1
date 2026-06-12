using namespace Belin.Sql

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
