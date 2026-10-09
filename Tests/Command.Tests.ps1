using assembly ../Binaries/System.Data.SQLite.dll
using namespace System.Collections.Generic
using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis
using module ../Sql.psd1
using module ./Character.psm1

<#
.SYNOPSIS
	Tests the features of the `New-Command` cmdlet.
#>
Describe "New-Command" {
	Context "ImplicitConversion" {
		It "should create a command from the specified string" {
			[Belin.Sql.SqlCommand] $command = "SELECT * FROM Characters"
			$command.Text | Should-BeString "SELECT * FROM Characters" -CaseSensitive
		}
	}
}

<#
.SYNOPSIS
	Tests the features of the `New-CommandBuilder` cmdlet.
#>
Describe "New-CommandBuilder" {
	BeforeAll {
		[SuppressMessage("PSUseDeclaredVarsMoreThanAssignments", "character")]
		$character = [Character]@{ Id = 1000; FirstName = "Cédric"; Gender = [CharacterGender]::DarkLord }

		[SuppressMessage("PSUseDeclaredVarsMoreThanAssignments", "connection")]
		$connection = New-SqlConnection ([System.Data.SQLite.SQLiteConnection]) "DataSource=:memory:"
	}

	Context "GetDeleteCommand" {
		It "should return the SQL command to delete an entity" {
			$command = (New-SqlCommandBuilder $connection).GetDeleteCommand($character)
			$command.Item1.Text | Should-BeLikeString 'DELETE FROM "main"."Characters"*' -CaseSensitive
			$command.Item1.Text | Should-BeLikeString '*WHERE "ID" = @ID' -CaseSensitive
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetDeleteCommand($character)
			$command.Item2[0].Name | Should-BeString "@ID" -CaseSensitive
			$command.Item2[0].Value | Should-Be 1000
		}
	}

	Context "GetDeleteAllCommand" {
		It "should return the SQL command to delete an entity" {
			$command = (New-SqlCommandBuilder $connection).GetDeleteAllCommand([Character])
			$command.Item1.Text | Should-BeString 'DELETE FROM "main"."Characters"' -CaseSensitive
		}

		It "should also return an empty parameter collection" {
			$command = (New-SqlCommandBuilder $connection).GetDeleteAllCommand([Character])
			$command.Item2.Count | Should-Be 0
		}
	}

	Context "GetExistsCommand" {
		It "should return the SQL command to check the existence of an entity" {
			$command = (New-SqlCommandBuilder $connection).GetExistsCommand([Character], $character.Id)
			$command.Item1.Text | Should-BeLikeString "SELECT 1*" -CaseSensitive
			$command.Item1.Text | Should-BeLikeString '*FROM "main"."Characters"*' -CaseSensitive
			$command.Item1.Text | Should-BeLikeString '*WHERE "ID" = @ID' -CaseSensitive
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetExistsCommand([Character], $character.Id)
			$command.Item2[0].Name | Should-BeString "@ID" -CaseSensitive
			$command.Item2[0].Value | Should-Be 1000
		}
	}

	Context "GetFindCommand" {
		It "should return the SQL command to find an entity" {
			$command = (New-SqlCommandBuilder $connection).GetFindCommand([Character], $character.Id)
			$command.Item1.Text | Should-BeLikeString 'SELECT "*' -CaseSensitive
			$command.Item1.Text | Should-NotBeLikeString '*`**'
			$command.Item1.Text | Should-BeLikeString '*FROM "main"."Characters"*' -CaseSensitive
			$command.Item1.Text | Should-BeLikeString '*WHERE "ID" = @ID' -CaseSensitive
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetFindCommand([Character], $character.Id)
			$command.Item2[0].Name | Should-BeString "@ID" -CaseSensitive
			$command.Item2[0].Value | Should-Be 1000
		}

		It "should allow selecting a specific set of columns" {
			$command = (New-SqlCommandBuilder $connection).GetFindCommand([Character], $character.Id, "firstName")
			$command.Item1.Text | Should-BeLikeString 'SELECT "firstName"*' -CaseSensitive
			$command.Item1.Text | Should-NotBeLikeString "*gender*"
			$command.Item1.Text | Should-NotBeLikeString "*lastName*"
			$command.Item1.Text | Should-BeLikeString '*WHERE "ID" = @ID' -CaseSensitive
		}
	}

	Context "GetFindAllCommand" {
		It "should return the SQL command to find all entities" {
			$command = (New-SqlCommandBuilder $connection).GetFindAllCommand([Character])
			$command.Item1.Text | Should-BeLikeString 'SELECT "*' -CaseSensitive
			$command.Item1.Text | Should-NotBeLikeString '*`**'
			$command.Item1.Text | Should-BeLikeString '*FROM "main"."Characters"*' -CaseSensitive
			$command.Item1.Text | Should-BeLikeString '*ORDER BY "ID" ASC' -CaseSensitive
		}

		It "should also return an empty parameter collection" {
			$command = (New-SqlCommandBuilder $connection).GetFindAllCommand([Character])
			$command.Item2.Count | Should-Be 0
		}

		It "should allow sorting the results by a specific set of columns" {
			$orderHints = [ordered]@{ gender = "Ascending"; fullName = "Descending" }
			$command = (New-SqlCommandBuilder $connection).GetFindAllCommand([Character], $orderHints)
			$command.Item1.Text | Should-BeLikeString 'SELECT "*' -CaseSensitive
			$command.Item1.Text | Should-NotBeLikeString '*`**'
			$command.Item1.Text | Should-BeLikeString '*FROM "main"."Characters"*' -CaseSensitive
			$command.Item1.Text | Should-BeLikeString '*ORDER BY "gender" ASC, "fullName" DESC' -CaseSensitive
		}

		It "should allow selecting a specific set of columns" {
			$command = (New-SqlCommandBuilder $connection).GetFindAllCommand([Character], "firstName")
			$command.Item1.Text | Should-BeLikeString 'SELECT "firstName"*' -CaseSensitive
			$command.Item1.Text | Should-NotBeLikeString "*gender*"
			$command.Item1.Text | Should-NotBeLikeString "*lastName*"
			$command.Item1.Text | Should-BeLikeString '*ORDER BY "ID" ASC' -CaseSensitive
		}
	}

	Context "GetInsertCommand" {
		It "should return the SQL command to insert an entity" {
			$command = (New-SqlCommandBuilder $connection).GetInsertCommand($character)
			$command.Item1.Text | Should-BeLikeString 'INSERT INTO "main"."Characters" (*' -CaseSensitive
			$command.Item1.Text | Should-BeLikeString "*VALUES (*" -CaseSensitive
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetInsertCommand($character)
			$command.Item2.Count | Should-Be 3
			$command.Item2["firstName"].Value | Should-BeString "Cédric" -CaseSensitive
			$command.Item2["gender"].Value | Should-Be ([CharacterGender]::DarkLord)
			$command.Item2["lastName"].Value | Should-BeEmptyString
		}
	}

	Context "GetUpdateCommand" {
		It "should return the SQL command to update an entity" {
			$command = (New-SqlCommandBuilder $connection).GetUpdateCommand($character)
			$command.Item1.Text | Should-BeLikeString 'UPDATE "main"."Characters"*' -CaseSensitive
			$command.Item1.Text | Should-BeLikeString '*SET "*' -CaseSensitive
			$command.Item1.Text | Should-BeLikeString '*WHERE "ID" = @ID' -CaseSensitive
		}

		It "should also return the parameters used by the SQL command" {
			$command = (New-SqlCommandBuilder $connection).GetUpdateCommand($character)
			$command.Item2.Count | Should-Be 4
			$command.Item2["ID"].Value | Should-Be 1000
			$command.Item2["firstName"].Value | Should-BeString "Cédric" -CaseSensitive
			$command.Item2["gender"].Value | Should-Be ([CharacterGender]::DarkLord)
			$command.Item2["lastName"].Value | Should-BeEmptyString
		}

		It "should allow updating a specific set of columns" {
			$command = (New-SqlCommandBuilder $connection).GetUpdateCommand($character, "firstName")
			$command.Item2.Count | Should-Be 2
			$command.Item2["ID"].Value | Should-Be 1000
			$command.Item2["firstName"].Value | Should-BeString Cédric -CaseSensitive
		}
	}
}

