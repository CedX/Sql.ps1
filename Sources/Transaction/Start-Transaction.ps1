using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Starts a new transaction.
.OUTPUTS
	The newly created transaction.
#>
function Start-Transaction {
	[CmdletBinding()]
	[OutputType([System.Data.IDbTransaction])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions")]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The isolation level for the transaction to use.
		[Parameter(Position = 1)]
		[IsolationLevel] $IsolationLevel = [IsolationLevel]::Unspecified
	)

	if ($Connection.State -eq [ConnectionState]::Closed) { Open-SqlConnection $Connection }
	$Connection.BeginTransaction($IsolationLevel)
}
