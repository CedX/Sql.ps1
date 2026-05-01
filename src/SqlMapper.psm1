using namespace System.Collections.Concurrent
using namespace System.Collections.Generic
using namespace System.Data
using namespace System.Runtime.CompilerServices
using module ./Reflection/DbColumnInfo.psm1
using module ./Reflection/DbTableInfo.psm1

<#
.SYNOPSIS
	The mapping between the entity types and their associated database tables.
#>
$Mapping = [ConcurrentDictionary[Type, DbTableInfo]]::new()

<#
.SYNOPSIS
	Maps data records to entity objects.
#>
class SqlMapper {

	<#
	.SYNOPSIS
		The singleton instance of the data mapper.
	#>
	static [SqlMapper] $Instance = [SqlMapper]::new()

	<#
	.SYNOPSIS
		Creates a new data mapper.
	#>
	hidden SqlMapper() {}

	# <#
	# .SYNOPSIS
	# 	Creates a new dyamic object from the specified data record.
	# .PARAMETER Record
	# 	A data record providing the properties to be set on the created object.
	# .OUTPUTS
	# 	The newly created object.
	# #>
	# [psobject] CreateInstance([IDataRecord] $Record) {
	# 	return $this.CreateInstance([psobject], $Record)
	# }

	# <#
	# .SYNOPSIS
	# 	Creates a new object of the given type from the specified data record.
	# #>
	# /// <typeparam name="T">The object type.</typeparam>
	# /// <param name="record">A data record providing the properties to be set on the created object.</param>
	# /// <returns>The newly created object.</returns>
	# T CreateInstance<T>(IDataRecord record) => CreateInstance<T>(SplitOn(record).First())

	# <#
	# .SYNOPSIS
	# 	Creates a new object pair of the given types from the specified data record.
	# #>
	# /// <typeparam name="TItem1">The type of the first object.</typeparam>
	# /// <typeparam name="TItem2">The type of the second object.</typeparam>
	# /// <param name="record">A data record providing the properties to be set on the created objects.</param>
	# /// <param name="splitOn">The field from which to split and read the next object.</param>
	# /// <returns>The newly created object pair.</returns>
	# (TItem1, TItem2) CreateInstance<TItem1, TItem2>(IDataRecord record, string splitOn = "Id") where TItem1: new() where TItem2: new() {
	# 	$records = SplitOn(record, splitOn)
	# 	return (
	# 		records[0].Values.All(value => value is null) ? default! : CreateInstance<TItem1>(records[0]),
	# 		records.Count <= 1 || records[1].Values.All(value => value is null) ? default! : CreateInstance<TItem2>(records[1])
	# 	)
	# }

	# <#
	# .SYNOPSIS
	# 	Creates a new object tuple of the given types from the specified data record.
	# #>
	# /// <typeparam name="TItem1">The type of the first object.</typeparam>
	# /// <typeparam name="TItem2">The type of the second object.</typeparam>
	# /// <typeparam name="TItem3">The type of the third object.</typeparam>
	# /// <param name="record">A data record providing the properties to be set on the created objects.</param>
	# /// <param name="splitOn">The fields from which to split and read the next objects.</param>
	# /// <returns>The newly created object tuple.</returns>
	# (TItem1, TItem2, TItem3) CreateInstance<TItem1, TItem2, TItem3>(IDataRecord record, (string, string)? splitOn = null) where TItem1: new() where TItem2: new() where TItem3: new() {
	# 	$(firstField, secondField) = splitOn ?? ("Id", "Id")
	# 	$records = SplitOn(record, firstField, secondField)
	# 	return (
	# 		records[0].Values.All(value => value is null) ? default! : CreateInstance<TItem1>(records[0]),
	# 		records.Count <= 1 || records[1].Values.All(value => value is null) ? default! : CreateInstance<TItem2>(records[1]),
	# 		records.Count <= 2 || records[2].Values.All(value => value is null) ? default! : CreateInstance<TItem3>(records[2])
	# 	)
	# }

