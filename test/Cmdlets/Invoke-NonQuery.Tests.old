<#
.SYNOPSIS
	Tests the features of the `Invoke-NonQuery` cmdlet.
#>
Describe "Invoke-NonQuery" {
	BeforeAll { . "$PSScriptRoot/BeforeAll.ps1" }
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should return the number of rows affected by the SQL query" {
		$parameters = @{ Gender = "Balrog" }
		Get-SqlScalar $connection -Command "SELECT COUNT(*) FROM Characters" | Should -Be 16
		Invoke-SqlNonQuery $connection -Command "DELETE FROM Characters WHERE Gender = @Gender" -Parameters $parameters | Should -Be 2
		Get-SqlScalar $connection -Command "SELECT COUNT(*) FROM Characters" | Should -Be 14

		$parameters = @{ Gender = "Elf" }
		Invoke-SqlNonQuery $connection -Command "DELETE FROM Characters WHERE Gender = @Gender" -Parameters $parameters | Should -Be 3
		Get-SqlScalar $connection -Command "SELECT COUNT(*) FROM Characters" | Should -Be 11
	}
}
