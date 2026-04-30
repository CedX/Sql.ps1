<#
.SYNOPSIS
	Tests the features of the `Get-First` cmdlet.
#>
Describe "Get-First" {
	BeforeAll { . "$PSScriptRoot/BeforeAll.ps1" }
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should return the first record produced by the SQL query" {
		$sql = "SELECT * FROM Characters WHERE FullName = @FullName"
		$record = Get-SqlFirst $connection -As ([Character]) -Command $sql -Parameters @{ FullName = "Sauron" }
		$record.FirstName | Should -BeExactly Sauron
		$record.Gender | Should -Be ([CharacterGender]::DarkLord)
	}
}
