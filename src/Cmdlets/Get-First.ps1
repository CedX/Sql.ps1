using namespace System.Data
using module ../SqlCommand.psm1
using module ../SqlMapper.psm1
using module ../SqlParameterCollection.psm1

<#
.SYNOPSIS
	Executes a parameterized SQL query and returns the first row.
.OUTPUTS
	The first row.
#>
function Get-First {
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
		if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }
	}

	end {
		$dbCommand = $Command.ToDbCommand($Connection, $Parameters)
		$reader = $dbCommand.ExecuteReader()
		if ($reader.Read()) { [SqlMapper]::Instance.CreateInstance($As, $reader) }
		else { Write-Error "The result set is empty." -Category InvalidOperation }
	}

	clean {
		${reader}?.Close()
		${dbCommand}?.Dispose()
	}
}