	# <#
	# .SYNOPSIS
	# 	Creates a new object tuple of the given types from the specified data record.
	# #>
	# /// <typeparam name="TItem1">The type of the first object.</typeparam>
	# /// <typeparam name="TItem2">The type of the second object.</typeparam>
	# /// <typeparam name="TItem3">The type of the third object.</typeparam>
	# /// <typeparam name="TItem4">The type of the fourth object.</typeparam>
	# /// <param name="record">A data record providing the properties to be set on the created objects.</param>
	# /// <param name="splitOn">The fields from which to split and read the next objects.</param>
	# /// <returns>The newly created object tuple.</returns>
	# (TItem1, TItem2, TItem3, TItem4) CreateInstance<TItem1, TItem2, TItem3, TItem4>(IDataRecord record, (string, string, string)? splitOn = null) where TItem1: new() where TItem2: new() where TItem3: new() where TItem4: new() {
	# 	$(firstField, secondField, thirdField) = splitOn ?? ("Id", "Id", "Id")
	# 	$records = SplitOn(record, firstField, secondField, thirdField)
	# 	return (
	# 		records[0].Values.All(value => value is null) ? default! : CreateInstance<TItem1>(records[0]),
	# 		records.Count <= 1 || records[1].Values.All(value => value is null) ? default! : CreateInstance<TItem2>(records[1]),
	# 		records.Count <= 2 || records[2].Values.All(value => value is null) ? default! : CreateInstance<TItem3>(records[2]),
	# 		records.Count <= 3 || records[3].Values.All(value => value is null) ? default! : CreateInstance<TItem4>(records[3])
	# 	)
	# }

	<#
	.SYNOPSIS
		Creates a new dynamic object from the specified hash table.
	.PARAMETER Properties
		A hash table providing the properties to be set on the created object.
	.OUTPUTS
		The newly created object.
	#>
	[psobject] CreateInstance([hashtable] $Properties) {
		return $this.CreateInstance([psobject], $Properties)
	}

	<#
	.SYNOPSIS
		Creates a new object of a given type from the specified hash table.
	.PARAMETER Type
		The object type.
	.PARAMETER Properties
		A hash table providing the properties to be set on the created object.
	.OUTPUTS
		The newly created object.
	#>
	[object] CreateInstance([Type] $Type, [hashtable] $Properties) {
		if ($Type -eq [psobject]) { return [pscustomobject] $Properties }

		$object = [Activator]::CreateInstance($Type)
		$table = $this.GetTable($Type)
		foreach ($name in $Properties.Keys.Where{ $table.Columns.ContainsKey($_) }) {
			$column = $table.Columns[$name]
			if ($column.CanWrite) { $column.SetValue($object, [SqlMapper]::ChangeType($Properties[$name], $column)) }
		}

		return $object
	}

	# <#
	# .SYNOPSIS
	# 	Creates new dynamic objects from the specified data reader.
	# #>
	# /// <param name="reader">A data reader providing the properties to be set on the created objects.</param>
	# /// <returns>An enumerable of newly created objects.</returns>
	# IEnumerable[psobject] CreateInstances(IDataReader reader) => CreateInstances[psobject](reader)

	<#
	.SYNOPSIS
		Creates new objects of the given type from the specified data reader.
	.PARAMETER Type
		The object type.
	.PARAMETER Reader
		A data reader providing the properties to be set on the created objects.
	.OUTPUTS
		An enumerable of newly created objects.
	#>
	[object[]] CreateInstances([Type] $Type, [IDataReader] $Reader) {
		$objects = [List[object]]::new()
		while ($Reader.Read()) { $objects.Add($this.CreateInstance($Type, $Reader)) }
		$Reader.Close()
		return $objects
	}

	# TODO !!!!
	# IEnumerable<T> CreateInstances<T>(IDataReader reader) {
	# 	while (reader.Read()) yield return CreateInstance<T>(reader)
	# 	reader.Close()
	# }

