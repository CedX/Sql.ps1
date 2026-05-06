using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Creates a new transaction associated with the specified connection.
.OUTPUTS
	The newly created transaction.
#>
function New-Transaction {
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
