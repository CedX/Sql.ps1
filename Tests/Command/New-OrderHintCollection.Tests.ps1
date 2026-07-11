using namespace Belin.Sql
using namespace System.Collections.Generic

<#
.SYNOPSIS
	Tests the features of the `New-OrderHintCollection` cmdlet.
#>
Describe "New-OrderHintCollection" {
	It "should create an empty collection by default" {
		$collection = New-SqlOrderHintCollection
		$collection | Should -BeNullOrEmpty
	}

	It "should create a collection from a single order hint" {
		$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending)
		Should-Be 1 $collection.Count

		$orderHint = $collection[0]
		$orderHint.Column | Should -BeExactly ID
		Should-Be ([SortOrder]::Descending) $orderHint.SortOrder
	}

	It "should create a collection from an array of order hints" {
		$orderHints = (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
		$collection = New-SqlOrderHintCollection $orderHints
		Should-Be 2 $collection.Count

		$orderHint = $collection[$collection.Count - 1]
		$orderHint.Column | Should -BeExactly Name
		Should-Be ([SortOrder]::Ascending) $orderHint.SortOrder
	}

	Context "Contains" {
		It "should return `$true if the collection contains the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint Key)
			$collection.Contains("key") | Should-BeTrue
			$collection.Contains("KEY") | Should-BeTrue
		}

		It "should return `$false if the collection does not contain the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint Key)
			$collection.Contains("foo") | Should-BeFalse
		}
	}

	Context "ImplicitConversion" {
		It "should create a collection from the specified array of column names" {
			[SqlOrderHintCollection] $collection = "ID", "Name"
			$collection.PSForEach{ $_.Column } | Should -Be "ID", "Name"
			$collection.PSForEach{ $_.SortOrder } | Should -Be ([SortOrder]::Ascending, [SortOrder]::Ascending)
		}

		It "should create a collection from the specified list of column names" {
			[SqlOrderHintCollection] $collection = [List[string]]::new([string[]] ("ID", "Name"))
			$collection.PSForEach{ $_.Column } | Should -Be "ID", "Name"
			$collection.PSForEach{ $_.SortOrder } | Should -Be ([SortOrder]::Ascending, [SortOrder]::Ascending)
		}

		It "should create a collection from the specified dictionary of column names and sort orders" {
			[SqlOrderHintCollection] $collection = [ordered]@{ ID = [SortOrder]::Descending; Name = [SortOrder]::Ascending }
			$collection.PSForEach{ $_.Column } | Should -Be "ID", "Name"
			$collection.PSForEach{ $_.SortOrder } | Should -Be ([SortOrder]::Descending, [SortOrder]::Ascending)
		}
	}

	Context "Indexer" {
		It "should return the order hint with the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			$orderHint = $collection["id"]
			$orderHint.Column | Should -BeExactly ID
			Should-Be ([SortOrder]::Descending) $orderHint.SortOrder
			$collection[0] | Should -Be $orderHint
		}

		It "should return `$null, or throw an error, if the specified column name does not exist" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			$collection["foo"] | Should -BeNullOrEmpty

			Set-StrictMode -Version Latest
			Should-Throw -ScriptBlock { $collection["foo"] }
			Set-StrictMode -Off
		}
	}

	Context "IndexOf" {
		It "should return the index if the order hint is found" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			$collection.IndexOf("id") | Should -Be 0
			$collection.IndexOf("name") | Should -Be 1
		}

		It "should return -1 if the order hint is not found" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			$collection.IndexOf("foo") | Should -Be -1
		}
	}

	Context "RemoveAt" {
		It "should remove the order hint with the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			Should-Be 2 $collection.Count
			$collection.RemoveAt("name")
			Should-Be 1 $collection.Count
			$collection.RemoveAt("id")
			$collection | Should -BeNullOrEmpty
		}

		It "should throw an error if the specified column name does not exist" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			Should-Throw -ScriptBlock { $collection.RemoveAt("Foo") }
		}
	}
}
