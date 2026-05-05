using namespace System.Collections.Generic
using module ../src/SortOrder.psm1
using module ../src/SqlOrderHint.psm1

<#
.SYNOPSIS
	Tests the features of the `SqlOrderHint` class.
#>
Describe "SqlOrderHint" {
	Context "ImplicitConversion" {
		It "should create an order hint from the specified tuple" {
			[SqlOrderHint] $orderHint = "ID", [SortOrder]::Descending
			$orderHint.Column | Should -BeExactly "ID"
			$orderHint.SortOrder | Should -Be ([SortOrder]::Descending)
		}

		It "should create an order hint from the specified key/value pair" {
			[SqlOrderHint] $orderHint = [KeyValuePair[string, SortOrder]]::new("Name", [SortOrder]::Ascending)
			$orderHint.Column | Should -BeExactly "Name"
			$orderHint.SortOrder | Should -Be ([SortOrder]::Ascending)
		}
	}
}
