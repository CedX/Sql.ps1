using namespace System.Collections.Generic
using namespace System.Diagnostics.CodeAnalysis
using module ../../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `Get-Mapper` cmdlet.
#>
Describe "Get-Mapper" {
	BeforeAll {
		[SuppressMessage("PSUseDeclaredVarsMoreThanAssignments", "")]
		$dataRow = @(
			[KeyValuePair[string, object]]::new("Id", 123)
			[KeyValuePair[string, object]]::new("LongLabel", "Hello World!")
			[KeyValuePair[string, object]]::new("ShortLabel", $null)
			[KeyValuePair[string, object]]::new("Id", 456)
			[KeyValuePair[string, object]]::new("FirstName", "Cédric")
			[KeyValuePair[string, object]]::new("LastName", "Belin")
			[KeyValuePair[string, object]]::new("RowID", 789)
		)
	}

	It "should return the singleton instance of the SQL mapper" {
		Get-SqlMapper | Should -BeExactly ([Belin.Sql.SqlMapper]::Instance)
		Get-SqlMapper | Should -BeExactly (Get-SqlMapper)
	}
}
