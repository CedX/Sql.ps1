using module ../Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Test-Object` cmdlet.
#>
Describe "Test-Object" {
	BeforeAll { Import-Module "$PSScriptRoot/../../Sql.psd1" }
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should delete the record with the specified identifier" {
		Test-SqlObject $connection -Class ([Character]) -Id 1 | Should -BeTrue
		Test-SqlObject $connection -Class ([Character]) -Id 666 | Should -BeFalse
	}
}
