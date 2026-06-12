using namespace Belin.Sql
using namespace System.Data

<#
.SYNOPSIS
	Executes a parameterized SQL query and returns the single row.
.OUTPUTS
	The single row.
#>
function Get-Single {
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

		# The type of objects to return.
		[ValidateNotNull()]
		[Type] $As = [psobject]
	)

	begin {
		$dbCommand = $null
		$reader = $null
		if ($Connection.State -eq [ConnectionState]::Closed) { Open-SqlConnection $Connection }
	}

	end {
		$dbCommand = $Command.ToDbCommand($Connection, $Parameters)
		$reader = $dbCommand.ExecuteReader()

		$rowCount = 0
		while ($reader.Read()) {
			if (++$rowCount -gt 1) { break }
			$record = [SqlMapper]::Instance.CreateInstance($As, $reader)
		}

		if ($rowCount -eq 1) { $record }
		else { Write-Error "The result set is empty or contains more than one record." -Category InvalidOperation }
	}

	clean {
		${reader}?.Close()
		${dbCommand}?.Dispose()
	}
}
