using namespace System.Data
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
		[ValidateCount(1, 4)]
		[Type[]] $As = @([psobject]),

		# The fields from which to split and read the next objects.
		[ValidateNotNullOrWhiteSpace()]
		[ValidateScript({ (-not $_) -or ($_.Count -eq $As.Count - 1) }, ErrorMessage = "The number of split fields is invalid.")]
		[string[]] $SplitOn = @()
	)

	begin {
		$dbCommand = $null
		$reader = $null
		if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }
		if ((-not $SplitOn) -and ($As.Count -gt 1)) { $SplitOn = (0..$As.Count - 1).ForEach{ "Id" } }
	}

	end {
		$dbCommand = $Command.ToDbCommand($Connection, $Parameters)
		$reader = $dbCommand.ExecuteReader()
		while ($reader.Read()) { [SqlMapper]::Instance.CreateInstance($As, $reader, $SplitOn) }
	}

	clean {
		${dbCommand}?.Dispose()
		${reader}?.Close()
	}
}
