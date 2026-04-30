<#
.SYNOPSIS
	Tests the features of the `Get-Mapper` cmdlet.
#>
Describe "Get-Mapper" {
	BeforeAll {
		. "$PSScriptRoot/BeforeAll.ps1"
	}

	Describe "CreateInstance()" {
		It "should create instances of the requested type" {
			$properties = @{
				CLASS = "Bard/minstrel"
				firstName = "Cédric"
				gender = [CharacterGender]::Balrog.ToString()
				lastName = $null
			}

			$instance = (Get-SqlMapper).CreateInstance($properties)
			$instance.GetType().FullName | Should -BeExactly System.Dynamic.ExpandoObject
			$instance.CLASS | Should -BeExactly "Bard/minstrel"
			$instance.firstName | Should -BeExactly "Cédric"
			$instance.gender | Should -BeExactly ([CharacterGender]::Balrog.ToString())
			$instance.lastName | Should -Be $null

			$character = (Get-SqlMapper).CreateInstance[Character]($properties)
			$character.GetType().Name | Should -BeExactly Character
			$character.FirstName | Should -BeExactly "Cédric"
			$character.Gender | Should -Be ([CharacterGender]::Balrog)
			$character.LastName | Should -Be $null
		}
	}

	Describe "GetTable()" {
		It "should return information about the tables and columns of an entity type" {
			$table = (Get-SqlMapper).GetTable[Character]()
			$table.Schema | Should -BeExactly main
			$table.Name | Should -BeExactly Characters
			$table.Type | Should -Be ([Character])

			$table.Columns.Keys | Should -HaveCount 5
			$table.IdentityColumn | Should -Be $table.Columns["ID"]
			$table.Columns["gender"].Type | Should -Be ([CharacterGender])
			$table.Columns["lastName"].Type | Should -Be ([string])

			$table.Columns["firstName"].CanWrite | Should -BeTrue
			$table.Columns["fullName"].IsComputed | Should -BeTrue
			$table.Columns["ID"].IsIdentity | Should -BeTrue
		}
	}
}