<#
.SYNOPSIS
	Tests the features of the `New-OrderHint` cmdlet.
#>
Describe "New-OrderHint" {
	Context "ImplicitConversion" {
		It "should create an order hint from the specified column name" {
			[Belin.Sql.SqlOrderHint] $orderHint = "Name"
			$orderHint.Column | Should-BeString "Name" -CaseSensitive
			$orderHint.SortOrder | Should-Be ([Belin.Sql.SortOrder]::Ascending)
		}

		It "should create an order hint from the specified array" {
			[Belin.Sql.SqlOrderHint] $orderHint = "ID", "Descending"
			$orderHint.Column | Should-BeString ID -CaseSensitive
			$orderHint.SortOrder | Should-Be ([Belin.Sql.SortOrder]::Descending)
		}

		It "should create an order hint from the specified tuple" {
			[Belin.Sql.SqlOrderHint] $orderHint = [ValueTuple]::Create("ID", [Belin.Sql.SortOrder]::Descending)
			$orderHint.Column | Should-BeString ID -CaseSensitive
			$orderHint.SortOrder | Should-Be ([Belin.Sql.SortOrder]::Descending)
		}

		It "should create an order hint from the specified key/value pair" {
			[Belin.Sql.SqlOrderHint] $orderHint = [KeyValuePair[string, Belin.Sql.SortOrder]]::new("Name", "Ascending")
			$orderHint.Column | Should-BeString Name -CaseSensitive
			$orderHint.SortOrder | Should-Be ([Belin.Sql.SortOrder]::Ascending)
		}
	}
}

