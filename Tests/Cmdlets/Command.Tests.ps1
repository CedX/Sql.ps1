using namespace System.Data
using module ../../Sql.psd1
using module ../../Sources/SortOrder.psm1

<#
.SYNOPSIS
	Tests the features of the `New-SqlOrderHintCollection` cmdlet.
#>
Describe "New-SqlOrderHintCollection" {
	It "should create an empty collection by default" {
		$collection = New-SqlOrderHintCollection
		$collection | Should -BeNullOrEmpty
	}

	It "should create a collection from a single order hint" {
		$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending)
		$collection | Should -HaveCount 1

		$orderHint = $collection[0]
		$orderHint.Column | Should -BeExactly ID
		$orderHint.SortOrder | Should -Be ([SortOrder]::Descending)
	}

	It "should create a collection from an array of order hints" {
		$orderHints = (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name Ascending)
		$collection = New-SqlOrderHintCollection $orderHints
		$collection | Should -HaveCount 2

		$orderHint = $collection[$collection.Count - 1]
		$orderHint.Column | Should -BeExactly Name
		$orderHint.SortOrder | Should -Be ([SortOrder]::Ascending)
	}
}

<#
.SYNOPSIS
	Tests the features of the `New-SqlParameter` cmdlet.
#>
Describe "New-SqlParameter" {
	It "should normalize the parameter name" -ForEach @(
		@{ Name = ""; Expected = "?" }
		@{ Name = "?"; Expected = "?" }
		@{ Name = "?1"; Expected = "?1" }
		@{ Name = "foo"; Expected = "@foo" }
		@{ Name = "@bar"; Expected = "@bar" }
		@{ Name = ":baz"; Expected = ":baz" }
		@{ Name = "`$qux"; Expected = "`$qux" }
	) {
		$parameter = New-SqlParameter $name
		$parameter.Name | Should -BeExactly $expected
	}

	It "should normalize the parameter value" -ForEach @(
		@{ Value = $null; Expected = [DBNull]::Value }
		@{ Value = [DBNull]::Value; Expected = [DBNull]::Value }
		@{ Value = 123; Expected = 123 }
		@{ Value = -123.456; Expected = -123.456 }
		@{ Value = ""; Expected = "" }
		@{ Value = "Foo"; Expected = "Foo" }
		@{ Value = [datetime]::UnixEpoch; Expected = [datetime]::UnixEpoch }
	) {
		$parameter = New-SqlParameter Name $value
		$parameter.Value | Should -BeExactly $expected
	}
}

<#
.SYNOPSIS
	Tests the features of the `New-SqlParameterCollection` cmdlet.
#>
Describe "New-SqlParameterCollection" {
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
		$parameters = (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
		$collection = New-SqlParameterCollection $parameters
		$collection | Should -HaveCount 2

		$parameter = $collection[$collection.Count - 1]
		$parameter.Name | Should -BeExactly "@Key"
		$parameter.Value | Should -BeExactly Unique
		$parameter.DbType | Should -Be ([DbType]::AnsiString)
	}
}
