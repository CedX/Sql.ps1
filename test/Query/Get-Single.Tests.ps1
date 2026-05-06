using module ../Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Get-Single` cmdlet.
#>
Describe "Get-Single" {
	BeforeAll { Import-Module "$PSScriptRoot/../../Sql.psd1" }
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should return the single record produced by the SQL query" {
		$sql = "SELECT * FROM Characters WHERE fullName = @FullName"
		$record = Get-SqlSingle $connection -As ([Character]) -Command $sql -Parameters @{ FullName = "Saruman" }
		$record.FirstName | Should -BeExactly Saruman
		$record.Gender | Should -Be ([CharacterGender]::Istari)
	}

	It "should throw an error if the query produces no results" {
		$sql = "SELECT * FROM Characters WHERE fullName = @FullName"
		{ Get-SqlSingle $connection -Command $sql -Parameters @{ FullName = "Cédric" } -ErrorAction Stop } | Should -Throw
	}

	It "should throw an error if the query produces more than one result" {
		$sql = "SELECT * FROM Characters WHERE gender = @Gender"
		{ Get-SqlSingle $connection -Command $sql -Parameters @{ Gender = "Human" } -ErrorAction Stop } | Should -Throw
	}
}
