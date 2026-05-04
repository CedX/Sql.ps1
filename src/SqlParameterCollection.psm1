using namespace System.Collections.Generic
using module ./SqlParameter.psm1

<#
.SYNOPSIS
	Collects all parameters relevant to a parameterized SQL statement.
#>
class SqlParameterCollection: List[SqlParameter] {

	<#
	.SYNOPSIS
		Creates a new parameter collection.
	#>
	SqlParameterCollection(): base() {}

	<#
	.SYNOPSIS
		Creates a new parameter collection that contains the elements copied from the specified collection.
	.PARAMETER Parameters
		The collection whose elements are copied to the parameter collection.
	#>
	SqlParameterCollection([SqlParameter[]] $Parameters): base($Parameters) {}

	<#
	.SYNOPSIS
		Gets the parameter with the specified name.
	.PARAMETER Name
		The parameter name.
	.OUTPUTS
		The parameter with the specified name, or `$null` if not found.
	#>
	[SqlParameter] get_Item([string] $Name) {
		$normalizedName = [SqlParameter]::NormalizeName($Name)
		$parameterFound = $this.Find({ param ($parameter) $parameter.Name -eq $normalizedName })
		if (-not $parameterFound) { throw [ArgumentOutOfRangeException] $Name }
		return $parameterFound
	}

	<#
	.SYNOPSIS
		Creates a new parameter collection from the specified hash table of named parameters.
	.PARAMETER Parameters
		The hash table whose elements are copied to the parameter collection.
	.OUTPUTS
		The parameter collection corresponding to the specified hash table of named parameters.
	#>
	static [SqlParameterCollection] op_Implicit([hashtable] $Parameters) {
		$parameterCollection = [SqlParameterCollection]::new($Parameters.Count)
		foreach ($key in $Parameters.Keys) {
			$value = $Parameters.$key
			$parameterCollection.Add($value -is [SqlParameter] ? $value : [SqlParameter]::new($key, $value))
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
	static [SqlParameterCollection] op_Implicit([object[]] $Parameters) {
		$parameterCollection = [SqlParameterCollection]::new($Parameters.Count)
		for ($index = 0; $index -lt $Parameters.Count; $index++) {
			$value = $Parameters[$index]
			$parameterCollection.Add($value -is [SqlParameter] ? $value : [SqlParameter]::new("?$($index + 1)", $value))
		}

		return $parameterCollection
	}

	<#
	.SYNOPSIS
		Adds a new positional parameter to the end of this collection.
	.PARAMETER Value
		The parameter value.
	.OUTPUTS
		The newly added parameter.
	#>
	[SqlParameter] AddWithValue([object] $Value) {
		return $this.AddWithValue("?$($this.Count + 1)", $Value)
	}

	<#
	.SYNOPSIS
		Adds a new named parameter to the end of this collection.
	.PARAMETER Name
		The parameter name.
	.PARAMETER Value
		The parameter value.
	.OUTPUTS
		The newly added parameter.
	#>
	[SqlParameter] AddWithValue([string] $Name, [object] $Value) {
		$parameter = [SqlParameter]::new($Name, $Value)
		$this.Add($parameter)
		return $parameter
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
		$normalizedName = [SqlParameter]::NormalizeName($Name)
		return $this.Exists({ param ($parameter) $parameter.Name -eq $normalizedName })
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
		$normalizedName = [SqlParameter]::NormalizeName($Name)
		return $this.FindIndex({ param ($parameter) $parameter.Name -eq $normalizedName })
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
