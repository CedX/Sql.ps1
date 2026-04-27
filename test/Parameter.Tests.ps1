using module ../src/Parameter.psm1

<#
.SYNOPSIS
	Tests the features of the `Parameter` class.
#>
Describe "Parameter" {
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
		It "should return the normalized value" {
			[Parameter]::new("Name", $null).Value | Should -Be ([DBNull]::Value)
			[Parameter]::new("Name", [DBNull]::Value).Value | Should -Be ([DBNull]::Value)
			[Parameter]::new("Name", 123).Value | Should -Be 123
			[Parameter]::new("Name", -123.456).Value | Should -Be -123.456
			[Parameter]::new("Name", "").Value | Should -Be ""
			[Parameter]::new("Name", "Foo").Value | Should -BeExactly "Foo"
			[Parameter]::new("Name", [datetime]::UnixEpoch).Value | Should -Be ([datetime]::UnixEpoch)
		}
	}
}
