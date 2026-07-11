using namespace Belin.Sql
using namespace System.Diagnostics.CodeAnalysis

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
