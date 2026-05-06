using module ../SqlMapper.psm1

<#
.SYNOPSIS
	Gets the singleton instance of the data mapper.
.OUTPUTS
	The singleton instance of the data mapper.
#>
function Get-Mapper {
	[CmdletBinding()]
	[OutputType([SqlMapper])]
	param ()

	[SqlMapper]::Instance
}
