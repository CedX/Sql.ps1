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
			Should-BeString "?" $parameter.Name -CaseSensitive
			Should-Be ([DBNull]::Value) $parameter.Value

			$parameter = ":foo", "bar"
			Should-BeString ":foo" $parameter.Name -CaseSensitive
			Should-BeString "bar" $parameter.Value -CaseSensitive

			$parameter = "bar", 123
			Should-BeString "@bar" $parameter.Name -CaseSensitive
			Should-Be 123 $parameter.Value
		}

		It "should create a parameter from the specified tuple" {
			[SqlParameter] $parameter = [ValueTuple]::Create("", [object] $null)
			Should-BeString "?" $parameter.Name -CaseSensitive
			Should-Be ([DBNull]::Value) $parameter.Value

			$parameter = [ValueTuple]::Create(":foo", [object] "bar")
			Should-BeString ":foo" $parameter.Name -CaseSensitive
			Should-BeString "bar" $parameter.Value -CaseSensitive

			$parameter = [ValueTuple]::Create("bar", [object] 123)
			Should-BeString "@bar" $parameter.Name -CaseSensitive
			Should-Be 123 $parameter.Value
		}

		It "should create a parameter from the specified key/value pair" {
			[SqlParameter] $parameter = [KeyValuePair[string, object]]::new("foo", $null)
			Should-BeString "@foo" $parameter.Name -CaseSensitive
			Should-Be ([DBNull]::Value) $parameter.Value

			$parameter = [KeyValuePair[string, object]]::new(":bar", "Baz")
			Should-BeString ":bar" $parameter.Name -CaseSensitive
			Should-BeString Baz $parameter.Value -CaseSensitive
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
			Should-BeString $expected $parameter.Name -CaseSensitive
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
			Should-Be $expected $parameter.Value
		}

		It "should support the values wrapped in a [psobject] instance" -ForEach ([DBNull]::Value, "Foo", [datetime]::UnixEpoch) {
			$parameter = New-SqlParameter Name ([psobject]::AsPSObject($_))
			Should-Be $_ $parameter.Value
		}
	}
}
