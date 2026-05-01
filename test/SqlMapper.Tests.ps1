using namespace System.Collections.Generic
using namespace System.Diagnostics.CodeAnalysis
using module ../src/SqlMapper.psm1
using module ./Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `SqlMapper` class.
#>
Describe "SqlMapper" {
	BeforeAll {
		[SuppressMessage("PSUseDeclaredVarsMoreThanAssignments", "")]
		$dataRow = @(
			[KeyValuePair[string, object]]::new("Id", 123)
			[KeyValuePair[string, object]]::new("LongLabel", "Hello World!")
			[KeyValuePair[string, object]]::new("ShortLabel", $null)
			[KeyValuePair[string, object]]::new("Id", 456)
			[KeyValuePair[string, object]]::new("FirstName", "Cédric")
			[KeyValuePair[string, object]]::new("LastName", "Belin")
			[KeyValuePair[string, object]]::new("RowID", 789)
		)
	}

	Context "ChangeType" {
		It "convert the specified value to an object of the given type" -ForEach @(
			@{ Value = $null; ConversionType = [bool]; IsNullable = $false; Expected = $false }
			@{ Value = $null; ConversionType = [Nullable[bool]]; IsNullable = $true; Expected = $null }
			@{ Value = 0; ConversionType = [bool]; IsNullable = $false; Expected = $false }
			@{ Value = 0; ConversionType = [Nullable[bool]]; IsNullable = $true; Expected = $false }
			@{ Value = 1; ConversionType = [bool]; IsNullable = $false; Expected = $true }
			@{ Value = 1; ConversionType = [Nullable[bool]]; IsNullable = $true; Expected = $true }
			@{ Value = "false"; ConversionType = [bool]; IsNullable = $false; Expected = $false }
			@{ Value = "true"; ConversionType = [bool]; IsNullable = $false; Expected = $true }

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
			@{ Value = [datetime]::MaxValue; ConversionType = [datetime]; IsNullable = $false; Expected = [datetime]::MaxValue }
			@{ Value = [datetime]::UnixEpoch; ConversionType = [Nullable[datetime]]; IsNullable = $true; Expected = [datetime]::UnixEpoch }
			@{ Value = [datetime]::new(2025, 6, 7, 10, 45, 1); ConversionType = [datetime]; IsNullable = $false; Expected = [datetime]::new(2025, 6, 7, 10, 45, 1) }
			@{ Value = [datetime]::new(2026, 1, 31); ConversionType = [Nullable[datetime]]; IsNullable = $true; Expected = [datetime]::new(2026, 1, 31) }
			@{ Value = "2025-06-07 10:45:01"; ConversionType = [datetime]; IsNullable = $false; Expected = [datetime]::new(2025, 6, 7, 10, 45, 1) }
			@{ Value = "2025-06-07T10:45:01"; ConversionType = [Nullable[datetime]]; IsNullable = $true; Expected = [datetime]::new(2025, 6, 7, 10, 45, 1) }

			@{ Value = $null; ConversionType = [DayOfWeek]; IsNullable = $false; Expected = [DayOfWeek]::Sunday }
			@{ Value = $null; ConversionType = [Nullable[DayOfWeek]]; IsNullable = $true; Expected = $null }
			@{ Value = 0; ConversionType = [DayOfWeek]; IsNullable = $false; Expected = [DayOfWeek]::Sunday }
			@{ Value = 1; ConversionType = [Nullable[DayOfWeek]]; IsNullable = $true; Expected = [DayOfWeek]::Monday }
			@{ Value = 5; ConversionType = [DayOfWeek]; IsNullable = $false; Expected = [DayOfWeek]::Friday }
			@{ Value = 6; ConversionType = [Nullable[DayOfWeek]]; IsNullable = $true; Expected = [DayOfWeek]::Saturday }
			@{ Value = "sunday"; ConversionType = [DayOfWeek]; IsNullable = $false; Expected = [DayOfWeek]::Sunday }
			@{ Value = "friday"; ConversionType = [Nullable[DayOfWeek]]; IsNullable = $true; Expected = [DayOfWeek]::Friday }

			@{ Value = $null; ConversionType = [double]; IsNullable = $false; Expected = 0.0 }
			@{ Value = $null; ConversionType = [Nullable[double]]; IsNullable = $true; Expected = $null }
			@{ Value = 0; ConversionType = [double]; IsNullable = $false; Expected = 0.0 }
			@{ Value = 0; ConversionType = [Nullable[double]]; IsNullable = $true; Expected = 0.0 }
			@{ Value = 123; ConversionType = [double]; IsNullable = $false; Expected = 123.0 }
			@{ Value = -123.456; ConversionType = [Nullable[double]]; IsNullable = $true; Expected = -123.456 }
			@{ Value = "123"; ConversionType = [double]; IsNullable = $false; Expected = 123.0 }
			@{ Value = "-123.456"; ConversionType = [Nullable[double]]; IsNullable = $true; Expected = -123.456 }

			@{ Value = $null; ConversionType = [int]; IsNullable = $false; Expected = 0 }
			@{ Value = $null; ConversionType = [Nullable[int]]; IsNullable = $true; Expected = $null }
			@{ Value = 0; ConversionType = [int]; IsNullable = $false; Expected = 0 }
			@{ Value = 0; ConversionType = [Nullable[int]]; IsNullable = $true; Expected = 0 }
			@{ Value = 123; ConversionType = [int]; IsNullable = $false; Expected = 123 }
			@{ Value = -123.456; ConversionType = [Nullable[int]]; IsNullable = $true; Expected = -123 }
			@{ Value = "123"; ConversionType = [int]; IsNullable = $false; Expected = 123 }
			@{ Value = "-123"; ConversionType = [Nullable[int]]; IsNullable = $true; Expected = -123 }
		) {
			[SqlMapper]::ChangeType($value, $conversionType, $isNullable) | Should -BeExactly $expected
		}
	}

	Context "CreateInstance" {
		It "should create a [PSObject] by default" {
			$properties = @{ CLASS = "Bard/minstrel"; firstName = "Cédric"; gender = "Balrog"; lastName = $null }
			$object = [SqlMapper]::Instance.CreateInstance($properties)
			$object | Should -BeOfType ([psobject])
			$object.CLASS | Should -BeExactly "Bard/minstrel"
			$object.firstName | Should -BeExactly Cédric
			$object.gender | Should -BeExactly ([CharacterGender]::Balrog.ToString())
			$object.lastName | Should -BeNullOrEmpty
		}

		It "should create an object of the specified type" {
			$properties = @{ CLASS = "Bard/minstrel"; firstName = "Cédric"; gender = "Balrog"; lastName = $null }
			$object = [SqlMapper]::Instance.CreateInstance([Character], $properties)
			$object | Should -BeOfType ([Character])
			$object.FirstName | Should -BeExactly Cédric
			$object.Gender | Should -Be ([CharacterGender]::Balrog)
			$object.LastName | Should -Be ""
		}
	}

	Context "GetTable" {
		It "should return detailed information about the database table associated with the specified entity class" {
			$table = [SqlMapper]::Instance.GetTable([Character])
			$table.Schema | Should -BeExactly main
			$table.Name | Should -BeExactly Characters
			$table.Type | Should -Be ([Character])

			$table.Columns.Keys | Should -HaveCount 5
			$table.IdentityColumn | Should -Be $table.Columns.ID
			$table.Columns.gender.Type | Should -Be ([CharacterGender])
			$table.Columns.lastName.Type | Should -Be ([string])

			$table.Columns.firstName.CanWrite | Should -BeTrue
			$table.Columns.fullName.IsComputed | Should -BeTrue
			$table.Columns.ID.IsIdentity | Should -BeTrue
		}
	}

	Context "SplitOn" {
		It "should return a hash table equivalent to the specified data row" {
			$records = [SqlMapper]::SplitOn($dataRow, @())
			$records | Should -HaveCount 1

			$properties = @{ Id = 123; LongLabel = "Hello World!"; ShortLabel = $null; FirstName = "Cédric"; LastName = "Belin"; RowID = 789 }
			Compare-Object $records[0] $properties | Should -BeNullOrEmpty
		}

		It "should not split the data row if the specified field does not exist" {
			$records = [SqlMapper]::SplitOn($dataRow, "_NonExistent_")
			$records | Should -HaveCount 1

			$properties = @{ Id = 123; LongLabel = "Hello World!"; ShortLabel = $null; FirstName = "Cédric"; LastName = "Belin"; RowID = 789 }
			Compare-Object $records[0] $properties | Should -BeNullOrEmpty
		}

		It "should split the data row according to the specified fields" {
			$records = [SqlMapper]::SplitOn($dataRow, "Id")
			$records | Should -HaveCount 2
			Compare-Object $records[0] @{ Id = 123; LongLabel = "Hello World!"; ShortLabel = $null } | Should -BeNullOrEmpty
			Compare-Object $records[1] @{ Id = 456; FirstName = "Cédric"; LastName = "Belin"; RowID = 789 } | Should -BeNullOrEmpty

			$records = [SqlMapper]::SplitOn($dataRow, ("Id", "RowID", "_Unused_"))
			$records | Should -HaveCount 3
			Compare-Object $records[0] @{ Id = 123; LongLabel = "Hello World!"; ShortLabel = $null } | Should -BeNullOrEmpty
			Compare-Object $records[1] @{ Id = 456; FirstName = "Cédric"; LastName = "Belin" } | Should -BeNullOrEmpty
			Compare-Object $records[2] @{ RowID = 789 } | Should -BeNullOrEmpty
		}
	}
}
