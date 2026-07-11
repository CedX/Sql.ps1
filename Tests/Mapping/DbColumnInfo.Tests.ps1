using namespace Belin.Sql
using namespace System.Data
using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `DbColumnInfo` class.
#>
Describe "DbColumnInfo" {
	Context "CanRead" {
		It "should return `$true if the property can be read" -ForEach "FirstName", "FullName", "Gender", "Id" {
			Should-BeTrue ([Belin.Sql.DbColumnInfo]::new([Character].GetProperty($_)).CanRead)
		}
	}

	Context "CanWrite" {
		It "should return `$true if the property can be written" -ForEach "FirstName", "FullName", "Gender", "Id" {
			Should-BeTrue ([Belin.Sql.DbColumnInfo]::new([Character].GetProperty($_)).CanWrite)
		}
	}

	Context "DbType" {
		It "should return the SQL data type of the column" -ForEach @(
			@{ Name = "FirstName"; Expected = [DbType]::String }
			@{ Name = "FullName"; Expected = [DbType]::String }
			@{ Name = "Gender"; Expected = [DbType]::AnsiString }
			@{ Name = "Id"; Expected = [DbType]::Int32 }
		) {
			Should-Be $expected ([Belin.Sql.DbColumnInfo]::new([Character].GetProperty($name)).DbType)
		}
	}

	Context "IsComputed" {
		It "should return `$false if the property is not computed" -ForEach "FirstName", "Gender" {
			Should-BeFalse ([Belin.Sql.DbColumnInfo]::new([Character].GetProperty($_)).IsComputed)
		}

		It "should return `$true if the property is computed" -ForEach "FullName", "Id" {
			Should-BeTrue ([Belin.Sql.DbColumnInfo]::new([Character].GetProperty($_)).IsComputed)
		}
	}

	Context "IsIdentity" {
		It "should return `$false if the property is not an identity" -ForEach "FirstName", "FullName", "Gender" {
			Should-BeFalse ([Belin.Sql.DbColumnInfo]::new([Character].GetProperty($_)).IsIdentity)
		}

		It "should return `$true if the property is an identity" -ForEach "Id" {
			Should-BeTrue ([Belin.Sql.DbColumnInfo]::new([Character].GetProperty($_)).IsIdentity)
		}
	}

	Context "IsNullable" {
		It "should return `$false if the property is not nullable" -ForEach "FirstName", "Gender", "Id" {
			Should-BeFalse ([Belin.Sql.DbColumnInfo]::new([Character].GetProperty($_)).IsNullable)
		}

		It "should return `$true if the property is nullable" -ForEach "FullName" {
			Should-BeTrue ([Belin.Sql.DbColumnInfo]::new([Character].GetProperty($_)).IsNullable)
		}
	}

	Context "Name" {
		It "should return the name of the database column" -ForEach @(
			@{ Name = "FirstName"; Expected = "firstName" }
			@{ Name = "FullName"; Expected = "fullName" }
			@{ Name = "Gender"; Expected = "gender" }
			@{ Name = "Id"; Expected = "ID" }
		) {
			[Belin.Sql.DbColumnInfo]::new([Character].GetProperty($name)).Name | Should -BeExactly $expected
		}
	}

	Context "PropertyType" {
		It "should return the type of the database column" -ForEach @(
			@{ Name = "FirstName"; Expected = [string] }
			@{ Name = "FullName"; Expected = [string] }
			@{ Name = "Gender"; Expected = [CharacterGender] }
			@{ Name = "Id"; Expected = [int] }
		) {
			Should-Be $expected ([Belin.Sql.DbColumnInfo]::new([Character].GetProperty($name)).PropertyType)
		}
	}

	Context "GetValue" {
		It "should return the value of the spcified property" {
			$record = [Character]@{ FirstName = "Cédric"; LastName = "Belin" }
			[Belin.Sql.DbColumnInfo]::new([Character].GetProperty("FirstName")).GetValue($record) | Should -BeExactly Cédric
			[Belin.Sql.DbColumnInfo]::new([Character].GetProperty("LastName")).GetValue($record) | Should -BeExactly Belin
		}
	}

	Context "SetValue" {
		It "should set the value of the spcified property" {
			$record = [Character]@{ FirstName = "Cédric"; LastName = "Belin" }
			[Belin.Sql.DbColumnInfo]::new([Character].GetProperty("FirstName")).SetValue($record, "Jeffrey")
			[Belin.Sql.DbColumnInfo]::new([Character].GetProperty("LastName")).SetValue($record, "Snover")
			$record.FirstName | Should -BeExactly Jeffrey
			$record.LastName | Should -BeExactly Snover
		}
	}
}
