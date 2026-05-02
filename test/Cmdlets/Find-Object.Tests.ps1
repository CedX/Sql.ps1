using module ../Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Find-Object` cmdlet.
#>
Describe "Find-Object" {
	BeforeAll { Import-Module "$PSScriptRoot/../../Sql.psd1" }
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should find the record with the specified identifier" {
		$record = Find-SqlObject $connection -Class ([Character]) -Id 2
		$record | Should -Not -BeNullOrEmpty
		$record.Id | Should -Be 2
		$record.FullName | Should -BeExactly Balin

		$record = Find-SqlObject $connection -Class ([Character]) -Id 2 -Columns gender
		$record.FullName | Should -BeNullOrEmpty
		$record.Gender | Should -Be ([CharacterGender]::Dwarf)

		$record = Find-SqlObject $connection -Class ([Character]) -Id 14
		$record | Should -Not -BeNullOrEmpty
		$record.Id | Should -Be 14
		$record.FullName | Should -BeExactly "Sam Gamgee"

		$record = Find-SqlObject $connection -Class ([Character]) -Id 14 -Columns gender
		$record.FullName | Should -BeNullOrEmpty
		$record.Gender | Should -Be ([CharacterGender]::Hobbit)
	}

	It "should return `$null if the record is not found" {
		Find-SqlObject $connection -Class ([Character]) -Id 666 | Should -BeNullOrEmpty
	}
}
