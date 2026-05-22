using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Commits the specified database transaction.
.INPUTS
	The transaction to commit.
#>
function Approve-SqlTransaction {
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

<#
.SYNOPSIS
	Rolls back the specified database transaction.
.INPUTS
	The transaction to roll back.
#>
function Deny-SqlTransaction {
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

<#
.SYNOPSIS
	Creates a new transaction associated with the specified connection.
.OUTPUTS
	The newly created transaction.
#>
function New-SqlTransaction {
	[CmdletBinding()]
	[OutputType([System.Data.IDbTransaction])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The isolation level for the transaction to use.
		[Parameter(Position = 1)]
		[IsolationLevel] $IsolationLevel = [IsolationLevel]::Unspecified
	)

	$Connection.BeginTransaction($IsolationLevel)
}
