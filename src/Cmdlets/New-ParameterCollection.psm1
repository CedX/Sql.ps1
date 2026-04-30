using namespace System.Diagnostics.CodeAnalysis
using module ../SqlParameter.psm1
using module ../SqlParameterCollection.psm1

<#
.SYNOPSIS
	Creates a new parameter collection.
.OUTPUTS
	The newly created parameter collection.
#>
function New-ParameterCollection {
	[CmdletBinding()]
	[OutputType([SqlParameterCollection])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The collection whose elements are copied to the parameter collection.
		[ValidateNotNull()]
		[SqlParameter[]] $Parameters = @()
	)

	[SqlParameterCollection]::new($Parameters)
}
