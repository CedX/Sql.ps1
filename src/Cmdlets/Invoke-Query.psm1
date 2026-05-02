using namespace System.Data
using module ../SqlCommand.psm1
using module ../SqlMapper.psm1
using module ../SqlParameterCollection.psm1

<#
.SYNOPSIS
	Executes a parameterized SQL query and returns a sequence of objects whose properties correspond to the columns.
.OUTPUTS
	The sequence of object tuples whose properties correspond to the columns.
#>
function Invoke-Query {
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
		[ValidateCount(1, 7)]
		[Type[]] $As = @([psobject]),

		# The fields from which to split and read the next objects.
		[ValidateCount(0, 6)]
		[string[]] $SplitOn = @()
	)

	begin {
		$dbCommand = $null
		$reader = $null
		if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }
	}

	end {
		$dbCommand = $Command.ToDbCommand($Connection, $Parameters)
		$reader = $dbCommand.ExecuteReader()
		while ($reader.Read()) {
			$As.Count -gt 1 ? [SqlMapper]::Instance.CreateInstance($As, $reader, $SplitOn) : [SqlMapper]::Instance.CreateInstance($As[0], $reader)
		}
	}

	clean {
		${dbCommand}?.Dispose()
		${reader}?.Close()
	}
}