<#
.SYNOPSIS
	Tests the features of the `New-OrderHintCollection` cmdlet.
#>
Describe "New-OrderHintCollection" {
	It "should create an empty collection by default" {
		$collection = New-SqlOrderHintCollection
		$collection | Should-BeCollection -Count 0
	}

	It "should create a collection from a single order hint" {
		$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending)
		$collection | Should-BeCollection -Count 1

		$orderHint = $collection[0]
		$orderHint.Column | Should-BeString "ID" -CaseSensitive
		$orderHint.SortOrder | Should-Be ([Belin.Sql.SortOrder]::Descending)
	}

	It "should create a collection from an array of order hints" {
		$orderHints = (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
		$collection = New-SqlOrderHintCollection $orderHints
		$collection | Should-BeCollection -Count 2

		$orderHint = $collection[-1]
		$orderHint.Column | Should-BeString Name -CaseSensitive
		$orderHint.SortOrder | Should-Be ([Belin.Sql.SortOrder]::Ascending)
	}

	Context "Contains" {
		It "should return `$true if the collection contains the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint Key)
			$collection.Contains("key") | Should-BeTrue
			$collection.Contains("KEY") | Should-BeTrue
		}

		It "should return `$false if the collection does not contain the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint Key)
			$collection.Contains("foo") | Should-BeFalse
		}
	}

	Context "ImplicitConversion" {
		It "should create a collection from the specified array of column names" {
			[Belin.Sql.SqlOrderHintCollection] $collection = "ID", "Name"
			$collection | ForEach-Object { $_.Column } | Should-BeCollection ("ID", "Name")
			$collection | ForEach-Object { $_.SortOrder } | Should-BeCollection ([Belin.Sql.SortOrder]::Ascending, [Belin.Sql.SortOrder]::Ascending)
		}

		It "should create a collection from the specified list of column names" {
			[Belin.Sql.SqlOrderHintCollection] $collection = [List[string]]::new([string[]] ("ID", "Name"))
			$collection | ForEach-Object { $_.Column } | Should-BeCollection ("ID", "Name")
			$collection | ForEach-Object { $_.SortOrder } | Should-BeCollection ([Belin.Sql.SortOrder]::Ascending, [Belin.Sql.SortOrder]::Ascending)
		}

		It "should create a collection from the specified dictionary of column names and sort orders" {
			[Belin.Sql.SqlOrderHintCollection] $collection = [ordered]@{ ID = [Belin.Sql.SortOrder]::Descending; Name = [Belin.Sql.SortOrder]::Ascending }
			$collection | ForEach-Object { $_.Column }| Should-BeCollection ("ID", "Name")
			$collection | ForEach-Object { $_.SortOrder } | Should-BeCollection ([Belin.Sql.SortOrder]::Descending, [Belin.Sql.SortOrder]::Ascending)
		}
	}

	Context "Indexer" {
		It "should return the order hint with the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			$orderHint = $collection["id"]
			$orderHint.Column | Should-BeString "ID" -CaseSensitive
			$orderHint.SortOrder | Should-Be ([Belin.Sql.SortOrder]::Descending)
			$collection[0] | Should-Be $orderHint
		}

		It "should return `$null, or throw an error, if the specified column name does not exist" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			$collection["foo"] | Should-BeNull

			Set-StrictMode -Version Latest
			{ $collection["foo"] } | Should-Throw
			Set-StrictMode -Off
		}
	}

	Context "IndexOf" {
		It "should return the index if the order hint is found" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			$collection.IndexOf("id") | Should-Be 0
			$collection.IndexOf("name") | Should-Be 1
		}

		It "should return -1 if the order hint is not found" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			$collection.IndexOf("foo") | Should-Be -1
		}
	}

	Context "RemoveAt" {
		It "should remove the order hint with the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			$collection | Should-BeCollection -Count 2
			$collection.RemoveAt("name")
			$collection | Should-BeCollection -Count 1
			$collection.RemoveAt("id")
			$collection | Should-BeCollection -Count 0
		}

		It "should throw an error if the specified column name does not exist" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			{ $collection.RemoveAt("Foo") } | Should-Throw
		}
	}
}

