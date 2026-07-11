using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Measure-Object` cmdlet.
#>
Describe "Measure-Object" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	Context "All" {
		It "should return the total number of entities from the underlying table" {
			Should-Be 16 (Measure-SqlObject $connection -Class ([Character]) -All)
		}
	}
}
