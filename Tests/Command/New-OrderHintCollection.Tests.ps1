using namespace Belin.Sql
using namespace System.Collections.Generic

<#
.SYNOPSIS
	Tests the features of the `New-OrderHintCollection` cmdlet.
#>
Describe "New-OrderHintCollection" {
	It "should create an empty collection by default" {
		$collection = New-SqlOrderHintCollection
		Should-BeCollection $collection -Count 0
	}

	It "should create a collection from a single order hint" {
		$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending)
		Should-BeCollection $collection -Count 1

		$orderHint = $collection[0]
		Should-BeString ID $orderHint.Column -CaseSensitive
		Should-Be ([SortOrder]::Descending) $orderHint.SortOrder
	}

	It "should create a collection from an array of order hints" {
		$orderHints = (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
		$collection = New-SqlOrderHintCollection $orderHints
		Should-BeCollection $collection -Count 2

		$orderHint = $collection[-1]
		Should-BeString Name $orderHint.Column -CaseSensitive
		Should-Be ([SortOrder]::Ascending) $orderHint.SortOrder
	}

	Context "Contains" {
		It "should return `$true if the collection contains the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint Key)
			Should-BeTrue $collection.Contains("key")
			Should-BeTrue $collection.Contains("KEY")
		}

		It "should return `$false if the collection does not contain the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint Key)
			Should-BeFalse $collection.Contains("foo")
		}
	}

	Context "ImplicitConversion" {
		It "should create a collection from the specified array of column names" {
			[SqlOrderHintCollection] $collection = "ID", "Name"
			Should-BeCollection ("ID", "Name") $collection.PSForEach{ $_.Column }
			Should-BeCollection ([SortOrder]::Ascending, [SortOrder]::Ascending) $collection.PSForEach{ $_.SortOrder }
		}

		It "should create a collection from the specified list of column names" {
			[SqlOrderHintCollection] $collection = [List[string]]::new([string[]] ("ID", "Name"))
			Should-BeCollection ("ID", "Name") $collection.PSForEach{ $_.Column }
			Should-BeCollection ([SortOrder]::Ascending, [SortOrder]::Ascending) $collection.PSForEach{ $_.SortOrder }
		}

		It "should create a collection from the specified dictionary of column names and sort orders" {
			[SqlOrderHintCollection] $collection = [ordered]@{ ID = [SortOrder]::Descending; Name = [SortOrder]::Ascending }
			Should-BeCollection ("ID", "Name") $collection.PSForEach{ $_.Column }
			Should-BeCollection ([SortOrder]::Descending, [SortOrder]::Ascending) $collection.PSForEach{ $_.SortOrder }
		}
	}

	Context "Indexer" {
		It "should return the order hint with the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			$orderHint = $collection["id"]
			Should-BeString ID $orderHint.Column -CaseSensitive
			Should-Be ([SortOrder]::Descending) $orderHint.SortOrder
			Should-Be $orderHint $collection[0]
		}

		It "should return `$null, or throw an error, if the specified column name does not exist" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			Should-BeNull $collection["foo"]

			Set-StrictMode -Version Latest
			Should-Throw -ScriptBlock { $collection["foo"] }
			Set-StrictMode -Off
		}
	}

	Context "IndexOf" {
		It "should return the index if the order hint is found" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			Should-Be 0 $collection.IndexOf("id")
			Should-Be 1 $collection.IndexOf("name")
		}

		It "should return -1 if the order hint is not found" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			Should-Be -1 $collection.IndexOf("foo")
		}
	}

	Context "RemoveAt" {
		It "should remove the order hint with the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			Should-BeCollection $collection -Count 2
			$collection.RemoveAt("name")
			Should-BeCollection $collection -Count 1
			$collection.RemoveAt("id")
			Should-BeCollection $collection -Count 0
		}

		It "should throw an error if the specified column name does not exist" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			Should-Throw -ScriptBlock { $collection.RemoveAt("Foo") }
		}
	}
}
