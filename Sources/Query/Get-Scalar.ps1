using namespace Belin.Sql
using namespace System.Data

<#
.SYNOPSIS
	Executes a parameterized SQL query that selects a single value.
.OUTPUTS
	The first column of the first row.
#>
function Get-Scalar {
	[CmdletBinding()]
	[OutputType([object])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The command to be executed.
		[Parameter(Mandatory, Position = 1)]
		[SqlCommand] $Command,

		# The parameters of the SQL statement.
		[Parameter(Position = 2)]
		[SqlParameterCollection] $Parameters,

		# The type of object to return.
		[ValidateNotNull()]
		[Type] $As = [object]
	)

	begin {
		$dbCommand = $null
		if ($Connection.State -eq [ConnectionState]::Closed) { Open-SqlConnection $Connection }
	}

	end {
		$dbCommand = $Command.ToDbCommand($Connection, $Parameters)
		$value = $dbCommand.ExecuteScalar()
		($null -eq $value) -or ($value -is [DBNull]) ? $null : [SqlMapper]::Instance.ChangeType($value, $As)
	}

	clean {
		${dbCommand}?.Dispose()
	}
}
