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
			Should-BeString "SELECT * FROM Characters" $command.Text -CaseSensitive
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

<#
.SYNOPSIS
	Tests the features of the `New-OrderHint` cmdlet.
#>
Describe "New-OrderHint" {
	Context "ImplicitConversion" {
		It "should create an order hint from the specified column name" {
			[Belin.Sql.SqlOrderHint] $orderHint = "Name"
			Should-BeString Name $orderHint.Column -CaseSensitive
			Should-Be ([Belin.Sql.SortOrder]::Ascending) $orderHint.SortOrder
		}

		It "should create an order hint from the specified array" {
			[Belin.Sql.SqlOrderHint] $orderHint = "ID", "Descending"
			Should-BeString ID $orderHint.Column -CaseSensitive
			Should-Be ([Belin.Sql.SortOrder]::Descending) $orderHint.SortOrder
		}

		It "should create an order hint from the specified tuple" {
			[Belin.Sql.SqlOrderHint] $orderHint = [ValueTuple]::Create("ID", [Belin.Sql.SortOrder]::Descending)
			Should-BeString ID $orderHint.Column -CaseSensitive
			Should-Be ([Belin.Sql.SortOrder]::Descending) $orderHint.SortOrder
		}

		It "should create an order hint from the specified key/value pair" {
			[Belin.Sql.SqlOrderHint] $orderHint = [KeyValuePair[string, Belin.Sql.SortOrder]]::new("Name", "Ascending")
			Should-BeString Name $orderHint.Column -CaseSensitive
			Should-Be ([Belin.Sql.SortOrder]::Ascending) $orderHint.SortOrder
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
		Should-BeCollection $collection -Count 0
	}

	It "should create a collection from a single order hint" {
		$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending)
		Should-BeCollection $collection -Count 1

		$orderHint = $collection[0]
		Should-BeString ID $orderHint.Column -CaseSensitive
		Should-Be ([Belin.Sql.SortOrder]::Descending) $orderHint.SortOrder
	}

	It "should create a collection from an array of order hints" {
		$orderHints = (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
		$collection = New-SqlOrderHintCollection $orderHints
		Should-BeCollection $collection -Count 2

		$orderHint = $collection[-1]
		Should-BeString Name $orderHint.Column -CaseSensitive
		Should-Be ([Belin.Sql.SortOrder]::Ascending) $orderHint.SortOrder
	}

	Context "Contains" {
		It "should return `$true if the collection contains the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint Key)
			Should-BeTrue $collection.Contains("key")
			Should-BeTrue $collection.Contains("KEY")
		}

		It "should return `$false if the collection does not contain the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint Key)
			Should-BeFalse $collection.Contains("foo")
		}
	}

	Context "ImplicitConversion" {
		It "should create a collection from the specified array of column names" {
			[Belin.Sql.SqlOrderHintCollection] $collection = "ID", "Name"
			Should-BeCollection ("ID", "Name") $collection.PSForEach{ $_.Column }
			Should-BeCollection ([Belin.Sql.SortOrder]::Ascending, [Belin.Sql.SortOrder]::Ascending) $collection.PSForEach{ $_.SortOrder }
		}

		It "should create a collection from the specified list of column names" {
			[Belin.Sql.SqlOrderHintCollection] $collection = [List[string]]::new([string[]] ("ID", "Name"))
			Should-BeCollection ("ID", "Name") $collection.PSForEach{ $_.Column }
			Should-BeCollection ([Belin.Sql.SortOrder]::Ascending, [Belin.Sql.SortOrder]::Ascending) $collection.PSForEach{ $_.SortOrder }
		}

		It "should create a collection from the specified dictionary of column names and sort orders" {
			[Belin.Sql.SqlOrderHintCollection] $collection = [ordered]@{ ID = [Belin.Sql.SortOrder]::Descending; Name = [Belin.Sql.SortOrder]::Ascending }
			Should-BeCollection ("ID", "Name") $collection.PSForEach{ $_.Column }
			Should-BeCollection ([Belin.Sql.SortOrder]::Descending, [Belin.Sql.SortOrder]::Ascending) $collection.PSForEach{ $_.SortOrder }
		}
	}

	Context "Indexer" {
		It "should return the order hint with the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			$orderHint = $collection["id"]
			Should-BeString ID $orderHint.Column -CaseSensitive
			Should-Be ([Belin.Sql.SortOrder]::Descending) $orderHint.SortOrder
			Should-Be $orderHint $collection[0]
		}

		It "should return `$null, or throw an error, if the specified column name does not exist" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			Should-BeNull $collection["foo"]

			Set-StrictMode -Version Latest
			Should-Throw -ScriptBlock { $collection["foo"] }
			Set-StrictMode -Off
		}
	}

	Context "IndexOf" {
		It "should return the index if the order hint is found" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			Should-Be 0 $collection.IndexOf("id")
			Should-Be 1 $collection.IndexOf("name")
		}

		It "should return -1 if the order hint is not found" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			Should-Be -1 $collection.IndexOf("foo")
		}
	}

	Context "RemoveAt" {
		It "should remove the order hint with the specified column name" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			Should-BeCollection $collection -Count 2
			$collection.RemoveAt("name")
			Should-BeCollection $collection -Count 1
			$collection.RemoveAt("id")
			Should-BeCollection $collection -Count 0
		}

		It "should throw an error if the specified column name does not exist" {
			$collection = New-SqlOrderHintCollection (New-SqlOrderHint ID Descending), (New-SqlOrderHint Name)
			Should-Throw -ScriptBlock { $collection.RemoveAt("Foo") }
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
			Should-BeString "?" $parameter.Name -CaseSensitive
			Should-Be ([DBNull]::Value) $parameter.Value

			$parameter = ":foo", "bar"
			Should-BeString ":foo" $parameter.Name -CaseSensitive
			Should-BeString "bar" $parameter.Value -CaseSensitive

			$parameter = "bar", 123
			Should-BeString "@bar" $parameter.Name -CaseSensitive
			Should-Be 123 $parameter.Value
		}

		It "should create a parameter from the specified tuple" {
			[Belin.Sql.SqlParameter] $parameter = [ValueTuple]::Create("", [object] $null)
			Should-BeString "?" $parameter.Name -CaseSensitive
			Should-Be ([DBNull]::Value) $parameter.Value

			$parameter = [ValueTuple]::Create(":foo", [object] "bar")
			Should-BeString ":foo" $parameter.Name -CaseSensitive
			Should-BeString "bar" $parameter.Value -CaseSensitive

			$parameter = [ValueTuple]::Create("bar", [object] 123)
			Should-BeString "@bar" $parameter.Name -CaseSensitive
			Should-Be 123 $parameter.Value
		}

		It "should create a parameter from the specified key/value pair" {
			[Belin.Sql.SqlParameter] $parameter = [KeyValuePair[string, object]]::new("foo", $null)
			Should-BeString "@foo" $parameter.Name -CaseSensitive
			Should-Be ([DBNull]::Value) $parameter.Value

			$parameter = [KeyValuePair[string, object]]::new(":bar", "Baz")
			Should-BeString ":bar" $parameter.Name -CaseSensitive
			Should-BeString Baz $parameter.Value -CaseSensitive
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
			Should-BeString $expected $parameter.Name -CaseSensitive
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
			Should-Be $expected $parameter.Value
		}

		It "should support the values wrapped in a [psobject] instance" -ForEach ([DBNull]::Value, "Foo", [datetime]::UnixEpoch) {
			$parameter = New-SqlParameter Name ([psobject]::AsPSObject($_))
			Should-Be $_ $parameter.Value
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
		Should-BeCollection $collection -Count 0
	}

	It "should create a collection from a single parameter" {
		$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123 -DbType Int64)
		Should-BeCollection $collection -Count 1

		$parameter = $collection[0]
		Should-BeString "?1" $parameter.Name -CaseSensitive
		Should-Be 123 $parameter.Value
		Should-Be ([DbType]::Int64) $parameter.DbType
	}

	It "should create a collection from an array of parameters" {
		$parameters = (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
		$collection = New-SqlParameterCollection $parameters
		Should-BeCollection $collection -Count 2

		$parameter = $collection[-1]
		Should-BeString "@Key" $parameter.Name -CaseSensitive
		Should-BeString Unique $parameter.Value -CaseSensitive
		Should-Be ([DbType]::AnsiString) $parameter.DbType
	}

	Context "AddWithValue" {
		It "should add a new parameter to the collection" {
			$collection = New-SqlParameterCollection
			Should-BeCollection $collection -Count 0

			$parameter = $collection.AddWithValue("Name", "Value1")
			Should-BeCollection $collection -Count 1
			Should-BeString "@Name" $parameter.Name -CaseSensitive
			Should-BeString Value1 $parameter.Value -CaseSensitive

			$parameter = $collection.AddWithValue("Value2")
			Should-BeCollection $collection -Count 2
			Should-BeString "?2" $parameter.Name -CaseSensitive
			Should-BeString Value2 $parameter.Value -CaseSensitive
		}
	}

	Context "Contains" {
		It "should return `$true if the collection contains the specified parameter" {
			$collection = New-SqlParameterCollection (New-SqlParameter "@Key")
			Should-BeTrue $collection.Contains("Key")
			Should-BeTrue $collection.Contains("@Key")
		}

		It "should return `$false if the collection does not contain the specified parameter" {
			$collection = New-SqlParameterCollection (New-SqlParameter "@Key")
			Should-BeFalse $collection.Contains("Foo")
			Should-BeFalse $collection.Contains("@Foo")
		}
	}

	Context "ImplicitConversion" {
		It "should create a collection from the specified array of postional parameters" {
			[Belin.Sql.SqlParameterCollection] $collection = "foo", "bar"
			Should-BeCollection ("?1", "?2") $collection.PSForEach{ $_.Name }
			Should-BeCollection ("foo", "bar") $collection.PSForEach{ $_.Value }
		}

		It "should create a collection from the specified list of postional parameters" {
			[Belin.Sql.SqlParameterCollection] $collection = [List[object]]::new(("foo", "bar"))
			Should-BeCollection ("?1", "?2") $collection.PSForEach{ $_.Name }
			Should-BeCollection ("foo", "bar") $collection.PSForEach{ $_.Value }
		}

		It "should create a collection from the specified hash table of named parameters" {
			[Belin.Sql.SqlParameterCollection] $collection = @{ foo = "bar"; baz = "qux" }
			Should-BeNull (Compare-Object @("@foo", "@baz") $collection.PSForEach{ $_.Name })
			Should-BeNull (Compare-Object @("bar", "qux") $collection.PSForEach{ $_.Value })
		}
	}

	Context "Indexer" {
		It "should return the parameter with the specified name" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			$parameter = $collection["Key"]
			Should-BeString "@Key" $parameter.Name -CaseSensitive
			Should-BeString Unique $parameter.Value -CaseSensitive
			Should-Be $parameter $collection[1]
		}

		It "should return `$null, or throw an error, if the specified name does not exist" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			Should-BeNull $collection["@Foo"]

			Set-StrictMode -Version Latest
			Should-Throw -ScriptBlock { $collection["@Foo"] }
			Set-StrictMode -Off
		}
	}

	Context "IndexOf" {
		It "should return the index if the parameter is found" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			Should-Be 1 $collection.IndexOf("Key")
			Should-Be 1 $collection.IndexOf("@Key")
		}

		It "should return -1 if the parameter is not found" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			Should-Be -1 $collection.IndexOf("Foo")
			Should-Be -1 $collection.IndexOf("@Foo")
		}
	}

	Context "RemoveAt" {
		It "should remove the parameter with the specified name" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			Should-BeCollection $collection -Count 2
			$collection.RemoveAt("Key")
			Should-BeCollection $collection -Count 1
			$collection.RemoveAt("?1")
			Should-BeCollection $collection -Count 0
		}

		It "should throw an error if the specified name does not exist" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			Should-Throw -ScriptBlock { $collection.RemoveAt("Foo") }
		}
	}
}