<#
.SYNOPSIS
	Tests the features of the `New-Parameter` cmdlet.
#>
Describe "New-Parameter" {
	Context "ImplicitConversion" {
		It "should create a parameter from the specified array" {
			[Belin.Sql.SqlParameter] $parameter = "", $null
			$parameter.Name | Should-BeString "?" -CaseSensitive
			$parameter.Value | Should-Be ([DBNull]::Value)

			$parameter = ":foo", "bar"
			$parameter.Name | Should-BeString ":foo" -CaseSensitive
			$parameter.Value | Should-BeString "bar" -CaseSensitive

			$parameter = "bar", 123
			$parameter.Name | Should-BeString "@bar" -CaseSensitive
			$parameter.Value | Should-Be 123
		}

		It "should create a parameter from the specified tuple" {
			[Belin.Sql.SqlParameter] $parameter = [ValueTuple]::Create("", [object] $null)
			$parameter.Name | Should-BeString "?" -CaseSensitive
			$parameter.Value | Should-Be ([DBNull]::Value)

			$parameter = [ValueTuple]::Create(":foo", [object] "bar")
			$parameter.Name | Should-BeString ":foo" -CaseSensitive
			$parameter.Value | Should-BeString "bar" -CaseSensitive

			$parameter = [ValueTuple]::Create("bar", [object] 123)
			$parameter.Name | Should-BeString "@bar" -CaseSensitive
			$parameter.Value | Should-Be 123
		}

		It "should create a parameter from the specified key/value pair" {
			[Belin.Sql.SqlParameter] $parameter = [KeyValuePair[string, object]]::new("foo", $null)
			$parameter.Name | Should-BeString "@foo" -CaseSensitive
			$parameter.Value | Should-Be ([DBNull]::Value)

			$parameter = [KeyValuePair[string, object]]::new(":bar", "Baz")
			$parameter.Name | Should-BeString ":bar" -CaseSensitive
			$parameter.Value | Should-BeString Baz -CaseSensitive
		}
	}

	Context "Name" {
		It "should normalize the parameter name" -ForEach @(
			@{ Name = ""; Expected = "?" }
			@{ Name = "?"; Expected = "?" }
			@{ Name = "?1"; Expected = "?1" }
			@{ Name = "foo"; Expected = "@foo" }
			@{ Name = "@bar"; Expected = "@bar" }
			@{ Name = ":baz"; Expected = ":baz" }
			@{ Name = "`$qux"; Expected = "`$qux" }
		) {
			$parameter = New-SqlParameter $name
			$parameter.Name | Should-BeString $expected -CaseSensitive
		}
	}

	Context "Value" {
		It "should normalize the parameter value" -ForEach @(
			@{ Value = $null; Expected = [DBNull]::Value }
			@{ Value = [DBNull]::Value; Expected = [DBNull]::Value }
			@{ Value = 123; Expected = 123 }
			@{ Value = -123.456; Expected = -123.456 }
			@{ Value = ""; Expected = "" }
			@{ Value = "Foo"; Expected = "Foo" }
			@{ Value = [datetime]::UnixEpoch; Expected = [datetime]::UnixEpoch }
		) {
			$parameter = New-SqlParameter Name $value
			$parameter.Value | Should-Be $expected
		}

		It "should support the values wrapped in a [psobject] instance" -ForEach ([DBNull]::Value, "Foo", [datetime]::UnixEpoch) {
			$parameter = New-SqlParameter Name ([psobject]::AsPSObject($_))
			$parameter.Value | Should-Be $_
		}
	}
}

<#
.SYNOPSIS
	Tests the features of the `New-ParameterCollection` cmdlet.
