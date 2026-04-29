using namespace System.Collections.Generic
using module ../src/SqlMapper.psm1
using module ./Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `SqlMapper` class.
#>
Describe "SqlMapper" {
	BeforeAll {
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

	# Context "CreateInstance" {
	# 	$properties = new Dictionary<string, object?> {
	# 		["CLASS"] = "Bard/minstrel",
	# 		["firstName"] = "Cédric",
	# 		["gender"] = CharacterGender.Balrog.ToString(),
	# 		["lastName"] = $null
	# 	}

	# 	dynamic instance = [SqlMapper]::Instance.CreateInstance(properties)
	# 	AreEqual("Bard/minstrel", instance.CLASS)
	# 	AreEqual("Cédric", instance.firstName)
	# 	AreEqual(CharacterGender.Balrog.ToString(), instance.gender)
	# 	IsNull(instance.lastName)

	# 	$character = [SqlMapper]::Instance.CreateInstance<Character>(properties)
	# 	AreEqual("Cédric", character.FirstName)
	# 	AreEqual(CharacterGender.Balrog, character.Gender)
	# 	AreEqual("", character.LastName)
	# }

	# Context "GetTable" {
	# 	$table = [SqlMapper]::Instance.GetTable<Character>()
	# 	AreEqual("main", table.Schema)
	# 	AreEqual("Characters", table.Name)
	# 	AreEqual(typeof(Character), table.Type)

	# 	HasCount(5, table.Columns.Keys)
	# 	AreEqual(table.Columns["ID"], table.IdentityColumn)
	# 	AreEqual(typeof(CharacterGender), table.Columns["gender"].Type)
	# 	AreEqual(typeof(string), table.Columns["lastName"].Type)

	# 	IsTrue(table.Columns["firstName"].CanWrite)
	# 	IsTrue(table.Columns["fullName"].IsComputed)
	# 	IsTrue(table.Columns["ID"].IsIdentity)
	# }

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
