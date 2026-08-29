using module ../Sql.psd1
using module ./Character.psm1

<#
.SYNOPSIS
	Tests the features of the `Find-Object` cmdlet.
#>
Describe "Find-Object" {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

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

<#
.SYNOPSIS
	Tests the features of the `Measure-Object` cmdlet.
#>
Describe "Measure-Object" {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	Context "All" {
		It "should return the total number of entities from the underlying table" {
			Should-Be 16 (Measure-SqlObject $connection -Class ([Character]) -All)
		}
	}
}

<#
.SYNOPSIS
	Tests the features of the `Publish-Object` cmdlet.
#>
Describe "Publish-Object" {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should insert the specified entity" {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Cédric'"
		Should-BeNull (Invoke-SqlQuery $connection -As ([Character]) -Command $sql)

		$record = [Character]@{ FirstName = "Cédric"; LastName = "Belin"; Gender = "Istari" }
		Should-Be 0 $record.Id
		Should-BeEmptyString $record.FullName

		$id = Publish-SqlObject $connection -InputObject $record
		Should-BeGreaterThan 16 $id
		Should-Be $id $record.Id

		$records = Invoke-SqlQuery $connection -As ([Character]) -Command $sql
		Should-Be 1 $records.Count

		$cedric = $records[0]
		Should-Be $id $cedric.Id
		Should-BeString "Cédric Belin" $cedric.FullName -CaseSensitive
		Should-Be $record.Gender $cedric.Gender
	}
}

<#
.SYNOPSIS
	Tests the features of the `Remove-Object` cmdlet.
#>
Describe "Remove-Object" {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	Context "All" {
		It "should remove all entities from the underlying table" {
			$sql = "SELECT COUNT(*) FROM Characters"
			Should-BeGreaterThan 0 (Get-SqlScalar $connection -As ([int]) -Command $sql)
			Remove-SqlObject $connection -Class ([Character]) -All -Truncate
			Should-Be 0 (Get-SqlScalar $connection -As ([int]) -Command $sql)
		}
	}

	Context "InputObject" {
		It "should delete the entity with the specified identifier" {
			$sql = "SELECT * FROM Characters WHERE ID = @Id"
			$record = Get-SqlSingle $connection -As ([Character]) -Command $sql -Parameters @{ Id = 1 }
			Should-BeTrue (Remove-SqlObject $connection -InputObject $record)
			Should-BeFalse (Remove-SqlObject $connection -InputObject $record)
			Should-BeNull (Get-SqlFirst $connection -As ([Character]) -Command $sql -Parameters @{ Id = 1 } -ErrorAction Ignore)
		}
	}
}

<#
.SYNOPSIS
	Tests the features of the `Test-Object` cmdlet.
#>
Describe "Test-Object" {
	BeforeEach { . "$PSScriptRoot/BeforeEach.ps1" }
	AfterEach { . "$PSScriptRoot/AfterEach.ps1" }

	It "should `$true if the specified identifier exists" {
		Should-BeTrue (Test-SqlObject $connection -Class ([Character]) -Id 1)
	}

	It "should `$false if the specified identifier does not exist" {
		Should-BeFalse (Test-SqlObject $connection -Class ([Character]) -Id 666)
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
		Should-BeString Sauron $sauron.FullName -CaseSensitive
		Should-Be ([CharacterGender]::DarkLord) $sauron.Gender

		$sauron.LastName = "The big bad guy"
		$sauron.Gender = [CharacterGender]::Istari
		Should-Be 1 (Update-SqlObject $connection -InputObject $sauron)

		$sauron = Get-SqlSingle $connection -As ([Character]) -Command $sql
		Should-BeString "Sauron The big bad guy" $sauron.FullName -CaseSensitive
		Should-Be ([CharacterGender]::Istari) $sauron.Gender
	}

	It "should allow updating a specific set of columns" {
		$sql = "SELECT * FROM Characters WHERE firstName = 'Saruman'"

		$saruman = Get-SqlSingle $connection -As ([Character]) -Command $sql
		Should-BeString Saruman $saruman.FullName -CaseSensitive
		Should-Be ([CharacterGender]::Istari) $saruman.Gender

		$saruman.LastName = "The traitor"
		$saruman.Gender = [CharacterGender]::DarkLord
		Should-Be 1 (Update-SqlObject $connection -InputObject $saruman -Columns gender)

		$saruman = Get-SqlSingle $connection -As ([Character]) -Command $sql
		Should-BeString Saruman $saruman.FullName -CaseSensitive
		Should-Be ([CharacterGender]::DarkLord) $saruman.Gender
	}
}
