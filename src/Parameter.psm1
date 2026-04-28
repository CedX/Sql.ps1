using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	The prefixes used for parameter placeholders.
#>
$Prefixes = "?", "@", ":", "$"

<#
.SYNOPSIS
	Represents a parameter of a parameterized SQL statement.
#>
class Parameter {

	<#
	.SYNOPSIS
		The database type of this parameter.
	#>
	[Nullable[DbType]] $DbType = $null

	<#
	.SYNOPSIS
		Value indicating whether this parameter is input-only, output-only, bidirectional, or a stored procedure return value parameter.
	#>
	[Nullable[ParameterDirection]] $Direction = $null

	<#
	.SYNOPSIS
		The parameter name.
	#>
	[ValidateNotNullOrWhiteSpace()]
	[string] $Name

	<#
	.SYNOPSIS
		Indicates the precision of numeric parameters.
	#>
	[Nullable[byte]] $Precision = $null

	<#
	.SYNOPSIS
		Indicates the scale of numeric parameters.
	#>
	[Nullable[byte]] $Scale = $null

	<#
	.SYNOPSIS
		The maximum size of this parameter, in bytes.
	#>
	[Nullable[int]] $Size = $null

	<#
	.SYNOPSIS
		The parameter value.
	#>
	[object] $Value

	<#
	.SYNOPSIS
		Creates a new parameter.
	#>
	Parameter() {
		$this.Name = "?"
		$this.Value = [DBNull]::Value
	}

	<#
	.SYNOPSIS
		Creates a new parameter.
	.PARAMETER Name
		The parameter name.
	#>
	Parameter([string] $Name) {
		$this.Name = [Parameter]::NormalizeName($Name)
		$this.Value = [DBNull]::Value
	}

	<#
	.SYNOPSIS
		Creates a new parameter.
	.PARAMETER Name
		The parameter name.
	.PARAMETER Value
		The parameter value.
	#>
	Parameter([string] $Name, [object] $Value) {
		$this.Name = [Parameter]::NormalizeName($Name)
		$this.Value = [Parameter]::NormalizeValue($Value)
	}

	<#
	.SYNOPSIS
		Creates a new parameter from the specified tuple.
	.PARAMETER Tuple
		The tuple providing the parameter properties.
	.OUTPUTS
		The parameter corresponding to the specified tuple.
	#>
	static [Parameter] op_Implicit([object[]] $Tuple) {
		return [Parameter]::new($Tuple.Count -gt 0 ? $Tuple[0] : "?", $Tuple.Count -gt 1 ? $Tuple[1] : [DBNull]::Value)
	}

	<#
	.SYNOPSIS
		Normalizes the specified parameter name.
	.PARAMETER Name
		The parameter name.
	.OUTPUTS
		The normalized parameter name.
	#>
	hidden static [string] NormalizeName([string] $Name) {
		return $Name ? ($Name[0] -in $Script:Prefixes ? $Name : "@$Name") : "?"
	}

	<#
	.SYNOPSIS
		Normalizes the specified parameter value.
	.PARAMETER Value
		The parameter value.
	.OUTPUTS
		The normalized parameter value.
	#>
	hidden static [object] NormalizeValue([object] $Value) {
		return $Value ?? [DBNull]::Value
	}

	<#
	.SYNOPSIS
		Converts this parameter into an `IDbDataParameter` object.
	.PARAMETER Command
		The command to associate with the created parameter.
	.OUTPUTS
		The `IDbDataParameter` object corresponding to this parameter.
	#>
	hidden [IDbDataParameter] ToDbParameter([IDbCommand] $Command) {
		$parameter = $Command.CreateParameter()
		$parameter.ParameterName = $this.Name
		$parameter.Value = $this.Value
		if ($null -ne $this.DbType) { $parameter.DbType = $this.DbType.Value }
		if ($null -ne $this.Direction) { $parameter.Direction = $this.Direction.Value }
		if ($null -ne $this.Precision) { $parameter.Precision = $this.Precision.Value }
		if ($null -ne $this.Scale) { $parameter.Scale = $this.Scale.Value }
		if ($null -ne $this.Size) { $parameter.Size = $this.Size.Value }
		return $parameter
	}
}
