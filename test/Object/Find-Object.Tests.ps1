using module ../Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Find-Object` cmdlet.
#>
Describe "Find-Object" {
	BeforeAll { Import-Module "$PSScriptRoot/../../Sql.psd1" }
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	Context "All" {
		It "should return the complete list of entities, sorted by default according to the identity column" {
			$records = Find-SqlObject $connection -All -Class ([Character])
			$records | Should -HaveCount 16
			$records[0].Id | Should -Be 1
			$records[0].FullName | Should -BeExactly "Aragorn"
			$records[15].Id | Should -Be 16
			$records[15].FullName | Should -BeExactly "Sauron"
		}

		It "should allow sorting the results by a specific set of columns" {
			$records = Find-SqlObject $connection -All -Class ([Character]) -OrderBy ([ordered]@{ gender = "Ascending"; fullName = "Descending" })
			$records | Should -HaveCount 16
			$records[0].Id | Should -Be 11
			$records[0].FullName | Should -BeExactly "Gothmog"
			$records[15].Id | Should -Be 8
			$records[15].FullName | Should -BeExactly "Gandalf"
		}

		It "should allow selecting a specific set of columns" {
			$records = Find-SqlObject $connection -All -Class ([Character]) -Columns "gender"
			$records[0].Id | Should -Be 1
			$records[0].Gender | Should -Be ([CharacterGender]::Human)
			$records[0].FullName | Should -BeNullOrEmpty
			$records[15].Id | Should -Be 16
			$records[15].Gender | Should -Be ([CharacterGender]::DarkLord)
			$records[15].FullName | Should -BeNullOrEmpty
		}
	}

	Context "Id" {
		It "should find the record with the specified identifier" {
			$record = Find-SqlObject $connection -Class ([Character]) -Id 2
			$record | Should -Not -BeNullOrEmpty
			$record.Id | Should -Be 2
			$record.FullName | Should -BeExactly Balin

			$record = Find-SqlObject $connection -Class ([Character]) -Id 14
			$record | Should -Not -BeNullOrEmpty
			$record.Id | Should -Be 14
			$record.FullName | Should -BeExactly "Sam Gamgee"
		}

		It "should allow selecting a specific set of columns" {
			$record = Find-SqlObject $connection -Class ([Character]) -Id 2 -Columns gender
			$record.FullName | Should -BeNullOrEmpty
			$record.Gender | Should -Be ([CharacterGender]::Dwarf)

			$record = Find-SqlObject $connection -Class ([Character]) -Id 14 -Columns gender
			$record.FullName | Should -BeNullOrEmpty
			$record.Gender | Should -Be ([CharacterGender]::Hobbit)
		}

		It "should return `$null if the record is not found" {
			Find-SqlObject $connection -Class ([Character]) -Id 666 | Should -BeNullOrEmpty
		}
	}
}
