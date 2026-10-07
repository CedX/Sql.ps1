using module ../Sql.psd1
using module ./Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Find-Object` cmdlet.
#>
Describe "Find-Object" -Skip {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	Context "All" {
		It "should return the complete list of entities, sorted by default according to the identity column" {
			$records = Find-SqlObject $connection -All -Class ([Character])
			$records.Count | Should-Be 16
			$records[0].Id | Should-Be 1
			$records[0].FullName | Should-BeString "Aragorn" -CaseSensitive
			$records[15].Id | Should-Be 16
			$records[15].FullName | Should-BeString "Sauron" -CaseSensitive
		}

		It "should allow sorting the results by a specific set of columns" {
			$records = Find-SqlObject $connection -All -Class ([Character]) -OrderBy ([ordered]@{ gender = "Ascending"; fullName = "Descending" })
			$records.Count | Should-Be 16
			$records[0].Id | Should-Be 11
			$records[0].FullName | Should-BeString "Gothmog" -CaseSensitive
			$records[15].Id | Should-Be 8
			$records[15].FullName | Should-BeString "Gandalf" -CaseSensitive
		}

		It "should allow selecting a specific set of columns" {
			$records = Find-SqlObject $connection -All -Class ([Character]) -Columns gender
			$records[0].Id | Should-Be 1
			$records[0].Gender | Should-Be ([CharacterGender]::Human)
			$records[0].FullName | Should-BeEmptyString
			$records[15].Id | Should-Be 16
			$records[15].Gender | Should-Be ([CharacterGender]::DarkLord)
			$records[15].FullName | Should-BeEmptyString
		}
	}

	Context "Id" {
		It "should find the entity with the specified identifier" {
			$record = Find-SqlObject $connection -Class ([Character]) -Id 2
			$record | Should-NotBeNull
			$record.Id | Should-Be 2
			$record.FullName | Should-BeString "Balin" -CaseSensitive

			$record = Find-SqlObject $connection -Class ([Character]) -Id 14
			$record | Should-NotBeNull
			$record.Id | Should-Be 14
			$record.FullName | Should-BeString "Sam Gamgee"-CaseSensitive
		}

		It "should allow selecting a specific set of columns" {
			$record = Find-SqlObject $connection -Class ([Character]) -Id 2 -Columns gender
			$record.FullName | Should-BeEmptyString
			$record.Gender | Should-Be ([CharacterGender]::Dwarf)

			$record = Find-SqlObject $connection -Class ([Character]) -Id 14 -Columns gender
			$record.FullName | Should-BeEmptyString
			$record.Gender | Should-Be ([CharacterGender]::Hobbit)
		}

		It "should return `$null if the entity is not found" {
			Find-SqlObject $connection -Class ([Character]) -Id 666 | Should-BeNull
		}
	}
}

<#
.SYNOPSIS
	Tests the features of the `Measure-Object` cmdlet.
#>
Describe "Measure-Object" -Skip {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	Context "All" {
		It "should return the total number of entities from the underlying table" {
			Measure-SqlObject $connection -Class ([Character]) -All | Should-Be 16
		}
	}
}

<#
.SYNOPSIS
	Tests the features of the `Publish-Object` cmdlet.
#>
Describe "Publish-Object" -Skip {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should insert the specified entity" {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Cédric'"
		Invoke-SqlQuery $connection -As ([Character]) -Command $sql | Should-BeNull

		$record = [Character]@{ FirstName = "Cédric"; LastName = "Belin"; Gender = "Istari" }
		$record.Id | Should-Be 0
		$record.FullName | Should-BeEmptyString

		$id = Publish-SqlObject $connection -InputObject $record
		$id | Should-BeGreaterThan 16
		$record.Id | Should-Be $id

		$records = Invoke-SqlQuery $connection -As ([Character]) -Command $sql
		$records.Count | Should-Be 1

		$cedric = $records[0]
		$cedric.Id | Should-Be $id
		$cedric.FullName | Should-BeString "Cédric Belin" -CaseSensitive
		$cedric.Gender | Should-Be $record.Gender
	}
}

<#
.SYNOPSIS
	Tests the features of the `Remove-Object` cmdlet.
#>
Describe "Remove-Object" -Skip {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	Context "All" {
		It "should remove all entities from the underlying table" {
			$sql = "SELECT COUNT(*) FROM Characters"
			Get-SqlScalar $connection -As ([int]) -Command $sql | Should-BeGreaterThan 0
			Remove-SqlObject $connection -Class ([Character]) -All -Truncate
			Get-SqlScalar $connection -As ([int]) -Command $sql | Should-Be 0
		}
	}

	Context "InputObject" {
		It "should delete the entity with the specified identifier" {
			$sql = "SELECT * FROM Characters WHERE ID = @Id"
			$record = Get-SqlSingle $connection -As ([Character]) -Command $sql -Parameters @{ Id = 1 }
			Remove-SqlObject $connection -InputObject $record | Should-BeTrue
			Remove-SqlObject $connection -InputObject $record | Should-BeFalse
			Get-SqlFirst $connection -As ([Character]) -Command $sql -Parameters @{ Id = 1 } -ErrorAction Ignore | Should-BeNull
		}
	}
}

<#
.SYNOPSIS
	Tests the features of the `Test-Object` cmdlet.
#>
Describe "Test-Object" -Skip {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should `$true if the specified identifier exists" {
		Test-SqlObject $connection -Class ([Character]) -Id 1 | Should-BeTrue
	}

	It "should `$false if the specified identifier does not exist" {
		Test-SqlObject $connection -Class ([Character]) -Id 666 | Should-BeFalse
	}
}

<#
.SYNOPSIS
	Tests the features of the `Update-Object` cmdlet.
#>
Describe "Update-Object" {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should update the specified entity" {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Sauron'"

		$sauron = Get-SqlSingle $connection -As ([Character]) -Command $sql
		Write-Host ($sauron | ConvertTo-Json)
		$sauron.FullName | Should-BeString "Sauron" -CaseSensitive
		$sauron.Gender | Should-Be ([CharacterGender]::DarkLord)

		$sauron.LastName = "The big bad guy"
		$sauron.Gender = [CharacterGender]::Istari
		Update-SqlObject $connection -InputObject $sauron | Should-Be 1

		$sauron = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$sauron.FullName | Should-BeString "Sauron The big bad guy" -CaseSensitive
		$sauron.Gender | Should-Be ([CharacterGender]::Istari)
	}

	It "should allow updating a specific set of columns" -Skip {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Saruman'"

		$saruman = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$saruman.FullName | Should-BeString "Saruman" -CaseSensitive
		$saruman.Gender | Should-Be ([CharacterGender]::Istari)

		$saruman.LastName = "The traitor"
		$saruman.Gender = [CharacterGender]::DarkLord
		Update-SqlObject $connection -InputObject $saruman -Columns gender | Should-Be 1

		$saruman = Get-SqlSingle $connection -As ([Character]) -Command $sql
		$saruman.FullName | Should-BeString "Saruman" -CaseSensitive
		$saruman.Gender | Should-Be ([CharacterGender]::DarkLord)
	}
}
