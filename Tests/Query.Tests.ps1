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
		Should-BeString Sauron $record.FirstName -CaseSensitive
		Should-Be ([CharacterGender]::DarkLord) $record.Gender
	}

	It "should throw an error if the query produces no results" {
		$sql = "SELECT * FROM Characters WHERE fullName = @FullName"
		Should-Throw -ScriptBlock { Get-SqlFirst $connection -Command $sql -Parameters @{ FullName = "Cédric" } -ErrorAction Stop }
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
		Should-Be 2 (Get-SqlScalar $connection -As ([int]) -Command $sql -Parameters @{ Gender = "Balrog" })

		$sql = "SELECT tbl_name FROM sqlite_schema WHERE type = @Type AND name = @Name"
		Should-BeString Characters (Get-SqlScalar $connection -As ([string]) -Command $sql -Parameters @{ Name = "Characters"; Type = "table" }) -CaseSensitive

		$sql = "SELECT tbl_name FROM sqlite_schema WHERE name = @Name"
		Should-BeNull (Get-SqlScalar $connection -As ([string]) -Command $sql -Parameters @{ Name = "FooBarBazQux" })
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
		Should-BeString Saruman $record.FirstName -CaseSensitive
		Should-Be ([CharacterGender]::Istari) $record.Gender
	}

	It "should throw an error if the query produces no results" {
		$sql = "SELECT * FROM Characters WHERE fullName = @FullName"
		Should-Throw -ScriptBlock { Get-SqlSingle $connection -Command $sql -Parameters @{ FullName = "Cédric" } -ErrorAction Stop }
	}

	It "should throw an error if the query produces more than one result" {
		$sql = "SELECT * FROM Characters WHERE gender = @Gender"
		Should-Throw -ScriptBlock { Get-SqlSingle $connection -Command $sql -Parameters @{ Gender = "Human" } -ErrorAction Stop }
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
		Should-Be 16 (Get-SqlScalar $connection -Command "SELECT COUNT(*) FROM Characters")
		Should-Be 2 (Invoke-SqlNonQuery $connection -Command "DELETE FROM Characters WHERE Gender = @Gender" -Parameters $parameters)
		Should-Be 14 (Get-SqlScalar $connection -Command "SELECT COUNT(*) FROM Characters")

		$parameters = @{ Gender = "Elf" }
		Should-Be 3 (Invoke-SqlNonQuery $connection -Command "DELETE FROM Characters WHERE Gender = @Gender" -Parameters $parameters)
		Should-Be 11 (Get-SqlScalar $connection -Command "SELECT COUNT(*) FROM Characters")
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
		Should-Be 3 $records.Count

		$elrond = $records[0]
		Should-BeString Elrond $elrond.FullName -CaseSensitive
		Should-Be ([CharacterGender]::Elf) $elrond.Gender

		$galadriel = $records[1]
		Should-BeString Galadriel $galadriel.FullName -CaseSensitive
		Should-Be ([CharacterGender]::Elf) $galadriel.Gender
	}

	It "should allow the data rows to be split into distinct objects" {
		$sql = "SELECT ID, firstName, lastName, ID, fullName, gender FROM Characters WHERE firstName = @FirstName"
		$records = Invoke-SqlQuery $connection -As ([psobject], [psobject]) -Command $sql -Parameters @{ FirstName = "Frodo" } -SplitOn id
		Should-Be 1 $records.Count

		$left = $records.Item1
		Should-Be 6 $left.ID
		Should-BeString Frodo $left.firstName -CaseSensitive
		Should-BeString Baggins $left.lastName -CaseSensitive
		Should-BeNull $left.fullName

		$right = $records.Item2
		Should-Be 6 $right.ID
		Should-BeString "Frodo Baggins" $right.fullName -CaseSensitive
		Should-BeString Hobbit $right.gender -CaseSensitive
		Should-BeNull $right.firstName
	}
}
