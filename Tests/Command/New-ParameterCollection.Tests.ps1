using namespace Belin.Sql
using namespace System.Data
using namespace System.Collections.Generic
using module ../../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `New-ParameterCollection` cmdlet.
#>
Describe "New-ParameterCollection" {
	It "should create an empty collection by default" {
		$collection = New-SqlParameterCollection
		$collection | Should -BeNullOrEmpty
	}

	It "should create a collection from a single parameter" {
		$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123 -DbType Int64)
		Should-Be 1 $collection.Count

		$parameter = $collection[0]
		$parameter.Name | Should -BeExactly "?1"
		$parameter.Value | Should -Be 123
		Should-Be ([DbType]::Int64) $parameter.DbType
	}

	It "should create a collection from an array of parameters" {
		$parameters = (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
		$collection = New-SqlParameterCollection $parameters
		Should-Be 2 $collection.Count

		$parameter = $collection[$collection.Count - 1]
		$parameter.Name | Should -BeExactly "@Key"
		$parameter.Value | Should -BeExactly Unique
		Should-Be ([DbType]::AnsiString) $parameter.DbType
	}

	Context "AddWithValue" {
		It "should add a new parameter to the collection" {
			$collection = New-SqlParameterCollection
			$collection | Should -BeNullOrEmpty

			$parameter = $collection.AddWithValue("Name", "Value1")
			Should-Be 1 $collection.Count
			$parameter.Name | Should -BeExactly "@Name"
			$parameter.Value | Should -BeExactly Value1

			$parameter = $collection.AddWithValue("Value2")
			Should-Be 2 $collection.Count
			$parameter.Name | Should -BeExactly "?2"
			$parameter.Value | Should -BeExactly Value2
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
			[SqlParameterCollection] $collection = "foo", "bar"
			$collection.PSForEach{ $_.Name } | Should -Be "?1", "?2"
			$collection.PSForEach{ $_.Value } | Should -Be "foo", "bar"
		}

		It "should create a collection from the specified list of postional parameters" {
			[SqlParameterCollection] $collection = [List[object]]::new(("foo", "bar"))
			$collection.PSForEach{ $_.Name } | Should -Be "?1", "?2"
			$collection.PSForEach{ $_.Value } | Should -Be "foo", "bar"
		}

		It "should create a collection from the specified hash table of named parameters" {
			[SqlParameterCollection] $collection = @{ foo = "bar"; baz = "qux" }
			Compare-Object @("@foo", "@baz") $collection.PSForEach{ $_.Name } | Should -BeNullOrEmpty
			Compare-Object @("bar", "qux") $collection.PSForEach{ $_.Value } | Should -BeNullOrEmpty
		}
	}

	Context "Indexer" {
		It "should return the parameter with the specified name" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			$parameter = $collection["Key"]
			$parameter.Name | Should -BeExactly "@Key"
			$parameter.Value | Should -BeExactly Unique
			$collection[1] | Should -Be $parameter
		}

		It "should return `$null, or throw an error, if the specified name does not exist" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			$collection["@Foo"] | Should -BeNullOrEmpty

			Set-StrictMode -Version Latest
			Should-Throw -ScriptBlock { $collection["@Foo"] }
			Set-StrictMode -Off
		}
	}

	Context "IndexOf" {
		It "should return the index if the parameter is found" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			$collection.IndexOf("Key") | Should -Be 1
			$collection.IndexOf("@Key") | Should -Be 1
		}

		It "should return -1 if the parameter is not found" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			$collection.IndexOf("Foo") | Should -Be -1
			$collection.IndexOf("@Foo") | Should -Be -1
		}
	}

	Context "RemoveAt" {
		It "should remove the parameter with the specified name" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			Should-Be 2 $collection.Count
			$collection.RemoveAt("Key")
			Should-Be 1 $collection.Count
			$collection.RemoveAt("?1")
			$collection | Should -BeNullOrEmpty
		}

		It "should throw an error if the specified name does not exist" {
			$collection = New-SqlParameterCollection (New-SqlParameter "?1" 123), (New-SqlParameter "@Key" Unique -DbType AnsiString)
			Should-Throw -ScriptBlock { $collection.RemoveAt("Foo") }
		}
	}
}
