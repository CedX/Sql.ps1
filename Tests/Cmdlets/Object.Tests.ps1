using module ../../Sql.psd1
using module ../Fixtures/Character.psm1

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
			$records | Should -HaveCount 16
			$records[0].Id | Should -Be 1
			$records[0].FullName | Should -BeExactly Aragorn
			$records[15].Id | Should -Be 16
			$records[15].FullName | Should -BeExactly Sauron
		}

		It "should allow sorting the results by a specific set of columns" {
			$records = Find-SqlObject $connection -All -Class ([Character]) -OrderBy ([ordered]@{ gender = "Ascending"; fullName = "Descending" })
			$records | Should -HaveCount 16
			$records[0].Id | Should -Be 11
			$records[0].FullName | Should -BeExactly Gothmog
			$records[15].Id | Should -Be 8
			$records[15].FullName | Should -BeExactly Gandalf
		}

		It "should allow selecting a specific set of columns" {
			$records = Find-SqlObject $connection -All -Class ([Character]) -Columns gender
			$records[0].Id | Should -Be 1
			$records[0].Gender | Should -Be ([CharacterGender]::Human)
			$records[0].FullName | Should -BeNullOrEmpty
			$records[15].Id | Should -Be 16
			$records[15].Gender | Should -Be ([CharacterGender]::DarkLord)
			$records[15].FullName | Should -BeNullOrEmpty
		}
	}

	Context "Id" {
		It "should find the record with the specified identifier" {
			$record = Find-SqlObject $connection -Class ([Character]) -Id 2
			$record | Should -Not -BeNullOrEmpty
			$record.Id | Should -Be 2
			$record.FullName | Should -BeExactly Balin

			$record = Find-SqlObject $connection -Class ([Character]) -Id 14
			$record | Should -Not -BeNullOrEmpty
			$record.Id | Should -Be 14
			$record.FullName | Should -BeExactly "Sam Gamgee"
		}

		It "should allow selecting a specific set of columns" {
			$record = Find-SqlObject $connection -Class ([Character]) -Id 2 -Columns gender
			$record.FullName | Should -BeNullOrEmpty
			$record.Gender | Should -Be ([CharacterGender]::Dwarf)

			$record = Find-SqlObject $connection -Class ([Character]) -Id 14 -Columns gender
			$record.FullName | Should -BeNullOrEmpty
			$record.Gender | Should -Be ([CharacterGender]::Hobbit)
		}

		It "should return `$null if the record is not found" {
			Find-SqlObject $connection -Class ([Character]) -Id 666 | Should -BeNullOrEmpty
		}
	}
}

<#
.SYNOPSIS
	Tests the features of the `Publish-Object` cmdlet.
#>
Describe "Publish-Object" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should insert the specified record" {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Cédric'"
		Invoke-SqlQuery $connection -As ([Character]) -Command $sql | Should -BeNullOrEmpty

		$record = [Character]@{ FirstName = "Cédric"; LastName = "Belin"; Gender = "Istari" }
		$record.Id | Should -Be 0
		$record.FullName | Should -BeNullOrEmpty

		$id = Publish-SqlObject $connection -InputObject $record
		$id | Should -BeGreaterThan 16
		$record.Id | Should -Be $id

		$records = Invoke-SqlQuery $connection -As ([Character]) -Command $sql
		$records | Should -HaveCount 1

		$cedric = $records[0]
		$cedric.Id | Should -Be $id
		$cedric.FullName | Should -BeExactly "Cédric Belin"
		$cedric.Gender | Should -Be $record.Gender
	}
}

<#
.SYNOPSIS
	Tests the features of the `Remove-Object` cmdlet.
#>
Describe "Remove-Object" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should delete the record with the specified identifier" {
		$sql = "SELECT * FROM Characters WHERE ID = @Id"
		$record = Get-SqlSingle $connection -As ([Character]) -Command $sql -Parameters @{ Id = 1 }
		Remove-SqlObject $connection -InputObject $record | Should -BeTrue
		Remove-SqlObject $connection -InputObject $record | Should -BeFalse
		Get-SqlFirst $connection -As ([Character]) -Command $sql -Parameters @{ Id = 1 } -ErrorAction Ignore | Should -BeNullOrEmpty
	}
}

<#
.SYNOPSIS
	Tests the features of the `Test-Object` cmdlet.
#>
Describe "Test-Object" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should delete the record with the specified identifier" {
		Test-SqlObject $connection -Class ([Character]) -Id 1 | Should -BeTrue
		Test-SqlObject $connection -Class ([Character]) -Id 666 | Should -BeFalse
	}
}

<#
.SYNOPSIS
	Tests the features of the `Update-Object` cmdlet.
#>
Describe "Update-Object" {
	BeforeEach { . "$PSScriptRoot/../BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/../AfterEach.ps1" }

	It "should update the specified record" {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Sauron'"

		$sauron = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$sauron.FullName | Should -BeExactly Sauron
		$sauron.Gender | Should -Be ([CharacterGender]::DarkLord)

		$sauron.LastName = "The big bad guy"
		$sauron.Gender = [CharacterGender]::Istari
		Update-SqlObject $connection -InputObject $sauron | Should -Be 1

		$sauron = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$sauron.FullName | Should -BeExactly "Sauron The big bad guy"
		$sauron.Gender | Should -Be ([CharacterGender]::Istari)
	}

	It "should allow updating a specific set of columns" {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Saruman'"

		$saruman = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$saruman.FullName | Should -BeExactly Saruman
		$saruman.Gender | Should -Be ([CharacterGender]::Istari)

		$saruman.LastName = "The traitor"
		$saruman.Gender = [CharacterGender]::DarkLord
		Update-SqlObject $connection -InputObject $saruman -Columns gender | Should -Be 1

		$saruman = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$saruman.FullName | Should -BeExactly Saruman
		$saruman.Gender | Should -Be ([CharacterGender]::DarkLord)
	}
}
