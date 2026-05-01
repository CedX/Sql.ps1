using namespace System.Data
using module ../src/SqlParameter.psm1
using module ../src/SqlParameterCollection.psm1

<#
.SYNOPSIS
	Tests the features of the `SqlParameterCollection` class.
#>
Describe "SqlParameterCollection" {
	Context "Constructor" {
		It "should create an empty collection by default" {
			$collection = [SqlParameterCollection]::new()
			$collection | Should -BeNullOrEmpty
		}

		It "should create a collection from a single parameter" {
			$collection = [SqlParameterCollection]::new([SqlParameter]@{ Name = "?1"; Value = 123; DbType = [DbType]::Int64 })
			$collection | Should -HaveCount 1

			$parameter = $collection[0]
			$parameter.Name | Should -BeExactly "?1"
			$parameter.Value | Should -Be 123
			$parameter.DbType | Should -Be ([DbType]::Int64)
		}

		It "should create a collection from an array of parameters" {
			$parameters = @(
				[SqlParameter]::new("?1", 123)
				[SqlParameter]@{ Name = "@Key"; Value = "Unique"; DbType = [DbType]::AnsiString }
			)

			$collection = [SqlParameterCollection]::new($parameters)
			$collection | Should -HaveCount 2

			$parameter = $collection[$collection.Count - 1]
			$parameter.Name | Should -BeExactly "@Key"
			$parameter.Value | Should -BeExactly Unique
			$parameter.DbType | Should -Be ([DbType]::AnsiString)
		}
	}

	Context "Contains" {
		It "should return `$true if the collection contains the specified parameter" {
			$collection = [SqlParameterCollection]::new([SqlParameter]::new("@Key", $null))
			$collection.Contains("Key") | Should -BeTrue
			$collection.Contains("@Key") | Should -BeTrue
		}

		It "should return `$false if the collection does not contain the specified parameter" {
			$collection = [SqlParameterCollection]::new([SqlParameter]::new("@Key", $null))
			$collection.Contains("Foo") | Should -BeFalse
			$collection.Contains("@Foo") | Should -BeFalse
		}
	}

	Context "ImplicitConversion" {
		It "should create a collection from the specified array of postional parameters" {
			[SqlParameterCollection] $collection = "foo", "bar"
			$collection | Should -HaveCount 2
			$collection[0].Name | Should -BeExactly "?1"
			$collection[0].Value | Should -BeExactly foo
			$collection[1].Name | Should -BeExactly "?2"
			$collection[1].Value | Should -BeExactly bar
		}

		It "should create a collection from the specified hash table of named parameters" {
			[SqlParameterCollection] $collection = @{ foo = "bar"; baz = "qux" }
			$collection | Should -HaveCount 2
			Compare-Object @("@foo", "@baz") $collection.PSForEach{ $_.Name } | Should -BeNullOrEmpty
			Compare-Object @("bar", "qux") $collection.PSForEach{ $_.Value } | Should -BeNullOrEmpty
		}
	}

	Context "Indexer" {
		It "should return the parameter with the specified name" {
			$collection = [SqlParameterCollection]::new((("?1", 123), ("@Key", "Unique")))
			$parameter = $collection["Key"]
			$parameter.Name | Should -BeExactly "@Key"
			$parameter.Value | Should -BeExactly Unique
			$collection[1] | Should -Be $parameter
		}

		It "should return `$null, or throw an error, if the specified name does not exist" {
			$collection = [SqlParameterCollection]::new((("?1", 123), ("@Key", "Unique")))
			$collection["@Foo"] | Should -BeNullOrEmpty

			Set-StrictMode -Version Latest
			{ $collection["@Foo"] } | Should -Throw
			Set-StrictMode -Off
		}
	}

	Context "IndexOf" {
		It "should return the index if the parameter is found" {
			$collection = [SqlParameterCollection]::new((("?1", 123), ("@Key", "Unique")))
			$collection.IndexOf("Key") | Should -Be 1
			$collection.IndexOf("@Key") | Should -Be 1
		}

		It "should return -1 if the parameter is not found" {
			$collection = [SqlParameterCollection]::new((("?1", 123), ("@Key", "Unique")))
			$collection.IndexOf("Foo") | Should -Be -1
			$collection.IndexOf("@Foo") | Should -Be -1
		}
	}

	Context "RemoveAt" {
		It "should remove the parameter with the specified name" {
			$collection = [SqlParameterCollection]::new((("?1", 123), ("@Key", "Unique")))
			$collection | Should -HaveCount 2
			$collection.RemoveAt("Key")
			$collection | Should -HaveCount 1
			$collection.RemoveAt("?1")
			$collection | Should -BeNullOrEmpty
		}

		It "should throw an error if the specified name does not exist" {
			$collection = [SqlParameterCollection]::new((("?1", 123), ("@Key", "Unique")))
			{ $collection.RemoveAt("Foo") } | Should -Throw
		}
	}
}
