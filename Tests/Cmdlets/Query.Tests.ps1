using module ../../Sql.psd1
using module ../Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Get-SqlFirst` cmdlet.
#>
Describe "Get-SqlFirst" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

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

<#
.SYNOPSIS
	Tests the features of the `Get-SqlScalar` cmdlet.
#>
Describe "Get-SqlScalar" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should return the single value produced by the query" {
		$sql = "SELECT COUNT(*) FROM Characters WHERE gender = @Gender"
		Get-SqlScalar $connection -As ([int]) -Command $sql -Parameters @{ Gender = "Balrog" } | Should -Be 2

		$sql = "SELECT tbl_name FROM sqlite_schema WHERE type = @Type AND name = @Name"
		Get-SqlScalar $connection -As ([string]) -Command $sql -Parameters @{ Name = "Characters"; Type = "table" } | Should -BeExactly Characters
	}
}

<#
.SYNOPSIS
	Tests the features of the `Get-SqlSingle` cmdlet.
#>
Describe "Get-SqlSingle" {
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

<#
.SYNOPSIS
	Tests the features of the `Invoke-SqlNonQuery` cmdlet.
#>
Describe "Invoke-SqlNonQuery" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

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

<#
.SYNOPSIS
	Tests the features of the `Invoke-SqlQuery` cmdlet.
#>
Describe "Invoke-SqlQuery" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should return the records produced by the SQL query" {
		$sql = "SELECT * FROM Characters WHERE gender = @Gender ORDER BY fullName"
		$records = Invoke-SqlQuery $connection -As ([Character]) -Command $sql -Parameters @{ Gender = "Elf" }
		$records | Should -HaveCount 3

		$elrond = $records[0]
		$elrond.FullName | Should -BeExactly Elrond
		$elrond.Gender | Should -Be ([CharacterGender]::Elf)

		$galadriel = $records[1]
		$galadriel.FullName | Should -BeExactly Galadriel
		$galadriel.Gender | Should -Be ([CharacterGender]::Elf)
	}

	It "should allow the data rows to be split into distinct objects" {
		$sql = "SELECT ID, firstName, lastName, ID, fullName, gender FROM Characters WHERE firstName = @FirstName"
		$records = Invoke-SqlQuery $connection -As ([psobject], [psobject]) -Command $sql -Parameters @{ FirstName = "Frodo" } -SplitOn id
		$records | Should -HaveCount 1

		$left = $records[0]
		$left.ID | Should -Be 6
		$left.firstName | Should -BeExactly Frodo
		$left.lastName | Should -BeExactly Baggins
		$left.fullName | Should -BeNullOrEmpty

		$right = $records[1]
		$right.ID | Should -Be 6
		$right.fullName | Should -BeExactly "Frodo Baggins"
		$right.gender | Should -BeExactly Hobbit
		$right.firstName | Should -BeNullOrEmpty
	}
}
