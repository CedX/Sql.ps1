using namespace System.Data

<#
.SYNOPSIS
	Tests the features of the `New-ParameterCollection` cmdlet.
#>
Describe "New-ParameterCollection" {
	BeforeAll {
		Import-Module "$PSScriptRoot/../../Sql.psd1"
	}

	It "should create an empty collection by default" {
		$collection = New-SqlParameterCollection
		$collection | Should -BeNullOrEmpty
	}

	It "should create a collection from a single parameter" {
		$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123 -DbType Int64)
		$collection | Should -HaveCount 1

		$parameter = $collection[0]
		$parameter.Name | Should -BeExactly "?1"
		$parameter.Value | Should -Be 123
		$parameter.DbType | Should -Be ([DbType]::Int64)
	}

	It "should create a collection from an array of parameters" {
		$parameters = (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" "Unique" -DbType AnsiString)
		$collection = New-SqlParameterCollection $parameters
		$collection | Should -HaveCount 2

		$parameter = $collection[$collection.Count - 1]
		$parameter.Name | Should -BeExactly "@Key"
		$parameter.Value | Should -BeExactly Unique
		$parameter.DbType | Should -Be ([DbType]::AnsiString)
	}
}
