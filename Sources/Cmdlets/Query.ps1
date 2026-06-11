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
		if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }
	}

	end {
		$dbCommand = $Command.ToDbCommand($Connection, $Parameters)
		$value = $dbCommand.ExecuteScalar()
		($null -eq $value) -or ($value -is [DBNull]) ? $null : [SqlMapper]::ChangeType($value, $As)
	}

	clean {
		${dbCommand}?.Dispose()
	}
}

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
		if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }
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
		${reader}?.Close()
		${dbCommand}?.Dispose()
	}
}
