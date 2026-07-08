using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Test-Object` cmdlet.
#>
Describe "Test-Object" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should `$true if the specified identifier exists" {
		Test-SqlObject $connection -Class ([Character]) -Id 1 | Should-BeTrue
	}

	It "should `$false if the specified identifier does not exist" {
		Test-SqlObject $connection -Class ([Character]) -Id 666 | Should-BeFalse
	}
}
