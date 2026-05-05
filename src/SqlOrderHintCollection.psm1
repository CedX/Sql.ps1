using namespace System.Collections.Generic
using namespace System.Collections.Specialized
using module ./SortOrder.psm1
using module ./SqlOrderHint.psm1

<#
.SYNOPSIS
	A collection of hints describing the sort order of columns.
#>
class SqlOrderHintCollection: List[SqlOrderHint] {

	<#
	.SYNOPSIS
		Creates a new order hint collection.
	#>
	SqlOrderHintCollection(): base() {}

	<#
	.SYNOPSIS
		Creates a new order hint collection that contains the elements copied from the specified collection.
	.PARAMETER OrderHints
		The collection whose elements are copied to the order hint collection.
	#>
	SqlOrderHintCollection([SqlOrderHint[]] $OrderHints): base($OrderHints) {}

	<#
	.SYNOPSIS
		Gets the order hint with the specified column name.
	.PARAMETER Column
		The column name.
	.OUTPUTS
		The order hint with the specified column name, or `$null` if not found.
	#>
	[SqlOrderHint] get_Item([string] $Column) {
		$orderHint = $this.Find({ param ($orderHint) $orderHint.Column -eq $Column })
		if (-not $orderHint) { throw [KeyNotFoundException] $Column }
		return $orderHint
	}

	<#
	.SYNOPSIS
		Creates a new order hint collection from the specified array of column names.
	.PARAMETER Columns
		The array whose elements are copied to the order hint collection.
	.OUTPUTS
		The order hint collection corresponding to the specified array of column names.
	#>
	static [SqlOrderHintCollection] op_Implicit([string[]] $Columns) {
		$orderHintCollection = [SqlOrderHintCollection]::new()
		for ($index = 0; $index -lt $Columns.Count; $index++) { $orderHintCollection.Add([SqlOrderHint]::new($Columns[$index], [SortOrder]::Ascending)) }
		return $orderHintCollection
	}

	<#
	.SYNOPSIS
		Creates a new order hint collection from the specified dictionary of column names and orders.
	.PARAMETER OrderHints
		The dictionary whose elements are copied to the order hint collection.
	.OUTPUTS
		The order hint collection corresponding to the specified dictionary of column names and orders.
	#>
	static [SqlOrderHintCollection] op_Implicit([OrderedDictionary] $OrderHints) {
		$orderHintCollection = [SqlOrderHintCollection]::new()
		foreach ($key in $OrderHints.Keys) { $orderHintCollection.Add([SqlOrderHint]::new($key, $OrderHints.$key)) }
		return $orderHintCollection
	}

	<#
	.SYNOPSIS
		Gets a value indicating whether an order hint in this collection has the specified column name.
	.PARAMETER Column
		The column name.
	.OUTPUTS
		`$true` if this collection contains an order hint with the specified column name, otherwise `$false`.
	#>
	[bool] Contains([string] $Column) {
		return $this.Exists({ param ($orderHint) $orderHint.Column -eq $Column })
	}

	<#
	.SYNOPSIS
		Returns the index of the order hint with the specified column name.
	.PARAMETER Column
		The column name.
	.OUTPUTS
		The index of the order hint with the specified column name, or `-1` if not found.
	#>
	[int] IndexOf([string] $Column) {
		return $this.FindIndex({ param ($orderHint) $orderHint.Column -eq $Column })
	}

	<#
	.SYNOPSIS
		Removes the order hint with the specified column name from this collection.
	.PARAMETER Column
		The column name.
	#>
	[void] RemoveAt([string] $Column) {
		$this.RemoveAt($this.IndexOf($Column))
	}
}
