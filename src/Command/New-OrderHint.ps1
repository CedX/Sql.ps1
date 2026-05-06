using namespace System.Diagnostics.CodeAnalysis
using module ../SqlOrderHint.psm1

<#
.SYNOPSIS
	Creates a new order hint.
.OUTPUTS
	The newly created order hint.
#>
function New-SqlOrderHint {
	[CmdletBinding()]
	[OutputType([SqlOrderHint])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The order hint name.
		[Parameter(Mandatory, Position = 0, ValueFromPipeline)]
		[AllowEmptyString()]
		[string] $Name,

		# The order hint value.
		[Parameter(Position = 1)]
		[object] $Value
	)

	process {
		[SqlOrderHint]::new($Name, $Value)
	}
}
