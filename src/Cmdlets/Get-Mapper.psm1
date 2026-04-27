
<#
.SYNOPSIS
	Gets the singleton instance of the data mapper.
.OUTPUTS
	The singleton instance of the data mapper.
#>
function Get-Mapper {
	[CmdletBinding()]
	[OutputType([Mapper])]
	param ()

	[Mapper]::Instance
}
