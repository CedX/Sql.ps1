using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Update-Object` cmdlet.
#>
Describe "Update-Object" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should update the specified entity" {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Sauron'"

		$sauron = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$sauron.FullName | Should -BeExactly Sauron
		$sauron.Gender | Should -Be ([CharacterGender]::DarkLord)

		$sauron.LastName = "The big bad guy"
		$sauron.Gender = [CharacterGender]::Istari
		Update-SqlObject $connection -InputObject $sauron | Should -Be 1

		$sauron = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$sauron.FullName | Should -BeExactly "Sauron The big bad guy"
		$sauron.Gender | Should -Be ([CharacterGender]::Istari)
	}

	It "should allow updating a specific set of columns" {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Saruman'"

		$saruman = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$saruman.FullName | Should -BeExactly Saruman
		$saruman.Gender | Should -Be ([CharacterGender]::Istari)

		$saruman.LastName = "The traitor"
		$saruman.Gender = [CharacterGender]::DarkLord
		Update-SqlObject $connection -InputObject $saruman -Columns gender | Should -Be 1

		$saruman = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$saruman.FullName | Should -BeExactly Saruman
		$saruman.Gender | Should -Be ([CharacterGender]::DarkLord)
	}
}
