<#
.SYNOPSIS
	Tests the features of the `Find-Object` cmdlet.
#>
Describe "Find-Object" {
	BeforeAll { . "$PSScriptRoot/BeforeAll.ps1" }
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should find the record with the specified identifier" {
		$record = Find-SqlObject $connection -Class ([Character]) -Id 2
		$record | Should -Not -Be $null
		$record.Id | Should -Be 2
		$record.FullName | Should -BeExactly "Balin"

		$record = Find-SqlObject $connection -Class ([Character]) -Id 2 -Columns gender
		$record.FullName | Should -Be ""
		$record.Gender | Should -Be ([CharacterGender]::Dwarf)

		Find-SqlObject $connection -Class ([Character]) -Id 666 | Should -Be $null
	}
}
