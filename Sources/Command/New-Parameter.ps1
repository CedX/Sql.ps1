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
		[Parameter(Mandatory, Position = 0, ValueFromPipeline)]
		[AllowEmptyString()]
		[string] $Name,

		# The parameter value.
		[Parameter(Position = 1)]
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
