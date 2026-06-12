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

	Context "CreateInstance" {
		It "should create a [psobject] instance" {
			$properties = @{ CLASS = "Bard/minstrel"; firstName = "Cédric"; gender = "Balrog"; lastName = $null }
			$object = (Get-SqlMapper).CreateInstance([psobject], $properties)
			$object | Should -BeOfType ([psobject])
			$object.CLASS | Should -BeExactly "Bard/minstrel"
			$object.firstName | Should -BeExactly Cédric
			$object.gender | Should -BeExactly ([CharacterGender]::Balrog.ToString())
			$object.lastName | Should -BeNullOrEmpty
		}

		It "should create an object of the specified type" {
			$properties = @{ CLASS = "Bard/minstrel"; firstName = "Cédric"; gender = "Balrog"; lastName = $null }
			$object = (Get-SqlMapper).CreateInstance([Character], $properties)
			$object | Should -BeOfType ([Character])
			$object.FirstName | Should -BeExactly Cédric
			$object.Gender | Should -Be ([CharacterGender]::Balrog)
			$object.LastName | Should -Be ""
		}
	}

	Context "GetTable" {
		It "should return detailed information about the database table associated with the specified entity class" {
			$table = (Get-SqlMapper).GetTable([Character])
			$table.Schema | Should -BeExactly main
			$table.Name | Should -BeExactly Characters
			$table.Type | Should -Be ([Character])

			$table.Columns.Keys | Should -HaveCount 5
			$table.IdentityColumn | Should -Be $table.Columns.ID
			$table.Columns.gender.PropertyType | Should -Be ([CharacterGender])
			$table.Columns.lastName.PropertyType | Should -Be ([string])

			$table.Columns.firstName.CanWrite | Should -BeTrue
			$table.Columns.fullName.IsComputed | Should -BeTrue
			$table.Columns.ID.IsIdentity | Should -BeTrue
		}
	}
}
