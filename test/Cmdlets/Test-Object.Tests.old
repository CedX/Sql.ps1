<#
.SYNOPSIS
	Tests the features of the `Test-Object` cmdlet.
#>
Describe "Test-Object" {
	BeforeAll { . "$PSScriptRoot/BeforeAll.ps1" }
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should delete the record with the specified identifier" {
		Test-SqlObject $connection -Class ([Character]) -Id 1 | Should -BeTrue
		Test-SqlObject $connection -Class ([Character]) -Id 666 | Should -BeFalse
	}
}
