using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Publish-Object` cmdlet.
#>
Describe "Publish-Object" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should insert the specified entity" {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Cédric'"
		Should-BeNull (Invoke-SqlQuery $connection -As ([Character]) -Command $sql)

		$record = [Character]@{ FirstName = "Cédric"; LastName = "Belin"; Gender = "Istari" }
		$record.Id | Should -Be 0
		Should-BeEmptyString $record.FullName

		$id = Publish-SqlObject $connection -InputObject $record
		$id | Should -BeGreaterThan 16
		$record.Id | Should -Be $id

		$records = Invoke-SqlQuery $connection -As ([Character]) -Command $sql
		Should-Be 1 $records.Count

		$cedric = $records[0]
		$cedric.Id | Should -Be $id
		$cedric.FullName | Should -BeExactly "Cédric Belin"
		$cedric.Gender | Should -Be $record.Gender
	}
}
