using namespace System.Data

<#
.SYNOPSIS
	Commits the specified database transaction.
.INPUTS
	The transaction to commit.
#>
function Approve-Transaction {
	[CmdletBinding()]
	[OutputType([void])]
	param (
		# The transaction to commit.
		[Parameter(Mandatory, Position = 0, ValueFromPipeline)]
		[IDbTransaction] $InputObject
	)

	process {
		$InputObject.Commit()
	}
}
