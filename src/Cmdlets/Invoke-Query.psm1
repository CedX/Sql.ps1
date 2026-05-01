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
		[ValidateCount(1, 8)]
		[Type[]] $As = @([psobject]),

		# The fields from which to split and read the next objects.
		[ValidateCount(0, 7)]
		[string[]] $SplitOn = @()
	)

	begin {
		# TODO [ValidateScript({ (-not $_) -or ($_.Count -eq $As.Count - 1) }, ErrorMessage = "The number of split fields is invalid.")]

		$dbCommand = $null
		$reader = $null
		if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }
		if ((-not $SplitOn) -and ($As.Count -ge 2)) { $SplitOn = (0..$As.Count - 2).ForEach{ "Id" } }
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
