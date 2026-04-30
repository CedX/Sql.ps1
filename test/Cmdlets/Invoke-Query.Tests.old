<#
.SYNOPSIS
	Tests the features of the `Invoke-Query` cmdlet.
#>
Describe "Invoke-Query" {
	BeforeAll { . "$PSScriptRoot/BeforeAll.ps1" }
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should return the records produced by the SQL query" {
		$sql = "SELECT * FROM Characters WHERE Gender = @Gender ORDER BY FullName"
		$records = Invoke-SqlQuery $connection -As ([Character]) -Command $sql -Parameters @{ Gender = "Elf" }
		$records | Should -HaveCount 3

		$elrond = $records[0]
		$elrond.FullName | Should -BeExactly Elrond
		$elrond.Gender | Should -Be ([CharacterGender]::Elf)

		$galadriel = $records[1]
		$galadriel.FullName | Should -BeExactly Galadriel
		$galadriel.Gender | Should -Be ([CharacterGender]::Elf)
	}
}
