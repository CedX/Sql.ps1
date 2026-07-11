using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Find-Object` cmdlet.
#>
Describe "Find-Object" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	Context "All" {
		It "should return the complete list of entities, sorted by default according to the identity column" {
			$records = Find-SqlObject $connection -All -Class ([Character])
			Should-Be 16 $records.Count
			Should-Be 1 $records[0].Id
			Should-BeString Aragorn $records[0].FullName -CaseSensitive
			Should-Be 16 $records[15].Id
			Should-BeString Sauron $records[15].FullName -CaseSensitive
		}

		It "should allow sorting the results by a specific set of columns" {
			$records = Find-SqlObject $connection -All -Class ([Character]) -OrderBy ([ordered]@{ gender = "Ascending"; fullName = "Descending" })
			Should-Be 16 $records.Count
			Should-Be 11 $records[0].Id
			Should-BeString Gothmog $records[0].FullName -CaseSensitive
			Should-Be 8 $records[15].Id
			Should-BeString Gandalf $records[15].FullName -CaseSensitive
		}

		It "should allow selecting a specific set of columns" {
			$records = Find-SqlObject $connection -All -Class ([Character]) -Columns gender
			Should-Be 1 $records[0].Id
			Should-Be ([CharacterGender]::Human) $records[0].Gender
			Should-BeEmptyString $records[0].FullName
			Should-Be 16 $records[15].Id
			Should-Be ([CharacterGender]::DarkLord) $records[15].Gender
			Should-BeEmptyString $records[15].FullName
		}
	}

	Context "Id" {
		It "should find the entity with the specified identifier" {
			$record = Find-SqlObject $connection -Class ([Character]) -Id 2
			Should-NotBeNull $record
			Should-Be 2 $record.Id
			Should-BeString Balin $record.FullName -CaseSensitive

			$record = Find-SqlObject $connection -Class ([Character]) -Id 14
			Should-NotBeNull $record
			Should-Be 14 $record.Id
			Should-BeString "Sam Gamgee" $record.FullName -CaseSensitive
		}

		It "should allow selecting a specific set of columns" {
			$record = Find-SqlObject $connection -Class ([Character]) -Id 2 -Columns gender
			Should-BeEmptyString $record.FullName
			Should-Be ([CharacterGender]::Dwarf) $record.Gender

			$record = Find-SqlObject $connection -Class ([Character]) -Id 14 -Columns gender
			Should-BeEmptyString $record.FullName
			Should-Be ([CharacterGender]::Hobbit) $record.Gender
		}

		It "should return `$null if the entity is not found" {
			Should-BeNull (Find-SqlObject $connection -Class ([Character]) -Id 666)
		}
	}
}
