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
			Should-BeString Name $orderHint.Column -CaseSensitive
			Should-Be ([SortOrder]::Ascending) $orderHint.SortOrder
		}

		It "should create an order hint from the specified array" {
			[SqlOrderHint] $orderHint = "ID", "Descending"
			Should-BeString ID $orderHint.Column -CaseSensitive
			Should-Be ([SortOrder]::Descending) $orderHint.SortOrder
		}

		It "should create an order hint from the specified tuple" {
			[SqlOrderHint] $orderHint = [ValueTuple]::Create("ID", [SortOrder]::Descending)
			Should-BeString ID $orderHint.Column -CaseSensitive
			Should-Be ([SortOrder]::Descending) $orderHint.SortOrder
		}

		It "should create an order hint from the specified key/value pair" {
			[SqlOrderHint] $orderHint = [KeyValuePair[string, SortOrder]]::new("Name", "Ascending")
			Should-BeString Name $orderHint.Column -CaseSensitive
			Should-Be ([SortOrder]::Ascending) $orderHint.SortOrder
		}
	}
}
