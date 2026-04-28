<#
.SYNOPSIS
	Tests the features of the `New-Parameter` cmdlet.
#>
Describe "New-Parameter" {
	BeforeAll {
		. "$PSScriptRoot/BeforeAll.ps1"
	}

	It "should normalize the parameter name" -ForEach @(
		@{ Name = ""; Expected = "?" }
		@{ Name = "?"; Expected = "?" }
		@{ Name = "?1"; Expected = "?1" }
		@{ Name = "foo"; Expected = "@foo" }
		@{ Name = "@bar"; Expected = "@bar" }
		@{ Name = ":baz"; Expected = ":baz" }
		@{ Name = "`$qux"; Expected = "`$qux" }
	) {
		$parameter = New-Parameter $name
		$parameter.Name | Should -BeExactly $expected
	}

	It "should normalize the parameter value" -ForEach @(
		@{ Value = $null; Expected = [DBNull]::Value }
		@{ Value = [DBNull]::Value; Expected = [DBNull]::Value }
		@{ Value = 123; Expected = 123 }
		@{ Value = -123.456; Expected = -123.456 }
		@{ Value = ""; Expected = "" }
		@{ Value = "foo"; Expected = "foo" }
		@{ Value = [datetime]::UnixEpoch; Expected = [datetime]::UnixEpoch }
	) {
		$parameter = New-Parameter "name" $value
		$parameter.Value | Should -BeExactly $expected
	}
}
