using module ../src/Parameter.psm1

<#
.SYNOPSIS
	Tests the features of the `Parameter` class.
#>
Describe "Parameter" {
	Context "ImplicitConversion" {
		[Parameter] $parameter = @()
		$parameter.Name | Should -BeExactly "?"
		$parameter.Value | Should -Be ([DBNull]::Value)

		$parameter = , ":foo"
		$parameter.Name | Should -BeExactly ":foo"
		$parameter.Value | Should -Be ([DBNull]::Value)

		$parameter = "bar", "Baz"
		$parameter.Name | Should -BeExactly "@bar"
		$parameter.Value | Should -BeExactly "Baz"
	}

	Context "Name" -ForEach @(
		@{ Name = ""; Expected = "?" }
		@{ Name = "?"; Expected = "?" }
		@{ Name = "?1"; Expected = "?1" }
		@{ Name = "foo"; Expected = "@foo" }
		@{ Name = "@bar"; Expected = "@bar" }
		@{ Name = ":baz"; Expected = ":baz" }
		@{ Name = "`$qux"; Expected = "`$qux" }
	) {
		It "should return the normalized name" {
			[Parameter]::new($name).Name | Should -BeExactly $expected
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
			[Parameter]::new("Name", $value).Value | Should -BeExactly $expected
		}
	}
}
