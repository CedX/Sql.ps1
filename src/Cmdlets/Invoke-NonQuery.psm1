using namespace System.Data
using module ../SqlCommand.psm1
using module ../SqlParameterCollection.psm1

<#
.SYNOPSIS
	Executes a parameterized SQL statement.
.OUTPUTS
	The number of rows affected.
#>
function Invoke-NonQuery {
	[CmdletBinding()]
	[OutputType([int])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The command to be executed.
		[Parameter(Mandatory, Position = 1)]
		[SqlCommand] $Command,

		# The parameters of the SQL statement.
		[Parameter(Position = 2)]
		[SqlParameterCollection] $Parameters
	)

	begin {
		$dbCommand = $null
		if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }
	}

	end {
		$dbCommand = $Command.ToDbCommand($Connection, $Parameters)
		$dbCommand.ExecuteNonQuery()
	}

	clean {
		${dbCommand}?.Dispose()
	}
}
