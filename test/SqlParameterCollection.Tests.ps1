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
			$parameter.Value | Should -BeExactly "Unique"
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
		It "TODO" {
			$collection = [SqlParameterCollection]::new((("?1", 123), ("@Key", "Unique")))
			$collection | Should -HaveCount 2
			$collection.RemoveAt("Key")
			$collection | Should -HaveCount 1
			{ $collection.RemoveAt("Foo") } | Should -Throw
			$collection.RemoveAt("?1")
			$collection | Should -BeNullOrEmpty
		}
	}
}
