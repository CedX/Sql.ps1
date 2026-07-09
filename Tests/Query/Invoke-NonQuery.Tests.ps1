using module ../../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `Invoke-NonQuery` cmdlet.
#>
Describe "Invoke-NonQuery" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should return the number of rows affected by the SQL query" {
		$parameters = @{ Gender = "Balrog" }
		Should-Be 16 (Get-SqlScalar $connection -Command "SELECT COUNT(*) FROM Characters")
		Should-Be 2 (Invoke-SqlNonQuery $connection -Command "DELETE FROM Characters WHERE Gender = @Gender" -Parameters $parameters)
		Should-Be 14 (Get-SqlScalar $connection -Command "SELECT COUNT(*) FROM Characters")

		$parameters = @{ Gender = "Elf" }
		Should-Be 3 (Invoke-SqlNonQuery $connection -Command "DELETE FROM Characters WHERE Gender = @Gender" -Parameters $parameters)
		Should-Be 11 (Get-SqlScalar $connection -Command "SELECT COUNT(*) FROM Characters")
	}
}
