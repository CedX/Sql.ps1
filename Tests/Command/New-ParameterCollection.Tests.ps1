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
			[SqlParameterCollection] $collection = "foo", "bar"
			Should-BeCollection ("?1", "?2") $collection.PSForEach{ $_.Name }
			Should-BeCollection ("foo", "bar") $collection.PSForEach{ $_.Value }
		}

		It "should create a collection from the specified list of postional parameters" {
			[SqlParameterCollection] $collection = [List[object]]::new(("foo", "bar"))
			Should-BeCollection ("?1", "?2") $collection.PSForEach{ $_.Name }
			Should-BeCollection ("foo", "bar") $collection.PSForEach{ $_.Value }
		}

		It "should create a collection from the specified hash table of named parameters" {
			[SqlParameterCollection] $collection = @{ foo = "bar"; baz = "qux" }
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
