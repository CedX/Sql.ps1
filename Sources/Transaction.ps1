using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Commits the specified transaction.
.INPUTS
	The transaction to commit.
#>
function Complete-Transaction {
	[CmdletBinding()]
	[OutputType([void])]
	param (
		# The transaction to commit.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[IDbTransaction] $InputObject
	)

	process {
		$InputObject.Commit()
	}
}

<#
.SYNOPSIS
	Starts a new transaction.
.OUTPUTS
	The newly created transaction.
#>
function Start-Transaction {
	[CmdletBinding()]
	[OutputType([System.Data.IDbTransaction])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The isolation level for the transaction to use.
		[Parameter(Position = 2)]
		[IsolationLevel] $IsolationLevel = [IsolationLevel]::Unspecified
	)

	if ($Connection.State -eq [ConnectionState]::Closed) { Open-SqlConnection $Connection }
	$Connection.BeginTransaction($IsolationLevel)
}

<#
.SYNOPSIS
	Rolls back the specified transaction.
.INPUTS
	The transaction to roll back.
#>
function Undo-Transaction {
	[CmdletBinding()]
	[OutputType([void])]
	param (
		# The transaction to roll back.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[IDbTransaction] $InputObject
	)

	process {
		$InputObject.Rollback()
	}
}
