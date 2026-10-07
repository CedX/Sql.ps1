using module ../Sql.psd1
using module ./Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Get-First` cmdlet.
#>
Describe "Get-First" {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should return the first record produced by the SQL query" {
		$sql = "SELECT * FROM Characters WHERE fullName = @FullName"
		$record = Get-SqlFirst $connection -As ([Character]) -Command $sql -Parameters @{ FullName = "Sauron" }
		$record.FirstName | Should-BeString "Sauron" -CaseSensitive
		$record.Gender | Should-Be ([CharacterGender]::DarkLord)
	}

	It "should throw an error if the query produces no results" {
		$sql = "SELECT * FROM Characters WHERE fullName = @FullName"
		{ Get-SqlFirst $connection -Command $sql -Parameters @{ FullName = "Cédric" } -ErrorAction Stop } | Should-Throw
	}
}

<#
.SYNOPSIS
	Tests the features of the `Get-Scalar` cmdlet.
#>
Describe "Get-Scalar" {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should return the single value produced by the query" {
		$sql = "SELECT COUNT(*) FROM Characters WHERE gender = @Gender"
		Get-SqlScalar $connection -As ([int]) -Command $sql -Parameters @{ Gender = "Balrog" } | Should-Be 2

		$sql = "SELECT tbl_name FROM sqlite_schema WHERE type = @Type AND name = @Name"
		Get-SqlScalar $connection -As ([string]) -Command $sql -Parameters @{ Name = "Characters"; Type = "table" } | Should-BeString "Characters" -CaseSensitive

		$sql = "SELECT tbl_name FROM sqlite_schema WHERE name = @Name"
		Get-SqlScalar $connection -As ([string]) -Command $sql -Parameters @{ Name = "FooBarBazQux" } | Should-BeNull
	}
}

<#
.SYNOPSIS
	Tests the features of the `Get-Single` cmdlet.
#>
Describe "Get-Single" {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should return the single record produced by the SQL query" {
		$sql = "SELECT * FROM Characters WHERE fullName = @FullName"
		$record = Get-SqlSingle $connection -As ([Character]) -Command $sql -Parameters @{ FullName = "Saruman" }
		$record.FirstName | Should-BeString "Saruman" -CaseSensitive
		$record.Gender | Should-Be ([CharacterGender]::Istari)
	}

	It "should throw an error if the query produces no results" {
		$sql = "SELECT * FROM Characters WHERE fullName = @FullName"
		{ Get-SqlSingle $connection -Command $sql -Parameters @{ FullName = "Cédric" } -ErrorAction Stop } | Should-Throw
	}

	It "should throw an error if the query produces more than one result" {
		$sql = "SELECT * FROM Characters WHERE gender = @Gender"
		{ Get-SqlSingle $connection -Command $sql -Parameters @{ Gender = "Human" } -ErrorAction Stop } | Should-Throw
	}
}

<#
.SYNOPSIS
	Tests the features of the `Invoke-NonQuery` cmdlet.
#>
Describe "Invoke-NonQuery" {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should return the number of rows affected by the SQL query" {
		$parameters = @{ Gender = "Balrog" }
		Get-SqlScalar $connection -Command "SELECT COUNT(*) FROM Characters" | Should-Be 16
		Invoke-SqlNonQuery $connection -Command "DELETE FROM Characters WHERE Gender = @Gender" -Parameters $parameters | Should-Be 2
		Get-SqlScalar $connection -Command "SELECT COUNT(*) FROM Characters" | Should-Be 14

		$parameters = @{ Gender = "Elf" }
		Invoke-SqlNonQuery $connection -Command "DELETE FROM Characters WHERE Gender = @Gender" -Parameters $parameters | Should-Be 3
		Get-SqlScalar $connection -Command "SELECT COUNT(*) FROM Characters" | Should-Be 11
	}
}

<#
.SYNOPSIS
	Tests the features of the `Invoke-Query` cmdlet.
#>
Describe "Invoke-Query" {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should return the records produced by the SQL query" {
		$sql = "SELECT * FROM Characters WHERE gender = @Gender ORDER BY fullName"
		$records = Invoke-SqlQuery $connection -As ([Character]) -Command $sql -Parameters @{ Gender = "Elf" }
		$records.Count | Should-Be 3

		$elrond = $records[0]
		$elrond.FullName | Should-BeString "Elrond" -CaseSensitive
		$elrond.Gender | Should-Be ([CharacterGender]::Elf)

		$galadriel = $records[1]
		$galadriel.FullName | Should-BeString "Galadriel" -CaseSensitive
		$galadriel.Gender | Should-Be ([CharacterGender]::Elf)
	}

	It "should allow the data rows to be split into distinct objects" {
		$sql = "SELECT ID, firstName, lastName, ID, fullName, gender FROM Characters WHERE firstName = @FirstName"
		$records = Invoke-SqlQuery $connection -As ([psobject], [psobject]) -Command $sql -Parameters @{ FirstName = "Frodo" } -SplitOn id
		$records.Count | Should-Be 1

		$left = $records.Item1
		$left.ID | Should-Be 6
		$left.firstName | Should-BeString "Frodo" -CaseSensitive
		$left.lastName | Should-BeString "Baggins" -CaseSensitive
		$left.fullName | Should-BeNull

		$right = $records.Item2
		$right.ID | Should-Be 6
		$right.fullName | Should-BeString "Frodo Baggins" -CaseSensitive
		$right.gender | Should-BeString "Hobbit" -CaseSensitive
		$right.firstName | Should-BeNull
	}
}
