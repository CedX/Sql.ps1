using module ../../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `New-Command` cmdlet.
#>
Describe "New-Command" {
	Context "ImplicitConversion" {
		It "should create a command from the specified string" {
			[Belin.Sql.SqlCommand] $command = "SELECT * FROM Characters"
			$command.Text | Should -BeExactly "SELECT * FROM Characters"
		}
	}
}
