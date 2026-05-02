using namespace System.ComponentModel.DataAnnotations.Schema
using namespace System.Reflection
using module ./DbColumnInfo.psm1

<#
.SYNOPSIS
	Provides information about a database table.
#>
class DbTableInfo {

	<#
	.SYNOPSIS
		The table columns.
	#>
	[hashtable] $Columns

	<#
	.SYNOPSIS
		The single identity column, if applicable.
	#>
	[DbColumnInfo] $IdentityColumn

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
	DbTableInfo([Type] $Type) {
		$properties = $Type.GetProperties([BindingFlags]::Instance -bor [BindingFlags]::NonPublic -bor [BindingFlags]::Public).Where{
			(-not [Attribute]::IsDefined($_, [NotMappedAttribute])) -and (($property.CanRead -and $property.CanWrite) -or ([Attribute]::IsDefined($_, [ColumnAttribute])))
		}

		$this.Columns = @{}
		foreach ($property in $properties) {
			$columnInfo = [DbColumnInfo]::new($property)
			$this.Columns[$columnInfo.Name] = $columnInfo
		}

		$identityColumns = $this.Columns.Values.Where({ $_.IsIdentity }, "First", 2)
		$table = [Attribute]::GetCustomAttribute($Type, [TableAttribute])

		$this.IdentityColumn = $identityColumns.Count -eq 1 ? $identityColumns[0] : ($this.Columns.Id ?? $null)
		$this.Name = ${table}?.Name ?? $Type.Name
		$this.Schema = ${table}?.Schema
		$this.Type = $Type
	}
}
