using namespace Belin.Sql
using namespace System.Collections.Generic
using namespace System.Diagnostics.CodeAnalysis
using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Get-Mapper` cmdlet.
#>
Describe "Get-Mapper" {
	It "should return the singleton instance of the SQL mapper" {
		Get-SqlMapper | Should -BeExactly ([SqlMapper]::Instance)
		Get-SqlMapper | Should -BeExactly (Get-SqlMapper)
	}

	Context "ChangeType" {
		It "convert the specified value to an object of the given type" -ForEach @(
			@{ Value = $null; ConversionType = [bool]; IsNullable = $false; Expected = $false }
			@{ Value = $null; ConversionType = [Nullable[bool]]; IsNullable = $true; Expected = $null }
			@{ Value = [DBNull]::Value; ConversionType = [bool]; IsNullable = $false; Expected = $false }
			@{ Value = [DBNull]::Value; ConversionType = [Nullable[bool]]; IsNullable = $true; Expected = $null }
			@{ Value = 0; ConversionType = [bool]; IsNullable = $false; Expected = $false }
			@{ Value = 0; ConversionType = [Nullable[bool]]; IsNullable = $true; Expected = $false }
			@{ Value = 1; ConversionType = [bool]; IsNullable = $false; Expected = $true }
			@{ Value = 1; ConversionType = [Nullable[bool]]; IsNullable = $true; Expected = $true }
			@{ Value = "false"; ConversionType = [bool]; IsNullable = $false; Expected = $false }
			@{ Value = "true"; ConversionType = [bool]; IsNullable = $false; Expected = $true }

			@{ Value = $null; ConversionType = [char]; IsNullable = $false; Expected = [char]::MinValue }
			@{ Value = $null; ConversionType = [Nullable[char]]; IsNullable = $true; Expected = $null }
			@{ Value = $null; ConversionType = [char]; IsNullable = $false; Expected = [char]::MinValue }
			@{ Value = $null; ConversionType = [Nullable[char]]; IsNullable = $true; Expected = $null }
			@{ Value = 0; ConversionType = [char]; IsNullable = $false; Expected = [char]::MinValue }
			@{ Value = 65535; ConversionType = [Nullable[char]]; IsNullable = $true; Expected = [char]::MaxValue }
			@{ Value = 97; ConversionType = [char]; IsNullable = $false; Expected = 'a' }
			@{ Value = 98; ConversionType = [Nullable[char]]; IsNullable = $true; Expected = 'b' }
			@{ Value = "a"; ConversionType = [char]; IsNullable = $false; Expected = 'a' }
			@{ Value = "b"; ConversionType = [Nullable[char]]; IsNullable = $true; Expected = 'b' }

			@{ Value = $null; ConversionType = [datetime]; IsNullable = $false; Expected = [datetime]::MinValue }
			@{ Value = $null; ConversionType = [Nullable[datetime]]; IsNullable = $true; Expected = $null }
			@{ Value = [DBNull]::Value; ConversionType = [datetime]; IsNullable = $false; Expected = [datetime]::MinValue }
			@{ Value = [DBNull]::Value; ConversionType = [Nullable[datetime]]; IsNullable = $true; Expected = $null }
			@{ Value = [datetime]::MaxValue; ConversionType = [datetime]; IsNullable = $false; Expected = [datetime]::MaxValue }
			@{ Value = [datetime]::UnixEpoch; ConversionType = [Nullable[datetime]]; IsNullable = $true; Expected = [datetime]::UnixEpoch }
			@{ Value = [datetime]::new(2025, 6, 7, 10, 45, 1); ConversionType = [datetime]; IsNullable = $false; Expected = [datetime]::new(2025, 6, 7, 10, 45, 1) }
			@{ Value = [datetime]::new(2026, 1, 31); ConversionType = [Nullable[datetime]]; IsNullable = $true; Expected = [datetime]::new(2026, 1, 31) }
			@{ Value = "2025-06-07 10:45:01"; ConversionType = [datetime]; IsNullable = $false; Expected = [datetime]::new(2025, 6, 7, 10, 45, 1) }
			@{ Value = "2025-06-07T10:45:01"; ConversionType = [Nullable[datetime]]; IsNullable = $true; Expected = [datetime]::new(2025, 6, 7, 10, 45, 1) }

			@{ Value = $null; ConversionType = [DayOfWeek]; IsNullable = $false; Expected = [DayOfWeek]::Sunday }
			@{ Value = $null; ConversionType = [Nullable[DayOfWeek]]; IsNullable = $true; Expected = $null }
			@{ Value = [DBNull]::Value; ConversionType = [DayOfWeek]; IsNullable = $false; Expected = [DayOfWeek]::Sunday }
			@{ Value = [DBNull]::Value; ConversionType = [Nullable[DayOfWeek]]; IsNullable = $true; Expected = $null }
			@{ Value = 0; ConversionType = [DayOfWeek]; IsNullable = $false; Expected = [DayOfWeek]::Sunday }
			@{ Value = 1; ConversionType = [Nullable[DayOfWeek]]; IsNullable = $true; Expected = [DayOfWeek]::Monday }
			@{ Value = 5; ConversionType = [DayOfWeek]; IsNullable = $false; Expected = [DayOfWeek]::Friday }
			@{ Value = 6; ConversionType = [Nullable[DayOfWeek]]; IsNullable = $true; Expected = [DayOfWeek]::Saturday }
			@{ Value = "sunday"; ConversionType = [DayOfWeek]; IsNullable = $false; Expected = [DayOfWeek]::Sunday }
			@{ Value = "friday"; ConversionType = [Nullable[DayOfWeek]]; IsNullable = $true; Expected = [DayOfWeek]::Friday }

			@{ Value = $null; ConversionType = [double]; IsNullable = $false; Expected = 0.0 }
			@{ Value = $null; ConversionType = [Nullable[double]]; IsNullable = $true; Expected = $null }
			@{ Value = [DBNull]::Value; ConversionType = [double]; IsNullable = $false; Expected = 0.0 }
			@{ Value = [DBNull]::Value; ConversionType = [Nullable[double]]; IsNullable = $true; Expected = $null }
			@{ Value = 0; ConversionType = [double]; IsNullable = $false; Expected = 0.0 }
			@{ Value = 0; ConversionType = [Nullable[double]]; IsNullable = $true; Expected = 0.0 }
			@{ Value = 123; ConversionType = [double]; IsNullable = $false; Expected = 123.0 }
			@{ Value = -123.456; ConversionType = [Nullable[double]]; IsNullable = $true; Expected = -123.456 }
			@{ Value = "123"; ConversionType = [double]; IsNullable = $false; Expected = 123.0 }
			@{ Value = "-123.456"; ConversionType = [Nullable[double]]; IsNullable = $true; Expected = -123.456 }

			@{ Value = $null; ConversionType = [int]; IsNullable = $false; Expected = 0 }
			@{ Value = $null; ConversionType = [Nullable[int]]; IsNullable = $true; Expected = $null }
			@{ Value = [DBNull]::Value; ConversionType = [int]; IsNullable = $false; Expected = 0 }
			@{ Value = [DBNull]::Value; ConversionType = [Nullable[int]]; IsNullable = $true; Expected = $null }
			@{ Value = 0; ConversionType = [int]; IsNullable = $false; Expected = 0 }
			@{ Value = 0; ConversionType = [Nullable[int]]; IsNullable = $true; Expected = 0 }
			@{ Value = 123; ConversionType = [int]; IsNullable = $false; Expected = 123 }
			@{ Value = -123.456; ConversionType = [Nullable[int]]; IsNullable = $true; Expected = -123 }
			@{ Value = "123"; ConversionType = [int]; IsNullable = $false; Expected = 123 }
			@{ Value = "-123"; ConversionType = [Nullable[int]]; IsNullable = $true; Expected = -123 }
		) {
			[SqlMapper]::Instance.ChangeType($value, $conversionType, $isNullable) | Should -BeExactly $expected
		}
	}

	Context "CreateInstance" {
		It "should support creating an object of type [psobject]" {
			$properties = @{ CLASS = "Bard/minstrel"; firstName = "Cédric"; gender = "Balrog"; lastName = $null }
			$psObject = (Get-SqlMapper).CreateInstance([psobject], $properties)
			$psObject | Should -BeOfType ([psobject])
			$psObject.CLASS | Should -BeExactly "Bard/minstrel"
			$psObject.firstName | Should -BeExactly Cédric
			$psObject.gender | Should -BeExactly ([CharacterGender]::Balrog.ToString())
			$psObject.lastName | Should -BeNullOrEmpty
		}

		It "should create an object of the specified type" {
			$properties = @{ CLASS = "Bard/minstrel"; firstName = "Cédric"; gender = "Balrog"; lastName = $null }
			$character = (Get-SqlMapper).CreateInstance([Character], $properties)
			$character | Should -BeOfType ([Character])
			$character.FirstName | Should -BeExactly Cédric
			$character.Gender | Should -Be ([CharacterGender]::Balrog)
			$character.LastName | Should -Be ""
		}
	}

	Context "GetTable" {
		It "should return detailed information about the database table associated with the specified entity class" {
			$table = (Get-SqlMapper).GetTable([Character])
			$table.Schema | Should -BeExactly main
			$table.Name | Should -BeExactly Characters
			$table.Type | Should -Be ([Character])

			Should-Be 5 $table.Columns.Count
			$table.IdentityColumn | Should -Be $table.Columns.ID
			$table.Columns.gender.PropertyType | Should -Be ([CharacterGender])
			$table.Columns.lastName.PropertyType | Should -Be ([string])

			$table.Columns.firstName.CanWrite | Should-BeTrue
			$table.Columns.fullName.IsComputed | Should-BeTrue
			$table.Columns.ID.IsIdentity | Should-BeTrue
		}
	}
}
