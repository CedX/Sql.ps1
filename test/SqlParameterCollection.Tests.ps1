using namespace System.Data
using module ../src/SqlParameter.psm1
using module ../src/ParameterCollection.psm1

<#
.SYNOPSIS
	Tests the features of the `ParameterCollection` class.
#>
Describe "ParameterCollection" {
	Context "Constructor" {
		$collection = [ParameterCollection]::new()
		$collection | Should -BeNullOrEmpty

		$collection = [ParameterCollection]::new(@([SqlParameter]@{ Name = "?1"; Value = 123; DbType = [DbType]::Int64 }))
		$collection | Should -HaveCount 1

		$parameter = $collection[0]
		$parameter.Name | Should -BeExactly "?1"
		$parameter.Value | Should -Be 123
		$parameter.DbType | Should -Be ([DbType]::Int64)

		$collection = [ParameterCollection]::new(@(
			[SqlParameter]::new("?1", 123)
			[SqlParameter]@{ Name = "@Key"; Value = "Unique"; DbType = [DbType]::AnsiString }
		))

		$collection | Should -HaveCount 2

		# $parameter = $collection[$collection.Count - 1]
		# $parameter.Name | Should -BeExactly "@Key"
		# $parameter.Value | Should -BeExactly "Unique"
		# $parameter.DbType | Should -Be ([DbType]::AnsiString)
	}

	# Context "Contains" {
	# 	$collection = new ParameterCollection("@Key")
	# 	IsTrue($collection.Contains("Key"))
	# 	IsTrue($collection.Contains("@Key"))
	# 	IsFalse($collection.Contains("Foo"))
	# 	IsFalse($collection.Contains("@Foo"))
	# }

	# Context "IndexOf" {
	# 	$collection = new ParameterCollection(("?1", 123), ("@Key", "Unique"))
	# 	AreEqual(1, $collection.IndexOf("Key"))
	# 	AreEqual(1, $collection.IndexOf("@Key"))
	# 	AreEqual(-1, $collection.IndexOf("Foo"))
	# 	AreEqual(-1, $collection.IndexOf("@Foo"))
	# }

	# Context "RemoveAt" {
	# 	$collection = new ParameterCollection(("?1", 123), ("@Key", "Unique"))
	# 	HasCount(2, $collection)

	# 	$collection.RemoveAt("Key")
	# 	HasCount(1, $collection)
	# 	Throws<ArgumentOutOfRangeException>(() => $collection.RemoveAt("Foo"))
	# 	$collection.RemoveAt("?1")
	# 	IsEmpty($collection)
	# }
}
