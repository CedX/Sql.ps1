using namespace System.Collections.Generic
using module ../src/SqlCommand.psm1

<#
.SYNOPSIS
	Tests the features of the `SqlCommand` class.
#>
Describe "SqlCommand" {
	Context "ImplicitConversion" {
		It "should create a command from the specified string" {
			$sql = "SELECT * FROM Characters"
			([SqlCommand] $sql).Text | Should -BeExactly $sql
		}
	}
}
