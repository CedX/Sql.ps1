using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Invoke-Query` cmdlet.
#>
Describe "Invoke-Query" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should return the records produced by the SQL query" {
		$sql = "SELECT * FROM Characters WHERE gender = @Gender ORDER BY fullName"
		$records = Invoke-SqlQuery $connection -As ([Character]) -Command $sql -Parameters @{ Gender = "Elf" }
		Should-Be 3 $records.Count

		$elrond = $records[0]
		$elrond.FullName | Should -BeExactly Elrond
		Should-Be ([CharacterGender]::Elf) $elrond.Gender

		$galadriel = $records[1]
		$galadriel.FullName | Should -BeExactly Galadriel
		Should-Be ([CharacterGender]::Elf) $galadriel.Gender
	}

	It "should allow the data rows to be split into distinct objects" {
		$sql = "SELECT ID, firstName, lastName, ID, fullName, gender FROM Characters WHERE firstName = @FirstName"
		$records = Invoke-SqlQuery $connection -As ([psobject], [psobject]) -Command $sql -Parameters @{ FirstName = "Frodo" } -SplitOn id
		Should-Be 1 $records.Count

		$left = $records.Item1
		Should-Be 6 $left.ID
		$left.firstName | Should -BeExactly Frodo
		$left.lastName | Should -BeExactly Baggins
		Should-BeNull $left.fullName

		$right = $records.Item2
		Should-Be 6 $right.ID
		$right.fullName | Should -BeExactly "Frodo Baggins"
		$right.gender | Should -BeExactly Hobbit
		Should-BeNull $right.firstName
	}
}
