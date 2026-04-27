using namespace System.ComponentModel.DataAnnotations.Schema
using namespace System.Reflection
using module ./ColumnInfo.psm1

<#
.SYNOPSIS
	Provides information about a database table.
#>
class TableInfo {

	<#
	.SYNOPSIS
		The table columns.
	#>
	[hashtable] $Columns

	<#
	.SYNOPSIS
		The single identity column, if applicable.
	#>
	[ColumnInfo] $IdentityColumn

	<#
	.SYNOPSIS
		The table name.
	#>
	[string] $Name

	<#
	.SYNOPSIS
		The table schema, if applicable.
	#>
	[string] $Schema

	<#
	.SYNOPSIS
		The entity type associated with this table.
	#>
	[Type] $Type

	<#
	.SYNOPSIS
		Creates new table information.
	.PARAMETER Type
		The type information providing the table metadata.
	#>
	TableInfo([Type] $Type) {
		$properties = $Type.GetProperties([BindingFlags]::Instance -bor [BindingFlags]::NonPublic -bor [BindingFlags]::Public).Where{
			(-not [Attribute]::IsDefined($_, [NotMappedAttribute])) -and (($property.CanRead -and $property.CanWrite) -or ([Attribute]::IsDefined($_, [ColumnAttribute])))
		}

		$columnInfos = @{}
		foreach ($property in $properties) {
			$columnInfo = [ColumnInfo] $property
			$columnInfos.$($columnInfo.Name) = $columnInfo
		}

		$identityColumns = $columnInfos.Values.Where({ $_.IsIdentity }, "First", 2)
		$table = [Attribute]::GetCustomAttribute($Type, [TableAttribute])

		$this.Columns = $columnInfos
		$this.IdentityColumn = $identityColumns.Count -eq 1 ? $identityColumns[0] : ($columnInfos.Id ?? $null)
		$this.Name = ${table}?.Name ?? $Type.Name
		$this.Schema = ${table}?.Schema
		$this.Type = $Type
	}
}
