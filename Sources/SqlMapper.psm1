using namespace System.Collections.Concurrent
using namespace System.Collections.Generic
using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis
using namespace System.Runtime.CompilerServices
using module ./DbColumnInfo.psm1
using module ./DbTableInfo.psm1

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
		The mapping between the entity types and their associated database tables.
	#>
	hidden static [ConcurrentDictionary[Type, DbTableInfo]] $Mapping = [ConcurrentDictionary[Type, DbTableInfo]]::new()

	<#
	.SYNOPSIS
		Creates a new data mapper.
	#>
	hidden SqlMapper() {}

	<#
	.SYNOPSIS
		Creates a new dyamic object from the specified data record.
	.PARAMETER Record
		A data record providing the properties to be set on the created object.
	.OUTPUTS
		The newly created object.
	#>
	[psobject] CreateInstance([IDataRecord] $Record) {
		return $this.CreateInstance([psobject], $Record)
	}

	<#
	.SYNOPSIS
		Creates a new object of the given type from the specified data record.
	.PARAMETER Type
		The object type.
	.PARAMETER Record
		A data record providing the properties to be set on the created object.
	.OUTPUTS
		The newly created object.
	#>
	[object] CreateInstance([Type] $Type, [IDataRecord] $Record) {
		return $this.CreateInstance($Type, [SqlMapper]::SplitOn($Record, @())[0])
	}

	<#
	.SYNOPSIS
		Creates a new object tuple of the given types from the specified data record.
	.PARAMETER Types
		The object types.
	.PARAMETER Record
		A data record providing the properties to be set on the created objects.
	.PARAMETER SplitOn
		The fields from which to split and read the next objects.
	.OUTPUTS
		The newly created object tuple.
	#>
	[SuppressMessage("PSUseDeclaredVarsMoreThanAssignments", "discard")]
	[ITuple] CreateInstance([Type[]] $Types, [IDataRecord] $Record, [string[]] $SplitOn) {
		if (($Types.Count -lt 2) -or ($Types.Count -gt 7)) { throw [ArgumentException]::new("The number of object types is invalid.", "Types") }
		if ($SplitOn -and ($SplitOn.Count -ne $Types.Count - 1)) { throw [ArgumentException]::new("The number of split fields is invalid.", "SplitOn") }
		if (-not $SplitOn) { $SplitOn = (1..($Types.Count - 1)).ForEach{ "Id" } }

		$records = [SqlMapper]::SplitOn($Record, $SplitOn)
		$objects = [List[object]]::new($records.Count)
		for ($index = 0; $index -lt $Types.Count; $index++) {
			$object = ($records.Count -le $index) -or [SqlMapper]::IsNullObject($records[$index]) ? $null : $this.CreateInstance($Types[$index], $records[$index])
			$objects.Add($object)
		}

		return $discard = switch ($objects.Count) {
			2 { [ValueTuple]::Create[object, object]($objects[0], $objects[1]); break }
			3 { [ValueTuple]::Create[object, object, object]($objects[0], $objects[1], $objects[2]); break }
			4 { [ValueTuple]::Create[object, object, object, object]($objects[0], $objects[1], $objects[2], $objects[3]); break }
			5 { [ValueTuple]::Create[object, object, object, object, object]($objects[0], $objects[1], $objects[2], $objects[3], $objects[4]); break }
			6 { [ValueTuple]::Create[object, object, object, object, object, object]($objects[0], $objects[1], $objects[2], $objects[3], $objects[4], $objects[5]); break }
			default { [ValueTuple]::Create[object, object, object, object, object, object, object]($objects[0], $objects[1], $objects[2], $objects[3], $objects[4], $objects[5], $objects[6]) }
		}
	}

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

	<#
	.SYNOPSIS
		Gets the table information associated with the specified type.
	.PARAMETER Type
		The type to inspect.
	.OUTPUTS
		The table information associated with the specified type.
	#>
	[DbTableInfo] GetTable([Type] $Type) {
		return [SqlMapper]::Mapping.GetOrAdd($Type, { param ([Type] $entityType) [DbTableInfo]::new($entityType) })
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
		return [SqlMapper]::ChangeType($Value, $Column.PropertyType, $Column.IsNullable)
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
	[SuppressMessage("PSUseDeclaredVarsMoreThanAssignments", "discard")]
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
		Returns a value indicating whether all values of the specified hash table are `$null`.
	.PARAMETER HashTable
		The hash table to inspect.
	.OUTPUTS
		`$true` if all values of the specified hash table are `$null`, otherwise `$false`.
	#>
	hidden static [bool] IsNullObject([hashtable] $HashTable) {
		return $HashTable.Values.Where{ $null -eq $_ }.Count -eq $HashTable.Count
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
			foreach ($entry in $Record) { if (-not $properties.ContainsKey($entry.Key)) { $properties[$entry.Key] = $entry.Value } }
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

			if (-not $properties.ContainsKey($entry.Key)) { $properties[$entry.Key] = $entry.Value }
		}

		$records.Add($properties)
		return $records.ToArray()
	}
}
