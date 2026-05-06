using namespace System.Data

<#
.SYNOPSIS
	Rolls back the specified database transaction.
.INPUTS
	The transaction to roll back.
#>
function Deny-Transaction {
	[CmdletBinding()]
	[OutputType([void])]
	param (
		# The transaction to roll back.
		[Parameter(Mandatory, Position = 0, ValueFromPipeline)]
		[IDbTransaction] $InputObject
	)

	process {
		$InputObject.Rollback()
	}
}
