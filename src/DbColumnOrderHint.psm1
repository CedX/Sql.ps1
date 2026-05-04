using namespace System.Collections.Generic
using module ./SortOrder.psm1

<#
.SYNOPSIS
	Defines the sort order for a database column.
#>
class DbColumnOrderHint {

	<#
	.SYNOPSIS
		The name of the column for which the hint is being provided.
	#>
	[ValidateNotNullOrWhiteSpace()]
	[string] $Column

	<#
	.SYNOPSIS
		The sort order of the column.
	#>
	[SortOrder] $SortOrder

	<#
	.SYNOPSIS
		Creates a new order hint.
	.PARAMETER Column
		The name of the column for which the hint is being provided.
	#>
	DbColumnOrderHint([string] $Column) {
		$this.Column = $Column
		$this.SortOrder = [SortOrder]::Ascending
	}

	<#
	.SYNOPSIS
		Creates a new order hint.
	.PARAMETER Column
		The name of the column for which the hint is being provided.
	.PARAMETER SortOrder
		The sort order of the column.
	#>
	DbColumnOrderHint([string] $Column, [SortOrder] $SortOrder) {
		$this.Column = $Column
		$this.SortOrder = $SortOrder
	}

	<#
	.SYNOPSIS
		Creates a new order hint from the specified key/value pair.
	.PARAMETER OrderHint
		The key/value pair providing the column name and its sort order.
	.OUTPUTS
		The order hint corresponding to the specified key/value pair.
	#>
	static [DbColumnOrderHint] op_Implicit([KeyValuePair[string, SortOrder]] $OrderHint) {
		return [DbColumnOrderHint]::new($OrderHint.Key, $OrderHint.Value)
	}
}
