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
		[SuppressMessage("PSUseDeclaredVarsMoreThanAssignments", "")]
		$character = [Character]@{ Id = 1000; FirstName = "Cédric"; Gender = [CharacterGender]::DarkLord }

		[SuppressMessage("PSUseDeclaredVarsMoreThanAssignments", "")]
		$connection = New-SqlConnection ([System.Data.SQLite.SQLiteConnection]) "DataSource=:memory:"
	}

	Context "GetDeleteCommand" {
		It "should return the SQL command to delete an entity" {
			$command = (New-SqlCommandBuilder $connection).GetDeleteCommand($character)
			Should-BeLikeString 'DELETE FROM "main"."Characters"*' $command.Item1.Text -CaseSensitive
			Should-BeLikeString '*WHERE "ID" = @ID' $command.Item1.Text -CaseSensitive
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetDeleteCommand($character)
			Should-BeString "@ID" $command.Item2[0].Name -CaseSensitive
			Should-Be 1000 $command.Item2[0].Value
		}
	}

	Context "GetDeleteAllCommand" {
		It "should return the SQL command to delete an entity" {
			$command = (New-SqlCommandBuilder $connection).GetDeleteAllCommand([Character])
			Should-BeString 'DELETE FROM "main"."Characters"' $command.Item1.Text -CaseSensitive
		}

		It "should also return an empty parameter collection" {
			$command = (New-SqlCommandBuilder $connection).GetDeleteAllCommand([Character])
			Should-Be 0 $command.Item2.Count
		}
	}

	Context "GetExistsCommand" {
		It "should return the SQL command to check the existence of an entity" {
			$command = (New-SqlCommandBuilder $connection).GetExistsCommand([Character], $character.Id)
			Should-BeLikeString "SELECT 1*" $command.Item1.Text -CaseSensitive
			Should-BeLikeString '*FROM "main"."Characters"*' $command.Item1.Text -CaseSensitive
			Should-BeLikeString '*WHERE "ID" = @ID' $command.Item1.Text -CaseSensitive
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetExistsCommand([Character], $character.Id)
			Should-BeString "@ID" $command.Item2[0].Name -CaseSensitive
			Should-Be 1000 $command.Item2[0].Value
		}
	}

	Context "GetFindCommand" {
		It "should return the SQL command to find an entity" {
			$command = (New-SqlCommandBuilder $connection).GetFindCommand([Character], $character.Id)
			Should-BeLikeString 'SELECT "*' $command.Item1.Text -CaseSensitive
			Should-NotBeLikeString '*`**' $command.Item1.Text
			Should-BeLikeString '*FROM "main"."Characters"*' $command.Item1.Text -CaseSensitive
			Should-BeLikeString '*WHERE "ID" = @ID' $command.Item1.Text -CaseSensitive
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetFindCommand([Character], $character.Id)
			Should-BeString "@ID" $command.Item2[0].Name -CaseSensitive
			Should-Be 1000 $command.Item2[0].Value
		}

		It "should allow selecting a specific set of columns" {
			$command = (New-SqlCommandBuilder $connection).GetFindCommand([Character], $character.Id, "firstName")
			Should-BeLikeString 'SELECT "firstName"*' $command.Item1.Text -CaseSensitive
			Should-NotBeLikeString "*gender*" $command.Item1.Text
			Should-NotBeLikeString "*lastName*" $command.Item1.Text
			Should-BeLikeString '*WHERE "ID" = @ID' $command.Item1.Text -CaseSensitive
		}
	}

	Context "GetFindAllCommand" {
		It "should return the SQL command to find all entities" {
			$command = (New-SqlCommandBuilder $connection).GetFindAllCommand([Character])
			Should-BeLikeString 'SELECT "*' $command.Item1.Text -CaseSensitive
			Should-NotBeLikeString '*`**' $command.Item1.Text
			Should-BeLikeString '*FROM "main"."Characters"*' $command.Item1.Text -CaseSensitive
			Should-BeLikeString '*ORDER BY "ID" ASC' $command.Item1.Text -CaseSensitive
		}

		It "should also return an empty parameter collection" {
			$command = (New-SqlCommandBuilder $connection).GetFindAllCommand([Character])
			Should-Be 0 $command.Item2.Count
		}

		It "should allow sorting the results by a specific set of columns" {
			$orderHints = [ordered]@{ gender = "Ascending"; fullName = "Descending" }
			$command = (New-SqlCommandBuilder $connection).GetFindAllCommand([Character], $orderHints)
			Should-BeLikeString 'SELECT "*' $command.Item1.Text -CaseSensitive
			Should-NotBeLikeString '*`**' $command.Item1.Text
			Should-BeLikeString '*FROM "main"."Characters"*' $command.Item1.Text -CaseSensitive
			Should-BeLikeString '*ORDER BY "gender" ASC, "fullName" DESC' $command.Item1.Text -CaseSensitive
		}

		It "should allow selecting a specific set of columns" {
			$command = (New-SqlCommandBuilder $connection).GetFindAllCommand([Character], "firstName")
			Should-BeLikeString 'SELECT "firstName"*' $command.Item1.Text -CaseSensitive
			Should-NotBeLikeString "*gender*" $command.Item1.Text
			Should-NotBeLikeString "*lastName*" $command.Item1.Text
			Should-BeLikeString '*ORDER BY "ID" ASC' $command.Item1.Text -CaseSensitive
		}
	}

	Context "GetInsertCommand" {
		It "should return the SQL command to insert an entity" {
			$command = (New-SqlCommandBuilder $connection).GetInsertCommand($character)
			Should-BeLikeString 'INSERT INTO "main"."Characters" (*' $command.Item1.Text -CaseSensitive
			Should-BeLikeString "*VALUES (*" $command.Item1.Text -CaseSensitive
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetInsertCommand($character)
			Should-Be 3 $command.Item2.Count
			Should-BeString Cédric $command.Item2["firstName"].Value -CaseSensitive
			Should-Be ([CharacterGender]::DarkLord) $command.Item2["gender"].Value
			Should-BeEmptyString $command.Item2["lastName"].Value
		}
	}

	Context "GetUpdateCommand" {
		It "should return the SQL command to update an entity" {
			$command = (New-SqlCommandBuilder $connection).GetUpdateCommand($character)
			Should-BeLikeString 'UPDATE "main"."Characters"*' $command.Item1.Text -CaseSensitive
			Should-BeLikeString '*SET "*' $command.Item1.Text -CaseSensitive
			Should-BeLikeString '*WHERE "ID" = @ID' $command.Item1.Text -CaseSensitive
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetUpdateCommand($character)
			Should-Be 4 $command.Item2.Count
			Should-Be 1000 $command.Item2["ID"].Value
			Should-BeString Cédric $command.Item2["firstName"].Value -CaseSensitive
			Should-Be ([CharacterGender]::DarkLord) $command.Item2["gender"].Value
			Should-BeEmptyString $command.Item2["lastName"].Value
		}

		It "should allow updating a specific set of columns" {
			$command = (New-SqlCommandBuilder $connection).GetUpdateCommand($character, "firstName")
			Should-Be 2 $command.Item2.Count
			Should-Be 1000 $command.Item2["ID"].Value
			Should-BeString Cédric $command.Item2["firstName"].Value -CaseSensitive
		}
	}
}
