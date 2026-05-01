using namespace System.Data
using module ../SqlCommand.psm1
using module ../SqlMapper.psm1
using module ../SqlParameterCollection.psm1

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
		if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }
		$dbCommand = $null
		$reader = $null
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
		${dbCommand}?.Dispose()
		${reader}?.Close()
	}
}
