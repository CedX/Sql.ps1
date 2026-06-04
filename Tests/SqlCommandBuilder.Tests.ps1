using namespace System.Diagnostics.CodeAnalysis
using assembly ../Binaries/System.Data.SQLite.dll
using module ../Sources/SqlCommandBuilder.psm1
using module ./Fixtures/Character.psm1

<#
.SYNOPSIS
	Tests the features of the `SqlCommandBuilder` class.
#>
Describe "SqlCommandBuilder" {
	BeforeAll {
		[SuppressMessage("PSUseDeclaredVarsMoreThanAssignments", "")]
		$record = [Character]@{ Id = 1000; FirstName = "Cédric"; Gender = [CharacterGender]::DarkLord }

		[SuppressMessage("PSUseDeclaredVarsMoreThanAssignments", "")]
		$connection = [System.Data.SQLite.SQLiteConnection] "DataSource=:memory:"
	}

	Context "GetDeleteCommand" {
		It "should return the SQL command to delete an entity" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetDeleteCommand($record)
			$command.Text | Should -BeLikeExactly 'DELETE FROM "main"."Characters"*'
			$command.Text | Should -BeLikeExactly '*WHERE "ID" = @ID'
		}

		It "should also return the parameters used by the SQL command" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetDeleteCommand($record)
			$parameters[0].Name | Should -BeExactly "@ID"
			$parameters[0].Value | Should -Be 1000
		}
	}

	Context "GetDeleteAllCommand" {
		It "should return the SQL command to delete an entity" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetDeleteAllCommand([Character])
			$command.Text | Should -BeExactly 'DELETE FROM "main"."Characters"'
		}

		It "should also return an empty parameter collection" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetDeleteAllCommand([Character])
			$parameters | Should -BeNullOrEmpty
		}
	}

	Context "GetExistsCommand" {
		It "should return the SQL command to check the existence of an entity" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetExistsCommand([Character], $record.Id)
			$command.Text | Should -BeLikeExactly "SELECT 1*"
			$command.Text | Should -BeLikeExactly '*FROM "main"."Characters"*'
			$command.Text | Should -BeLikeExactly '*WHERE "ID" = @ID'
		}

		It "should also return the parameters used by the SQL command" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetExistsCommand([Character], $record.Id)
			$parameters[0].Name | Should -BeExactly "@ID"
			$parameters[0].Value | Should -Be 1000
		}
	}

	Context "GetFindCommand" {
		It "should return the SQL command to find an entity" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetFindCommand([Character], $record.Id)
			$command.Text | Should -BeLikeExactly 'SELECT "*'
			$command.Text | Should -Not -BeLike '*`**'
			$command.Text | Should -BeLikeExactly '*FROM "main"."Characters"*'
			$command.Text | Should -BeLikeExactly '*WHERE "ID" = @ID'
		}

		It "should also return the parameters used by the SQL command" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetFindCommand([Character], $record.Id)
			$parameters[0].Name | Should -BeExactly "@ID"
			$parameters[0].Value | Should -Be 1000
		}

		It "should allow selecting a specific set of columns" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetFindCommand([Character], $record.Id, "firstName")
			$command.Text | Should -BeLikeExactly 'SELECT "firstName"*'
			$command.Text | Should -Not -BeLike "*gender*"
			$command.Text | Should -Not -BeLike "*lastName*"
			$command.Text | Should -BeLikeExactly '*WHERE "ID" = @ID'
		}
	}

	Context "GetFindAllCommand" {
		It "should return the SQL command to find all entities" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetFindAllCommand([Character])
			$command.Text | Should -BeLikeExactly 'SELECT "*'
			$command.Text | Should -Not -BeLike '*`**'
			$command.Text | Should -BeLikeExactly '*FROM "main"."Characters"*'
			$command.Text | Should -BeLikeExactly '*ORDER BY "ID" ASC'
		}

		It "should also return an empty parameter collection" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetFindAllCommand([Character])
			$parameters | Should -BeNullOrEmpty
		}

		It "should allow sorting the results by a specific set of columns" {
			$orderHints = [ordered]@{ gender = "Ascending"; fullName = "Descending" }
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetFindAllCommand([Character], $orderHints)
			$command.Text | Should -BeLikeExactly 'SELECT "*'
			$command.Text | Should -Not -BeLike '*`**'
			$command.Text | Should -BeLikeExactly '*FROM "main"."Characters"*'
			$command.Text | Should -BeLikeExactly '*ORDER BY "gender" ASC, "fullName" DESC'
		}

		It "should allow selecting a specific set of columns" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetFindAllCommand([Character], $null, "firstName")
			$command.Text | Should -BeLikeExactly 'SELECT "firstName"*'
			$command.Text | Should -Not -BeLike "*gender*"
			$command.Text | Should -Not -BeLike "*lastName*"
			$command.Text | Should -BeLikeExactly '*ORDER BY "ID" ASC'
		}
	}

	Context "GetInsertCommand" {
		It "should return the SQL command to insert an entity" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetInsertCommand($record)
			$command.Text | Should -BeLikeExactly 'INSERT INTO "main"."Characters" (*'
			$command.Text | Should -BeLikeExactly "*VALUES (*"
		}

		It "should also return the parameters used by the SQL command" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetInsertCommand($record)
			$parameters | Should -HaveCount 3
			$parameters["firstName"].Value | Should -BeExactly Cédric
			$parameters["gender"].Value | Should -BeExactly DarkLord
			$parameters["lastName"].Value | Should -Be ""
		}
	}

	Context "GetUpdateCommand" {
		It "should return the SQL command to update an entity" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetUpdateCommand($record)
			$command.Text | Should -BeLikeExactly 'UPDATE "main"."Characters"*'
			$command.Text | Should -BeLikeExactly '*SET "*'
			$command.Text | Should -BeLikeExactly '*WHERE "ID" = @ID'
		}

		It "should also return the parameters used by the SQL command" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetUpdateCommand($record)
			$parameters | Should -HaveCount 4
			$parameters["ID"].Value | Should -Be 1000
			$parameters["firstName"].Value | Should -BeExactly Cédric
			$parameters["gender"].Value | Should -BeExactly DarkLord
			$parameters["lastName"].Value | Should -Be ""
		}

		It "should allow updating a specific set of columns" {
			$command, $parameters = [SqlCommandBuilder]::new($connection).GetUpdateCommand($record, "firstName")
			$parameters | Should -HaveCount 2
			$parameters["ID"].Value | Should -Be 1000
			$parameters["firstName"].Value | Should -BeExactly Cédric
		}
	}
}
