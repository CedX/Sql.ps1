using module ../../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `Get-Scalar` cmdlet.
#>
Describe "Get-Scalar" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should return the single value produced by the query" {
		$sql = "SELECT COUNT(*) FROM Characters WHERE gender = @Gender"
		Get-SqlScalar $connection -As ([int]) -Command $sql -Parameters @{ Gender = "Balrog" } | Should -Be 2

		$sql = "SELECT tbl_name FROM sqlite_schema WHERE type = @Type AND name = @Name"
		Get-SqlScalar $connection -As ([string]) -Command $sql -Parameters @{ Name = "Characters"; Type = "table" } | Should -BeExactly Characters

		$sql = "SELECT tbl_name FROM sqlite_schema WHERE name = @Name"
		Should-BeNull (Get-SqlScalar $connection -As ([string]) -Command $sql -Parameters @{ Name = "FooBarBazQux" })
	}
}
