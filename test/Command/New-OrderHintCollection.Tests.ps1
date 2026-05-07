using module ../../Sql.psd1
using module ../../src/SortOrder.psm1

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
		$collection | Should -HaveCount 1

		$orderHint = $collection[0]
		$orderHint.Column | Should -BeExactly ID
		$orderHint.SortOrder | Should -Be ([SortOrder]::Descending)
	}

	It "should create a collection from an array of order hints" {
		$orderHints = (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name Ascending)
		$collection = New-SqlOrderHintCollection $orderHints
		$collection | Should -HaveCount 2

		$orderHint = $collection[$collection.Count - 1]
		$orderHint.Column | Should -BeExactly Name
		$orderHint.SortOrder | Should -Be ([SortOrder]::Ascending)
	}
}
