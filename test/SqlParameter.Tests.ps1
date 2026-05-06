using namespace System.Collections.Generic
using module ../src/SqlParameter.psm1

<#
.SYNOPSIS
	Tests the features of the `SqlParameter` class.
#>
Describe "SqlParameter" {
	Context "ImplicitConversion" {
		It "should create a parameter from the specified tuple" {
			[SqlParameter] $parameter = @()
			$parameter.Name | Should -BeExactly "?"
			$parameter.Value | Should -Be ([DBNull]::Value)

			$parameter = , ":foo"
			$parameter.Name | Should -BeExactly ":foo"
			$parameter.Value | Should -Be ([DBNull]::Value)

			$parameter = "bar", "Baz"
			$parameter.Name | Should -BeExactly "@bar"
			$parameter.Value | Should -BeExactly Baz
		}

		It "should create a parameter from the specified key/value pair" {
			[SqlParameter] $parameter = [KeyValuePair[string, object]]::new("foo", $null)
			$parameter.Name | Should -BeExactly "@foo"
			$parameter.Value | Should -Be ([DBNull]::Value)

			$parameter = [KeyValuePair[string, object]]::new(":bar", "Baz")
			$parameter.Name | Should -BeExactly ":bar"
			$parameter.Value | Should -BeExactly Baz
		}
	}

	Context "Name" {
		It "should return the normalized name" -ForEach @(
			@{ Name = ""; Expected = "?" }
			@{ Name = "?"; Expected = "?" }
			@{ Name = "?1"; Expected = "?1" }
			@{ Name = "foo"; Expected = "@foo" }
			@{ Name = "@bar"; Expected = "@bar" }
			@{ Name = ":baz"; Expected = ":baz" }
			@{ Name = "`$qux"; Expected = "`$qux" }
		) {
			[SqlParameter]::new($name).Name | Should -BeExactly $expected
		}
	}

	Context "Value" {
		It "should return the normalized value" -ForEach @(
			@{ Value = $null; Expected = [DBNull]::Value }
			@{ Value = [DBNull]::Value; Expected = [DBNull]::Value }
			@{ Value = 123; Expected = 123 }
			@{ Value = -123.456; Expected = -123.456 }
			@{ Value = ""; Expected = "" }
			@{ Value = "Foo"; Expected = "Foo" }
			@{ Value = [datetime]::UnixEpoch; Expected = [datetime]::UnixEpoch }
		) {
			[SqlParameter]::new("Name", $value).Value | Should -BeExactly $expected
		}
	}
}