	# <#
	# .SYNOPSIS
	# 	Creates new object pairs of the given types from the specified data reader.
	# #>
	# /// <typeparam name="TItem1">The type of the first object.</typeparam>
	# /// <typeparam name="TItem2">The type of the second object.</typeparam>
	# /// <param name="reader">A data reader providing the properties to be set on the created objects.</param>
	# /// <param name="splitOn">The field from which to split and read the next object.</param>
	# /// <returns>An enumerable of newly created object pairs.</returns>
	# IEnumerable<(TItem1, TItem2)> CreateInstances<TItem1, TItem2>(IDataReader reader, string splitOn = "Id") where TItem1: new() where TItem2: new() {
	# 	while (reader.Read()) yield return CreateInstance<TItem1, TItem2>(reader, splitOn)
	# 	reader.Close()
	# }

	# <#
	# .SYNOPSIS
	# 	Creates new object tuples of the given types from the specified data reader.
	# #>
	# /// <typeparam name="TItem1">The type of the first object.</typeparam>
	# /// <typeparam name="TItem2">The type of the second object.</typeparam>
	# /// <typeparam name="TItem3">The type of the third object.</typeparam>
	# /// <param name="reader">A data reader providing the properties to be set on the created objects.</param>
	# /// <param name="splitOn">The fields from which to split and read the next objects.</param>
	# /// <returns>An enumerable of newly created object tuples.</returns>
	# IEnumerable<(TItem1, TItem2, TItem3)> CreateInstances<TItem1, TItem2, TItem3>(IDataReader reader, (string, string)? splitOn = null) where TItem1: new() where TItem2: new() where TItem3: new() {
	# 	while (reader.Read()) yield return CreateInstance<TItem1, TItem2, TItem3>(reader, splitOn)
	# 	reader.Close()
	# }

	# <#
	# .SYNOPSIS
	# 	Creates new object tuples of the given types from the specified data reader.
	# #>
	# /// <typeparam name="TItem1">The type of the first object.</typeparam>
	# /// <typeparam name="TItem2">The type of the second object.</typeparam>
	# /// <typeparam name="TItem3">The type of the third object.</typeparam>
	# /// <typeparam name="TItem4">The type of the fourth object.</typeparam>
	# /// <param name="reader">A data reader providing the properties to be set on the created objects.</param>
	# /// <param name="splitOn">The fields from which to split and read the next objects.</param>
	# /// <returns>An enumerable of newly created object tuples.</returns>
	# IEnumerable<(TItem1, TItem2, TItem3, TItem4)> CreateInstances<TItem1, TItem2, TItem3, TItem4>(IDataReader reader, (string, string, string)? splitOn = null) where TItem1: new() where TItem2: new() where TItem3: new() where TItem4: new() {
	# 	while (reader.Read()) yield return CreateInstance<TItem1, TItem2, TItem3, TItem4>(reader, splitOn)
	# 	reader.Close()
	# }

	<#
	.SYNOPSIS
		Gets the table information associated with the specified type.
	.PARAMETER Type
		The type to inspect.
	.OUTPUTS
		The table information associated with the specified type.
	#>
	[DbTableInfo] GetTable([Type] $Type) {
		return $Script:Mapping.GetOrAdd($Type, { param ($entityType) [DbTableInfo]::new($entityType) })
	}

	<#
	.SYNOPSIS
		Converts the specified object into an equivalent value of the specified type.
	.PARAMETER Value
		The object to convert.
	.PARAMETER Column
		The column providing the type of object to return.
	.OUTPUTS
		The value of the given type corresponding to the specified object.
	#>
	hidden static [object] ChangeType([object] $Value, [DbColumnInfo] $Column) {
		return [SqlMapper]::ChangeType($Value, $Column.Type, $Column.IsNullable)
	}

