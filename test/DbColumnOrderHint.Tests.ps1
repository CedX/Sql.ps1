using namespace System.Collections.Generic
using module ../src/DbColumnOrderHint.psm1
using module ../src/SortOrder.psm1

<#
.SYNOPSIS
	Tests the features of the `DbColumnOrderHint` class.
#>
Describe "DbColumnOrderHint" {
	Context "ImplicitConversion" {
		It "should create an order hint from the specified tuple" {
			[DbColumnOrderHint] $orderHint = "ID", [SortOrder]::Descending
			$orderHint.Column | Should -BeExactly "ID"
			$orderHint.SortOrder | Should -Be ([SortOrder]::Descending)
		}

		It "should create an order hint from the specified key/value pair" {
			[DbColumnOrderHint] $orderHint = [KeyValuePair[string, SortOrder]]::new("Name", [SortOrder]::Ascending)
			$orderHint.Column | Should -BeExactly "Name"
			$orderHint.SortOrder | Should -Be ([SortOrder]::Ascending)
		}
	}
}