#>
Describe "New-ParameterCollection" {
	It "should create an empty collection by default" {
		$collection = New-SqlParameterCollection
		$collection | Should-BeCollection -Count 0
	}

	It "should create a collection from a single parameter" {
		$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123 -DbType Int64)
		$collection | Should-BeCollection -Count 1

		$parameter = $collection[0]
		$parameter.Name | Should-BeString "?1" -CaseSensitive
		$parameter.Value | Should-Be 123
		$parameter.DbType | Should-Be ([DbType]::Int64)
	}

	It "should create a collection from an array of parameters" {
		$parameters = (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
		$collection = New-SqlParameterCollection $parameters
		$collection | Should-BeCollection -Count 2

		$parameter = $collection[-1]
		$parameter.Name | Should-BeString "@Key" -CaseSensitive
		$parameter.Value | Should-BeString "Unique" -CaseSensitive
		$parameter.DbType | Should-Be ([DbType]::AnsiString)
	}

	Context "AddWithValue" {
		It "should add a new parameter to the collection" {
			$collection = New-SqlParameterCollection
			$collection | Should-BeCollection -Count 0

			$parameter = $collection.AddWithValue("Name", "Value1")
			$collection | Should-BeCollection -Count 1
			$parameter.Name | Should-BeString "@Name" -CaseSensitive
			$parameter.Value | Should-BeString "Value1" -CaseSensitive

			$parameter = $collection.AddWithValue("Value2")
			$collection | Should-BeCollection -Count 2
			$parameter.Name | Should-BeString "?2" -CaseSensitive
			$parameter.Value | Should-BeString "Value2" -CaseSensitive
		}
	}

	Context "Contains" {
		It "should return `$true if the collection contains the specified parameter" {
			$collection = New-SqlParameterCollection (New-SqlParameter "@Key")
			$collection.Contains("Key") | Should-BeTrue
			$collection.Contains("@Key") | Should-BeTrue
		}

		It "should return `$false if the collection does not contain the specified parameter" {
			$collection = New-SqlParameterCollection (New-SqlParameter "@Key")
			$collection.Contains("Foo") | Should-BeFalse
			$collection.Contains("@Foo") | Should-BeFalse
		}
	}

	Context "ImplicitConversion" {
		It "should create a collection from the specified array of postional parameters" {
			[Belin.Sql.SqlParameterCollection] $collection = "foo", "bar"
			$collection | ForEach-Object { $_.Name } | Should-BeCollection ("?1", "?2")
			$collection | ForEach-Object { $_.Value } | Should-BeCollection ("foo", "bar")
		}

		It "should create a collection from the specified list of postional parameters" {
			[Belin.Sql.SqlParameterCollection] $collection = [List[object]]::new(("foo", "bar"))
			$collection | ForEach-Object { $_.Name } | Should-BeCollection ("?1", "?2")
			$collection | ForEach-Object { $_.Value } | Should-BeCollection ("foo", "bar")
		}

		It "should create a collection from the specified hash table of named parameters" {
			[Belin.Sql.SqlParameterCollection] $collection = @{ foo = "bar"; baz = "qux" }
			Compare-Object @("@foo", "@baz") ($collection | ForEach-Object { $_.Name }) | Should-BeNull
			Compare-Object @("bar", "qux") ($collection | ForEach-Object { $_.Value }) | Should-BeNull
		}
	}

	Context "Indexer" {
		It "should return the parameter with the specified name" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			$parameter = $collection["Key"]
			$parameter.Name | Should-BeString "@Key" -CaseSensitive
			$parameter.Value | Should-BeString "Unique" -CaseSensitive
			$collection[1] | Should-Be $parameter
		}

		It "should return `$null, or throw an error, if the specified name does not exist" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			$collection["@Foo"] | Should-BeNull

			Set-StrictMode -Version Latest
			{ $collection["@Foo"] } | Should-Throw
			Set-StrictMode -Off
		}
	}

	Context "IndexOf" {
		It "should return the index if the parameter is found" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			$collection.IndexOf("Key") | Should-Be 1
			$collection.IndexOf("@Key") | Should-Be 1
		}

		It "should return -1 if the parameter is not found" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			$collection.IndexOf("Foo") | Should-Be -1
			$collection.IndexOf("@Foo") | Should-Be -1
		}
	}

	Context "RemoveAt" {
		It "should remove the parameter with the specified name" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			$collection | Should-BeCollection -Count 2
			$collection.RemoveAt("Key")
			$collection | Should-BeCollection -Count 1
			$collection.RemoveAt("?1")
			$collection | Should-BeCollection -Count 0
		}

		It "should throw an error if the specified name does not exist" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			{ $collection.RemoveAt("Foo") } | Should-Throw
		}
	}
}
