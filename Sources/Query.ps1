using namespace Belin.Sql
using namespace System.Data

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
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The command to be executed.
		[Parameter(Mandatory, Position = 2)]
		[SqlCommand] $Command,

		# The parameters of the SQL statement.
		[Parameter(Position = 3)]
		[SqlParameterCollection] $Parameters,

		# The type of objects to return.
		[ValidateNotNull()]
		[Type] $As = [psobject]
	)

	try { [DbConnectionExtensions]::QueryFirst($Connection, $As, $Command, $Parameters) }
	catch [InvalidOperationException] { Write-Error $_ }
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
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The command to be executed.
		[Parameter(Mandatory, Position = 2)]
		[SqlCommand] $Command,

		# The parameters of the SQL statement.
		[Parameter(Position = 3)]
		[SqlParameterCollection] $Parameters,

		# The type of object to return.
		[ValidateNotNull()]
		[Type] $As = [object]
	)

	[DbConnectionExtensions]::ExecuteScalar($Connection, $As, $Command, $Parameters)
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
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The command to be executed.
		[Parameter(Mandatory, Position = 2)]
		[SqlCommand] $Command,

		# The parameters of the SQL statement.
		[Parameter(Position = 3)]
		[SqlParameterCollection] $Parameters,

		# The type of objects to return.
		[ValidateNotNull()]
		[Type] $As = [psobject]
	)

	try { [DbConnectionExtensions]::QuerySingle($Connection, $As, $Command, $Parameters) }
	catch [InvalidOperationException] { Write-Error $_ }
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
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The command to be executed.
		[Parameter(Mandatory, Position = 2)]
		[SqlCommand] $Command,

		# The parameters of the SQL statement.
		[Parameter(Position = 3)]
		[SqlParameterCollection] $Parameters
	)

	[DbConnectionExtensions]::Execute($Connection, $Command, $Parameters)
}

<#
.SYNOPSIS
	Executes a parameterized SQL query and returns a sequence of objects whose properties correspond to the columns.
.OUTPUTS
	The sequence of object tuples whose properties correspond to the columns.
#>
function Invoke-Query {
	[CmdletBinding()]
	[OutputType([System.Collections.Generic.IList[object]])]
	[OutputType([System.Collections.Generic.IList[System.Runtime.CompilerServices.ITuple]])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 1)]
		[IDbConnection] $Connection,

		# The command to be executed.
		[Parameter(Mandatory, Position = 2)]
		[SqlCommand] $Command,

		# The parameters of the SQL statement.
		[Parameter(Position = 3)]
		[SqlParameterCollection] $Parameters,

		# The type of objects to return.
		[ValidateCount(1, 7)]
		[Type[]] $As = @([psobject]),

		# The fields from which to split and read the next objects.
		[ValidateCount(0, 6)]
		[string[]] $SplitOn = @()
	)

	if ($As.Count -gt 1) { [DbConnectionExtensions]::Query($Connection, $As, $Command, $Parameters, $SplitOn) }
	else { [DbConnectionExtensions]::Query($Connection, $As[0], $Command, $Parameters) }
}
