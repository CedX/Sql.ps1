using module ../Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Publish-Object` cmdlet.
#>
Describe "Publish-Object" {
	BeforeAll { Import-Module "$PSScriptRoot/../../Sql.psd1" }
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should insert the specified record" {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Cédric'"
		Invoke-SqlQuery $connection -As ([Character]) -Command $sql | Should -BeNullOrEmpty

		$record = [Character]@{ FirstName = "Cédric"; LastName = "Belin"; Gender = "Istari" }
		$record.Id | Should -Be 0
		$record.FullName | Should -BeNullOrEmpty

		$id = Publish-SqlObject $connection -InputObject $record
		$id | Should -BeGreaterThan 16
		$record.Id | Should -Be $id

		$records = Invoke-SqlQuery $connection -As ([Character]) -Command $sql
		$records | Should -HaveCount 1

		$cedric = $records[0]
		$cedric.Id | Should -Be $id
		$cedric.FullName | Should -BeExactly "Cédric Belin"
		$cedric.Gender | Should -Be $record.Gender
	}
}
