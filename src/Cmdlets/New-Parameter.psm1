using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Creates a new command parameter.
.OUTPUTS
	The newly created parameter.
#>
function New-Parameter {
	[CmdletBinding()]
	[OutputType([Parameter])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The parameter name.
		[Parameter(Mandatory, Position = 0)]
		[AllowEmptyString()]
		[string] $Name,

		# The parameter value.
		[Parameter(Position = 1)]
		[AllowNull()]
		[object] $Value,

		# Value indicating whether this parameter is input-only, output-only, bidirectional, or a stored procedure return value parameter.
		[ParameterDirection] $Direction,

		# The database type of this parameter.
		[DbType] $DbType,

		# The maximum size of this parameter, in bytes.
		[int] $Size,

		# Indicates the precision of numeric parameters.
		[byte] $Precision,

		# Indicates the scale of numeric parameters.
		[byte] $Scale
	)

	$parameter = [Parameter]::new($Name, $Value)
	$parameter.DbType = $DbType
	$parameter.Direction = $Direction
	$parameter.Precision = $Precision
	$parameter.Scale = $Scale
	$parameter.Size = $Size
	$parameter
}
