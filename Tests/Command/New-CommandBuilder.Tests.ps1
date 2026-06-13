using namespace System.Diagnostics.CodeAnalysis
using assembly ../../Binaries/System.Data.SQLite.dll
using module ../../Sql.psd1
using module ../Character.psm1

<#
.SYNOPSIS
	Tests the features of the `New-CommandBuilder` cmdlet.
#>
Describe "New-CommandBuilder" {
	BeforeAll {
		[SuppressMessage("PSUseDeclaredVarsMoreThanAssignments")]
		$character = [Character]@{ Id = 1000; FirstName = "Cédric"; Gender = [CharacterGender]::DarkLord }

		[SuppressMessage("PSUseDeclaredVarsMoreThanAssignments")]
		$connection = New-SqlConnection ([System.Data.SQLite.SQLiteConnection]) "DataSource=:memory:"
	}

	Context "GetDeleteCommand" {
		It "should return the SQL command to delete an entity" {
			$command = (New-SqlCommandBuilder $connection).GetDeleteCommand($character)
			$command.Item1.Text | Should -BeLikeExactly 'DELETE FROM "main"."Characters"*'
			$command.Item1.Text | Should -BeLikeExactly '*WHERE "ID" = @ID'
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetDeleteCommand($character)
			$command.Item2[0].Name | Should -BeExactly "@ID"
			$command.Item2[0].Value | Should -Be 1000
		}
	}

	Context "GetDeleteAllCommand" {
		It "should return the SQL command to delete an entity" {
			$command = (New-SqlCommandBuilder $connection).GetDeleteAllCommand([Character])
			$command.Item1.Text | Should -BeExactly 'DELETE FROM "main"."Characters"'
		}

		It "should also return an empty parameter collection" {
			$command = (New-SqlCommandBuilder $connection).GetDeleteAllCommand([Character])
			$command.Item2 | Should -BeNullOrEmpty
		}
	}

	Context "GetExistsCommand" {
		It "should return the SQL command to check the existence of an entity" {
			$command = (New-SqlCommandBuilder $connection).GetExistsCommand([Character], $character.Id)
			$command.Item1.Text | Should -BeLikeExactly "SELECT 1*"
			$command.Item1.Text | Should -BeLikeExactly '*FROM "main"."Characters"*'
			$command.Item1.Text | Should -BeLikeExactly '*WHERE "ID" = @ID'
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetExistsCommand([Character], $character.Id)
			$command.Item2[0].Name | Should -BeExactly "@ID"
			$command.Item2[0].Value | Should -Be 1000
		}
	}

	Context "GetFindCommand" {
		It "should return the SQL command to find an entity" {
			$command = (New-SqlCommandBuilder $connection).GetFindCommand([Character], $character.Id)
			$command.Item1.Text | Should -BeLikeExactly 'SELECT "*'
			$command.Item1.Text | Should -Not -BeLike '*`**'
			$command.Item1.Text | Should -BeLikeExactly '*FROM "main"."Characters"*'
			$command.Item1.Text | Should -BeLikeExactly '*WHERE "ID" = @ID'
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetFindCommand([Character], $character.Id)
			$command.Item2[0].Name | Should -BeExactly "@ID"
			$command.Item2[0].Value | Should -Be 1000
		}

		It "should allow selecting a specific set of columns" {
			$command = (New-SqlCommandBuilder $connection).GetFindCommand([Character], $character.Id, "firstName")
			$command.Item1.Text | Should -BeLikeExactly 'SELECT "firstName"*'
			$command.Item1.Text | Should -Not -BeLike "*gender*"
			$command.Item1.Text | Should -Not -BeLike "*lastName*"
			$command.Item1.Text | Should -BeLikeExactly '*WHERE "ID" = @ID'
		}
	}

	Context "GetFindAllCommand" {
		It "should return the SQL command to find all entities" {
			$command = (New-SqlCommandBuilder $connection).GetFindAllCommand([Character])
			$command.Item1.Text | Should -BeLikeExactly 'SELECT "*'
			$command.Item1.Text | Should -Not -BeLike '*`**'
			$command.Item1.Text | Should -BeLikeExactly '*FROM "main"."Characters"*'
			$command.Item1.Text | Should -BeLikeExactly '*ORDER BY "ID" ASC'
		}

		It "should also return an empty parameter collection" {
			$command = (New-SqlCommandBuilder $connection).GetFindAllCommand([Character])
			$command.Item2 | Should -BeNullOrEmpty
		}

		It "should allow sorting the results by a specific set of columns" {
			$orderHints = [ordered]@{ gender = "Ascending"; fullName = "Descending" }
			$command = (New-SqlCommandBuilder $connection).GetFindAllCommand([Character], $orderHints)
			$command.Item1.Text | Should -BeLikeExactly 'SELECT "*'
			$command.Item1.Text | Should -Not -BeLike '*`**'
			$command.Item1.Text | Should -BeLikeExactly '*FROM "main"."Characters"*'
			$command.Item1.Text | Should -BeLikeExactly '*ORDER BY "gender" ASC, "fullName" DESC'
		}

		It "should allow selecting a specific set of columns" {
			$command = (New-SqlCommandBuilder $connection).GetFindAllCommand([Character], "firstName")
			$command.Item1.Text | Should -BeLikeExactly 'SELECT "firstName"*'
			$command.Item1.Text | Should -Not -BeLike "*gender*"
			$command.Item1.Text | Should -Not -BeLike "*lastName*"
			$command.Item1.Text | Should -BeLikeExactly '*ORDER BY "ID" ASC'
		}
	}

	Context "GetInsertCommand" {
		It "should return the SQL command to insert an entity" {
			$command = (New-SqlCommandBuilder $connection).GetInsertCommand($character)
			$command.Item1.Text | Should -BeLikeExactly 'INSERT INTO "main"."Characters" (*'
			$command.Item1.Text | Should -BeLikeExactly "*VALUES (*"
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetInsertCommand($character)
			$command.Item2 | Should -HaveCount 3
			$command.Item2["firstName"].Value | Should -BeExactly Cédric
			$command.Item2["gender"].Value | Should -BeExactly DarkLord
			$command.Item2["lastName"].Value | Should -Be ""
		}
	}

	Context "GetUpdateCommand" {
		It "should return the SQL command to update an entity" {
			$command = (New-SqlCommandBuilder $connection).GetUpdateCommand($character)
			$command.Item1.Text | Should -BeLikeExactly 'UPDATE "main"."Characters"*'
			$command.Item1.Text | Should -BeLikeExactly '*SET "*'
			$command.Item1.Text | Should -BeLikeExactly '*WHERE "ID" = @ID'
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetUpdateCommand($character)
			$command.Item2 | Should -HaveCount 4
			$command.Item2["ID"].Value | Should -Be 1000
			$command.Item2["firstName"].Value | Should -BeExactly Cédric
			$command.Item2["gender"].Value | Should -BeExactly DarkLord
			$command.Item2["lastName"].Value | Should -Be ""
		}

		It "should allow updating a specific set of columns" {
			$command = (New-SqlCommandBuilder $connection).GetUpdateCommand($character, "firstName")
			$command.Item2 | Should -HaveCount 2
			$command.Item2["ID"].Value | Should -Be 1000
			$command.Item2["firstName"].Value | Should -BeExactly Cédric
		}
	}
}
