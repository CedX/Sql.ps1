using namespace System.Data
using module ../src/DbColumnInfo.psm1
using module ./Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `DbColumnInfo` class.
#>
Describe "DbColumnInfo" {
	Context "CanRead" {
		It "should return `$true if the property can be read" -ForEach @("FirstName", "FullName", "Gender", "Id") {
			[DbColumnInfo]::new([Character].GetProperty($_)).CanRead | Should -BeTrue
		}
	}

	Context "CanWrite" {
		It "should return `$true if the property can be written" -ForEach @("FirstName", "FullName", "Gender", "Id") {
			[DbColumnInfo]::new([Character].GetProperty($_)).CanWrite | Should -BeTrue
		}
	}

	Context "DbType" {
		It "should return the SQL data type of the column" -ForEach @(
			@{ Name = "FirstName"; Expected = [DbType]::String }
			@{ Name = "FullName"; Expected = [DbType]::String }
			@{ Name = "Gender"; Expected = [DbType]::AnsiString }
			@{ Name = "Id"; Expected = [DbType]::Int32 }
		) {
			[DbColumnInfo]::new([Character].GetProperty($name)).DbType | Should -Be $expected
		}
	}

	Context "IsComputed" {
		It "should return `$false if the property is not computed" -ForEach @("FirstName", "Gender") {
			[DbColumnInfo]::new([Character].GetProperty($_)).IsComputed | Should -BeFalse
		}

		It "should return `$true if the property is computed" -ForEach @("FullName", "Id") {
			[DbColumnInfo]::new([Character].GetProperty($_)).IsComputed | Should -BeTrue
		}
	}

	Context "IsIdentity" {
		It "should return `$false if the property is not an identity" -ForEach @("FirstName", "FullName", "Gender") {
			[DbColumnInfo]::new([Character].GetProperty($_)).IsIdentity | Should -BeFalse
		}

		It "should return `$true if the property is an identity" -ForEach @("Id") {
			[DbColumnInfo]::new([Character].GetProperty($_)).IsIdentity | Should -BeTrue
		}
	}

	Context "IsNullable" {
		It "should return `$false if the property is not nullable" -ForEach @("FirstName", "Gender", "Id") {
			[DbColumnInfo]::new([Character].GetProperty($_)).IsNullable | Should -BeFalse
		}

		It "should return `$true if the property is nullable" -ForEach @("FullName") {
			[DbColumnInfo]::new([Character].GetProperty($_)).IsNullable | Should -BeTrue
		}
	}

	Context "Name" {
		It "should return the name of the database column" -ForEach @(
			@{ Name = "FirstName"; Expected = "firstName" }
			@{ Name = "FullName"; Expected = "fullName" }
			@{ Name = "Gender"; Expected = "gender" }
			@{ Name = "Id"; Expected = "ID" }
		) {
			[DbColumnInfo]::new([Character].GetProperty($name)).Name | Should -BeExactly $expected
		}
	}

	Context "PropertyType" {
		It "should return the type of the database column" -ForEach @(
			@{ Name = "FirstName"; Expected = [string] }
			@{ Name = "FullName"; Expected = [string] }
			@{ Name = "Gender"; Expected = [CharacterGender] }
			@{ Name = "Id"; Expected = [int] }
		) {
			[DbColumnInfo]::new([Character].GetProperty($name)).PropertyType | Should -Be $expected
		}
	}

	Context "GetValue" {
		It "should return the value of the spcified property" {
			$record = [Character]@{ FirstName = "Cédric"; LastName = "Belin" }
			[DbColumnInfo]::new([Character].GetProperty("FirstName")).GetValue($record) | Should -BeExactly Cédric
			[DbColumnInfo]::new([Character].GetProperty("LastName")).GetValue($record) | Should -BeExactly Belin
		}
	}

	Context "SetValue" {
		It "should set the value of the spcified property" {
			$record = [Character]@{ FirstName = "Cédric"; LastName = "Belin" }
			[DbColumnInfo]::new([Character].GetProperty("FirstName")).SetValue($record, "Jeffrey")
			[DbColumnInfo]::new([Character].GetProperty("LastName")).SetValue($record, "Snover")
			$record.FirstName | Should -BeExactly Jeffrey
			$record.LastName | Should -BeExactly Snover
		}
	}
}
