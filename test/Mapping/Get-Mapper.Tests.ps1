using module ../../src/SqlMapper.psm1

<#
.SYNOPSIS
	Tests the features of the `Get-Mapper` cmdlet.
#>
Describe "Get-Mapper" {
	BeforeAll {
		Import-Module "$PSScriptRoot/../../Sql.psd1"
	}

	It "should return the singleton instance of the SQL mapper" {
		Get-SqlMapper | Should -BeExactly ([SqlMapper]::Instance)
		Get-SqlMapper | Should -BeExactly (Get-SqlMapper)
	}
}
