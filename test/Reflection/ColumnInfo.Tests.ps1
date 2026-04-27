using module ../../src/Reflection/ColumnInfo.psm1
using module ../Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `ColumnInfo` class.
#>
Describe "ColumnInfo" {
	Context "CanRead" {
		It "should return `$true if the property can be read" -ForEach @("FirstName", "FullName", "Gender", "Id") {
			[ColumnInfo]::new([Character].GetProperty($_)).CanRead | Should -BeTrue
		}
	}

	Context "CanWrite" {
		It "should return `$true if the property can be written" -ForEach @("FirstName", "FullName", "Gender", "Id") {
			[ColumnInfo]::new([Character].GetProperty($_)).CanWrite | Should -BeTrue
		}
	}

	Context "IsComputed" {
		It "should return `$false if the property is not computed" -ForEach @("FirstName", "Gender") {
			[ColumnInfo]::new([Character].GetProperty($_)).IsComputed | Should -BeFalse
		}

		It "should return `$true if the property is computed" -ForEach @("FullName", "Id") {
			[ColumnInfo]::new([Character].GetProperty($_)).IsComputed | Should -BeTrue
		}
	}

	Context "IsIdentity" {
		It "should return `$false if the property is not an identity" -ForEach @("FirstName", "FullName", "Gender") {
			[ColumnInfo]::new([Character].GetProperty($_)).IsIdentity | Should -BeFalse
		}

		It "should return `$true if the property is an identity" -ForEach @("Id") {
			[ColumnInfo]::new([Character].GetProperty($_)).IsIdentity | Should -BeTrue
		}
	}

	Context "IsNullable" {
		It "should return `$false if the property is not nullable" -ForEach @("Gender", "Id") {
			[ColumnInfo]::new([Character].GetProperty($_)).IsNullable | Should -BeFalse
		}

		It "should return `$true if the property is nullable" -ForEach @("FirstName", "FullName") {
			[ColumnInfo]::new([Character].GetProperty($_)).IsNullable | Should -BeTrue
		}
	}

	Context "Name" {
		It "should return the name of the database column" -ForEach @(
			@{ Name = "FirstName"; Expected = "firstName" }
			@{ Name = "FullName"; Expected = "fullName" }
			@{ Name = "Gender"; Expected = "gender" }
			@{ Name = "Id"; Expected = "ID" }
		) {
			[ColumnInfo]::new([Character].GetProperty($name)).Name | Should -BeExactly $expected
		}
	}

	Context "Type" {
		It "should return the type of the database column" -ForEach @(
			@{ Name = "FirstName"; Expected = [string] }
			@{ Name = "FullName"; Expected = [string] }
			@{ Name = "Gender"; Expected = [CharacterGender] }
			@{ Name = "Id"; Expected = [int] }
		) {
			[ColumnInfo]::new([Character].GetProperty($name)).Type | Should -Be $expected
		}
	}

	Context "GetValue" {
		It "should return the value of the spcified property" {
			$character = [Character]@{ LastName = "Belin" }
			[ColumnInfo]::new([Character].GetProperty("LastName")).GetValue($character) | Should -BeExactly "Belin"
		}
	}

	Context "SetValue" {
		It "should set the value of the spcified property" {
			$character = [Character]@{ LastName = "Belin" }
			[ColumnInfo]::new([Character].GetProperty("LastName")).SetValue($character, "New NAME")
			$character.LastName | Should -BeExactly "New NAME"
		}
	}
}
