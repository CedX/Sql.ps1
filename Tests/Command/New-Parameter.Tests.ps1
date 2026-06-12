using namespace Belin.Sql
using namespace System.Collections.Generic
using namespace System.Data
using module ../../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `New-Parameter` cmdlet.
#>
Describe "New-Parameter" {
	Context "ImplicitConversion" {
		It "should create a parameter from the specified array" {
			[SqlParameter] $parameter = "", $null
			$parameter.Name | Should -BeExactly "?"
			$parameter.Value | Should -Be ([DBNull]::Value)

			$parameter = ":foo", "bar"
			$parameter.Name | Should -BeExactly ":foo"
			$parameter.Value | Should -BeExactly "bar"

			$parameter = "bar", 123
			$parameter.Name | Should -BeExactly "@bar"
			$parameter.Value | Should -Be 123
		}

		It "should create a parameter from the specified tuple" {
			[SqlParameter] $parameter = [ValueTuple]::Create("", [object] $null)
			$parameter.Name | Should -BeExactly "?"
			$parameter.Value | Should -Be ([DBNull]::Value)

			$parameter = [ValueTuple]::Create(":foo", [object] "bar")
			$parameter.Name | Should -BeExactly ":foo"
			$parameter.Value | Should -BeExactly "bar"

			$parameter = [ValueTuple]::Create("bar", [object] 123)
			$parameter.Name | Should -BeExactly "@bar"
			$parameter.Value | Should -Be 123
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
	}

	Context "Value" {
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
}
