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

	<#
	.SYNOPSIS
		The test data used by the `ChangeType` method.
	#>
	# hidden static IEnumerable<object?[]> ChangeTypeData => [
	# 	[null, typeof(bool), false, false],
	# 	[null, typeof(bool?), true, null],
	# 	[0, typeof(bool), false, false],
	# 	[0, typeof(bool?), true, false],
	# 	[1, typeof(bool), false, true],
	# 	[1, typeof(bool?), true, true],
	# 	["false", typeof(bool), false, false],
	# 	["true", typeof(bool), false, true],

	# 	[null, typeof(char), false, char.MinValue],
	# 	[null, typeof(char?), true, null],
	# 	[0, typeof(char), false, char.MinValue],
	# 	[65_535, typeof(char?), true, char.MaxValue],
	# 	[97, typeof(char), false, 'a'],
	# 	[98, typeof(char?), true, 'b'],
	# 	["a", typeof(char), false, 'a'],
	# 	["b", typeof(char?), true, 'b'],

	# 	[null, typeof(DateTime), false, DateTime.MinValue],
	# 	[null, typeof(DateTime?), true, null],
	# 	[DateTime.MaxValue, typeof(DateTime), false, DateTime.MaxValue],
	# 	[DateTime.UnixEpoch, typeof(DateTime?), true, DateTime.UnixEpoch],
	# 	[new DateTime(2025, 6, 7, 10, 45, 1), typeof(DateTime), false, new DateTime(2025, 6, 7, 10, 45, 1)],
	# 	[new DateTime(2026, 1, 31), typeof(DateTime?), true, new DateTime(2026, 1, 31)],
	# 	["2025-06-07 10:45:01", typeof(DateTime), false, new DateTime(2025, 6, 7, 10, 45, 1)],
	# 	["2025-06-07T10:45:01", typeof(DateTime?), true, new DateTime(2025, 6, 7, 10, 45, 1)],

	# 	[null, typeof(DayOfWeek), false, DayOfWeek.Sunday],
	# 	[null, typeof(DayOfWeek?), true, null],
	# 	[0, typeof(DayOfWeek), false, DayOfWeek.Sunday],
	# 	[1, typeof(DayOfWeek?), true, DayOfWeek.Monday],
	# 	[5, typeof(DayOfWeek), false, DayOfWeek.Friday],
	# 	[6, typeof(DayOfWeek?), true, DayOfWeek.Saturday],
	# 	["sunday", typeof(DayOfWeek), false, DayOfWeek.Sunday],
	# 	["friday", typeof(DayOfWeek?), true, DayOfWeek.Friday],

	# 	[null, typeof(double), false, 0.0],
	# 	[null, typeof(double?), true, null],
	# 	[0, typeof(double), false, 0.0],
	# 	[0, typeof(double?), true, 0.0],
	# 	[123, typeof(double), false, 123.0],
	# 	[-123.456, typeof(double?), true, -123.456],
	# 	["123", typeof(double), false, 123.0],
	# 	["-123.456", typeof(double?), true, -123.456],

	# 	[null, typeof(int), false, 0],
	# 	[null, typeof(int?), true, null],
	# 	[0, typeof(int), false, 0],
	# 	[0, typeof(int?), true, 0],
	# 	[123, typeof(int), false, 123],
	# 	[-123.456, typeof(int?), true, -123],
	# 	["123", typeof(int), false, 123],
	# 	["-123", typeof(int?), true, -123]
	# ]

	# [TestMethod, DynamicData(nameof(ChangeTypeData))]
	# Context "ChangeType(object? value, Type conversionType, bool isNullable, object? expected) =>
	# 	AreEqual(expected, [SqlMapper]::ChangeType(value, conversionType, isNullable))

	# Context "CreateInstance" {
	# 	$properties = new Dictionary<string, object?> {
	# 		["CLASS"] = "Bard/minstrel",
	# 		["firstName"] = "Cédric",
	# 		["gender"] = CharacterGender.Balrog.ToString(),
	# 		["lastName"] = null
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
