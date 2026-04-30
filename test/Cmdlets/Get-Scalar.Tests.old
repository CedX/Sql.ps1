<#
.SYNOPSIS
	Tests the features of the `Get-Scalar` cmdlet.
#>
Describe "Get-Scalar" {
	BeforeAll { . "$PSScriptRoot/BeforeAll.ps1" }
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should return the single value produced by the SQL query" {
		$sql = "SELECT COUNT(*) FROM Characters WHERE Gender = @Gender"
		Get-SqlScalar $connection -Command $sql -Parameters @{ Gender = "Balrog" } | Should -Be 2

		$sql = "SELECT tbl_name FROM sqlite_schema WHERE type = @Type AND name = @Name"
		Get-SqlScalar $connection -Command $sql -Parameters @{ Name = "Characters"; Type = "table" } | Should -BeExactly Characters
	}
}
