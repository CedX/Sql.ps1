using module ../../Sql.psd1
using module ../../Sources/SqlMapper.psm1

<#
.SYNOPSIS
	Tests the features of the `Get-SqlMapper` cmdlet.
#>
Describe "Get-SqlMapper" {
	It "should return the singleton instance of the SQL mapper" {
		Get-SqlMapper | Should -BeExactly ([SqlMapper]::Instance)
		Get-SqlMapper | Should -BeExactly (Get-SqlMapper)
	}
}
