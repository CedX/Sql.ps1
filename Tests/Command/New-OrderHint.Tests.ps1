using namespace Belin.Sql
using namespace System.Collections.Generic
using module ../../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `New-OrderHint` cmdlet.
#>
Describe "New-OrderHint" {
	Context "ImplicitConversion" {
		It "should create an order hint from the specified column name" {
			[SqlOrderHint] $orderHint = "Name"
			$orderHint.Column | Should -BeExactly Name
			$orderHint.SortOrder | Should -Be ([SortOrder]::Ascending)
		}

		It "should create an order hint from the specified tuple" {
			[SqlOrderHint] $orderHint = "ID", "Descending"
			$orderHint.Column | Should -BeExactly ID
			$orderHint.SortOrder | Should -Be ([SortOrder]::Descending)

			$orderHint = [ValueTuple]::Create("ID", [SortOrder]::Descending)
			$orderHint.Column | Should -BeExactly ID
			$orderHint.SortOrder | Should -Be ([SortOrder]::Descending)
		}

		It "should create an order hint from the specified key/value pair" {
			[SqlOrderHint] $orderHint = [KeyValuePair[string, SortOrder]]::new("Name", "Ascending")
			$orderHint.Column | Should -BeExactly Name
			$orderHint.SortOrder | Should -Be ([SortOrder]::Ascending)
		}
	}
}
