using module ../Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Get-First` cmdlet.
#>
Describe "Get-First" {
	BeforeAll { Import-Module "$PSScriptRoot/../../Sql.psd1" }
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should return the first record produced by the SQL query" {
		$sql = "SELECT * FROM Characters WHERE fullName = @FullName"
		$record = Get-SqlFirst $connection -As ([Character]) -Command $sql -Parameters @{ FullName = "Sauron" }
		$record.FirstName | Should -BeExactly Sauron
		$record.Gender | Should -Be ([CharacterGender]::DarkLord)
	}

	It "should throw an error if the query produces no results" {
		$sql = "SELECT * FROM Characters WHERE fullName = @FullName"
		{ Get-SqlFirst $connection -Command $sql -Parameters @{ FullName = "Cédric" } -ErrorAction Stop } | Should -Throw
	}
}
