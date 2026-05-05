using namespace System.Data
using module ../src/SortOrder.psm1
using module ../src/SqlOrderHint.psm1
using module ../src/SqlOrderHintCollection.psm1

<#
.SYNOPSIS
	Tests the features of the `SqlOrderHintCollection` class.
#>
Describe "SqlOrderHintCollection" {
	Context "Constructor" {
		It "should create an empty collection by default" {
			$collection = [SqlOrderHintCollection]::new()
			$collection | Should -BeNullOrEmpty
		}

		It "should create a collection from a single order hint" {
			$collection = [SqlOrderHintCollection]::new([SqlOrderHint]::new("ID", [SortOrder]::Descending))
			$collection | Should -HaveCount 1

			$orderHint = $collection[0]
			$orderHint.Column | Should -BeExactly "ID"
			$orderHint.SortOrder | Should -Be ([SortOrder]::Descending)
		}

		It "should create a collection from an array of order hints" {
			$orderHints = @(
				[SqlOrderHint]::new("ID", [SortOrder]::Descending)
				[SqlOrderHint]::new("Name", [SortOrder]::Ascending)
			)

			$collection = [SqlOrderHintCollection]::new($orderHints)
			$collection | Should -HaveCount 2

			$orderHint = $collection[$collection.Count - 1]
			$orderHint.Column | Should -BeExactly "Name"
			$orderHint.SortOrder | Should -Be ([SortOrder]::Ascending)
		}
	}

	Context "Contains" {
		It "should return `$true if the collection contains the specified column name" {
			$collection = [SqlOrderHintCollection]::new([SqlOrderHint]::new("Key", [SortOrder]::Ascending))
			$collection.Contains("key") | Should -BeTrue
			$collection.Contains("KEY") | Should -BeTrue
		}

		It "should return `$false if the collection does not contain the specified column name" {
			$collection = [SqlOrderHintCollection]::new([SqlOrderHint]::new("Key", [SortOrder]::Ascending))
			$collection.Contains("foo") | Should -BeFalse
		}
	}

	Context "ImplicitConversion" {
		It "should create a collection from the specified array of column names" {
			[SqlOrderHintCollection] $collection = "ID", "Name"
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
			$collection = [SqlOrderHintCollection]::new((("ID", [SortOrder]::Descending), ("Name", [SortOrder]::Ascending)))
			$orderHint = $collection["id"]
			$orderHint.Column | Should -BeExactly ID
			$orderHint.SortOrder | Should -Be ([SortOrder]::Descending)
			$collection[0] | Should -Be $orderHint
		}

		It "should return `$null, or throw an error, if the specified column name does not exist" {
			$collection = [SqlOrderHintCollection]::new((("ID", [SortOrder]::Descending), ("Name", [SortOrder]::Ascending)))
			$collection["foo"] | Should -BeNullOrEmpty

			Set-StrictMode -Version Latest
			{ $collection["foo"] } | Should -Throw
			Set-StrictMode -Off
		}
	}

	Context "IndexOf" {
		It "should return the index if the order hint is found" {
			$collection = [SqlOrderHintCollection]::new((("ID", [SortOrder]::Descending), ("Name", [SortOrder]::Ascending)))
			$collection.IndexOf("id") | Should -Be 0
			$collection.IndexOf("name") | Should -Be 1
		}

		It "should return -1 if the order hint is not found" {
			$collection = [SqlOrderHintCollection]::new((("ID", [SortOrder]::Descending), ("Name", [SortOrder]::Ascending)))
			$collection.IndexOf("foo") | Should -Be -1
		}
	}

	Context "RemoveAt" {
		It "should remove the order hint with the specified column name" {
			$collection = [SqlOrderHintCollection]::new((("ID", [SortOrder]::Descending), ("Name", [SortOrder]::Ascending)))
			$collection | Should -HaveCount 2
			$collection.RemoveAt("name")
			$collection | Should -HaveCount 1
			$collection.RemoveAt("id")
			$collection | Should -BeNullOrEmpty
		}

		It "should throw an error if the specified column name does not exist" {
			$collection = [SqlOrderHintCollection]::new((("ID", [SortOrder]::Descending), ("Name", [SortOrder]::Ascending)))
			{ $collection.RemoveAt("Foo") } | Should -Throw
		}
	}
}