	<#
	.SYNOPSIS
		Converts the specified object into an equivalent value of the specified type.
	.PARAMETER Value
		The object to convert.
	.PARAMETER ConversionType
		The type of object to return.
	.OUTPUTS
		The value of the given type corresponding to the specified object.
	#>
	hidden static [object] ChangeType([object] $Value, [Type] $ConversionType) {
		return [SqlMapper]::ChangeType($Value, $ConversionType, $false)
	}

	<#
	.SYNOPSIS
		Converts the specified object into an equivalent value of the specified type.
	.PARAMETER Value
		The object to convert.
	.PARAMETER ConversionType
		The type of object to return.
	.PARAMETER IsNullable
		Value indicating whether the specified conversion type is nullable.
	.OUTPUTS
		The value of the given type corresponding to the specified object.
	#>
	hidden static [object] ChangeType([object] $Value, [Type] $ConversionType, [bool] $IsNullable) {
		$nullableType = [Nullable]::GetUnderlyingType($ConversionType)
		$targetType = $nullableType ?? $ConversionType

		if ($null -ne $Value) {
			$culture = [cultureinfo]::InvariantCulture
			return $discard = switch ($true) {
				{ $targetType.IsEnum -and ($Value -is [string]) } { [Enum]::Parse($targetType, $Value, $true); break }
				{ $targetType.IsEnum } { [Enum]::ToObject($targetType, [Convert]::ChangeType($Value, [Enum]::GetUnderlyingType($targetType), $culture)); break }
				default { $targetType.IsInstanceOfType($Value) ? $Value : [Convert]::ChangeType($Value, $targetType, $culture) }
			}
		}

		return $discard = switch ($true) {
			{ $null -ne $nullableType } { $null; break }
			{ $targetType.IsValueType } { [RuntimeHelpers]::GetUninitializedObject($targetType); break }
			{ $targetType -eq [string] } { $IsNullable ? $null : ""; break }
			default { $IsNullable ? $null : [Activator]::CreateInstance($targetType) }
		}
	}

	<#
	.SYNOPSIS
		Splits the specified data record according to the specified fields.
	.PARAMETER Record
		The data record to split.
	.PARAMETER Fields
		The fields from which to split and read the next objects.
	.OUTPUTS
		An array of hash tables representing the objects extracted from the data record.
	#>
	hidden static [hashtable[]] SplitOn([IDataRecord] $Record, [string[]] $Fields) {
		$properties = [List[KeyValuePair[string, object]]]::new($Record.FieldCount)
		for ($index = 0; $index -lt $Record.FieldCount; $index++) {
			$value = $Record[$index]
			$properties.Add([KeyValuePair[string, object]]::new($Record.GetName($index), $value -is [DBNull] ? $null : $value))
		}

		return [SqlMapper]::SplitOn($properties, $Fields)
	}

	<#
	.SYNOPSIS
		Splits the specified data record according to the specified fields.
	.PARAMETER Record
		The data record to split.
	.PARAMETER Fields
		The fields from which to split and read the next objects.
	.OUTPUTS
		An array of hash tables representing the objects extracted from the data record.
	#>
	hidden static [hashtable[]] SplitOn([KeyValuePair[string, object][]] $Record, [string[]] $Fields) {
		$properties = @{}
		if (-not $Fields) {
			foreach ($entry in $Record) { $properties[$entry.Key] = $entry.Value }
			return @($properties)
		}

		$field = ""
		$fieldQueue = [Queue[string]]::new($Fields)
		$records = [List[hashtable]]::new($Fields.Count + 1)
		$splitOn = $fieldQueue.Dequeue()

		for ($index = 0; $index -lt $Record.Count; $index++) {
			$entry = $Record[$index]
			if (($index -gt 0) -and ($entry.Key -eq $splitOn)) {
				$records.Add($properties)
				$properties = @{}
				if ($fieldQueue.TryDequeue([ref] $field)) { $splitOn = $field }
			}

			$properties[$entry.Key] = $entry.Value
		}

		$records.Add($properties)
		return $records
	}
}
