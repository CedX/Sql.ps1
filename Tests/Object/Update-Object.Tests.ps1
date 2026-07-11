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
		Should-Be ([CharacterGender]::DarkLord) $sauron.Gender

		$sauron.LastName = "The big bad guy"
		$sauron.Gender = [CharacterGender]::Istari
		Should-Be 1 (Update-SqlObject $connection -InputObject $sauron)

		$sauron = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$sauron.FullName | Should -BeExactly "Sauron The big bad guy"
		Should-Be ([CharacterGender]::Istari) $sauron.Gender
	}

	It "should allow updating a specific set of columns" {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Saruman'"

		$saruman = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$saruman.FullName | Should -BeExactly Saruman
		Should-Be ([CharacterGender]::Istari) $saruman.Gender

		$saruman.LastName = "The traitor"
		$saruman.Gender = [CharacterGender]::DarkLord
		Should-Be 1 (Update-SqlObject $connection -InputObject $saruman -Columns gender)

		$saruman = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$saruman.FullName | Should -BeExactly Saruman
		Should-Be ([CharacterGender]::DarkLord) $saruman.Gender
	}
}
