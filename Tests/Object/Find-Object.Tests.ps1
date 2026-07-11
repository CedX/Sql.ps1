using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Find-Object` cmdlet.
#>
Describe "Find-Object" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	Context "All" {
		It "should return the complete list of entities, sorted by default according to the identity column" {
			$records = Find-SqlObject $connection -All -Class ([Character])
			Should-Be 16 $records.Count
			Should-Be 1 $records[0].Id
			$records[0].FullName | Should -BeExactly Aragorn
			Should-Be 16 $records[15].Id
			$records[15].FullName | Should -BeExactly Sauron
		}

		It "should allow sorting the results by a specific set of columns" {
			$records = Find-SqlObject $connection -All -Class ([Character]) -OrderBy ([ordered]@{ gender = "Ascending"; fullName = "Descending" })
			Should-Be 16 $records.Count
			Should-Be 11 $records[0].Id
			$records[0].FullName | Should -BeExactly Gothmog
			Should-Be 8 $records[15].Id
			$records[15].FullName | Should -BeExactly Gandalf
		}

		It "should allow selecting a specific set of columns" {
			$records = Find-SqlObject $connection -All -Class ([Character]) -Columns gender
			Should-Be 1 $records[0].Id
			Should-Be ([CharacterGender]::Human) $records[0].Gender
			$records[0].FullName | Should -BeNullOrEmpty
			Should-Be 16 $records[15].Id
			Should-Be ([CharacterGender]::DarkLord) $records[15].Gender
			$records[15].FullName | Should -BeNullOrEmpty
		}
	}

	Context "Id" {
		It "should find the entity with the specified identifier" {
			$record = Find-SqlObject $connection -Class ([Character]) -Id 2
			$record | Should -Not -BeNullOrEmpty
			Should-Be 2 $record.Id
			$record.FullName | Should -BeExactly Balin

			$record = Find-SqlObject $connection -Class ([Character]) -Id 14
			$record | Should -Not -BeNullOrEmpty
			Should-Be 14 $record.Id
			$record.FullName | Should -BeExactly "Sam Gamgee"
		}

		It "should allow selecting a specific set of columns" {
			$record = Find-SqlObject $connection -Class ([Character]) -Id 2 -Columns gender
			$record.FullName | Should -BeNullOrEmpty
			Should-Be ([CharacterGender]::Dwarf) $record.Gender

			$record = Find-SqlObject $connection -Class ([Character]) -Id 14 -Columns gender
			$record.FullName | Should -BeNullOrEmpty
			Should-Be ([CharacterGender]::Hobbit) $record.Gender
		}

		It "should return `$null if the entity is not found" {
			Find-SqlObject $connection -Class ([Character]) -Id 666 | Should -BeNullOrEmpty
		}
	}
}
