using namespace Belin.Sql
using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Creates a new parameter.
.INPUTS
	The parameter name.
.OUTPUTS
	The newly created parameter.
#>
function New-Parameter {
	[CmdletBinding()]
	[OutputType([Belin.Sql.SqlParameter])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The parameter name.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[AllowEmptyString()]
		[string] $Name,

		# The parameter value.
		[Parameter(Position = 2)]
		[object] $Value,

		# Value indicating whether this parameter is input-only, output-only, bidirectional, or a stored procedure return value parameter.
		[Nullable[ParameterDirection]] $Direction,

		# The database type of this parameter.
		[Nullable[DbType]] $DbType,

		# The maximum size of this parameter, in bytes.
		[Nullable[int]] $Size,

		# Indicates the precision of numeric parameters.
		[Nullable[byte]] $Precision,

		# Indicates the scale of numeric parameters.
		[Nullable[byte]] $Scale
	)

	process {
		$parameter = [SqlParameter]::new($Name, $Value)
		$parameter.DbType = $DbType
		$parameter.Direction = $Direction
		$parameter.Precision = $Precision
		$parameter.Scale = $Scale
		$parameter.Size = $Size
		$parameter
	}
}

<#
.SYNOPSIS
	Creates a new parameter collection.
.INPUTS
	The collection whose elements are copied to the parameter collection.
.OUTPUTS
	The newly created parameter collection.
#>
function New-ParameterCollection {
	[CmdletBinding()]
	[OutputType([Belin.Sql.SqlParameterCollection])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The collection whose elements are copied to the parameter collection.
		[Parameter(Position = 1, ValueFromPipeline)]
		[ValidateNotNull()]
		[SqlParameter[]] $Parameters = @()
	)

	process {
		Write-Output ([SqlParameterCollection]::new($Parameters)) -NoEnumerate
	}
}
