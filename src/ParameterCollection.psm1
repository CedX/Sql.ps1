using namespace System.Collections.Generic
using module ./Parameter.psm1

<#
.SYNOPSIS
	Collects all parameters relevant to a parameterized SQL statement.
#>
class ParameterCollection: List[Parameter] {

	<#
	.SYNOPSIS
		Creates a new parameter collection.
	#>
	ParameterCollection(): base() {}

	<#
	.SYNOPSIS
		Creates a new parameter collection that has the specified initial capacity.
	.PARAMETER Capacity
		The number of parameters that the collection can initially store.
	#>
	ParameterCollection([int] $Capacity): base($Capacity) {}

	<#
	.SYNOPSIS
		Creates a new parameter collection that contains the elements copied from the specified collection.
	.PARAMETER Parameters
		The collection whose elements are copied to the parameter collection.
	#>
	ParameterCollection([Parameter[]] $Parameters): base($Parameters) {}

	<#
	.SYNOPSIS
		Creates a new parameter collection from the specified hash table of named parameters.
	.PARAMETER Parameters
		The hash table whose elements are copied to the parameter collection.
	.OUTPUTS
		The parameter collection corresponding to the specified hash table of named parameters.
	#>
	static [ParameterCollection] op_Implicit([hashtable] $Parameters) {
		$parameterCollection = [ParameterCollection]::new($Parameters.Count)
		foreach ($key in $Parameters.Keys) {
			$value = $Parameters.$key
			$parameterCollection.Add($value -is [Parameter] ? $value : [Parameter]::new($key, $value))
		}

		return $parameterCollection
	}

	<#
	.SYNOPSIS
		Creates a new parameter collection from the specified array of positional parameters.
	.PARAMETER Parameters
		The array whose elements are copied to the parameter collection.
	.OUTPUTS
		The parameter collection corresponding to the specified array of positional parameters.
	#>
	static [ParameterCollection] op_Implicit([object[]] $Parameters) {
		$parameterCollection = [ParameterCollection]::new($Parameters.Count)
		for ($index = 0; $index -lt $Parameters.Count; $index++) {
			$value = $Parameters[$index]
			$parameterCollection.Add($value -is [Parameter] ? $value : [Parameter]::new("?$($index + 1)", $value))
		}

		return $parameterCollection
	}

	<#
	.SYNOPSIS
		Gets a value indicating whether a parameter in this collection has the specified name.
	.PARAMETER Name
		The parameter name.
	.OUTPUTS
		`$true` if this collection contains a parameter with the specified name, otherwise `$false`.
	#>
	[bool] Contains([string] $Name) {
		$normalizedName = [Parameter]::NormalizeName($Name)
		return $this.Exists({ $_.Name -eq $normalizedName })
	}

	<#
	.SYNOPSIS
		Returns the index of the parameter with the specified name.
	.PARAMETER Name
		The parameter name.
	.OUTPUTS
		The index of the parameter with the specified name, or `-1` if not found.
	#>
	[int] IndexOf([string] $Name) {
		$normalizedName = [Parameter]::NormalizeName($Name)
		return $this.FindIndex({ $_.Name -eq $normalizedName })
	}

	<#
	.SYNOPSIS
		Gets the parameter with the specified name.
	.PARAMETER Name
		The parameter name.
	.OUTPUTS
		The parameter with the specified name.
	#>
	[Parameter] Item([string] $Name) {
		$normalizedName = [Parameter]::NormalizeName($Name)
		$parameter = $this.Find({ $_.Name -eq $normalizedName })
		if ($null -eq $parameter) { throw [ArgumentOutOfRangeException] $Name }
		return $parameter
	}

	<#
	.SYNOPSIS
		Removes the parameter with the specified name from this collection.
	.PARAMETER Name
		The parameter name.
	#>
	[void] RemoveAt([string] $Name) {
		$this.RemoveAt($this.IndexOf($Name))
	}
}
