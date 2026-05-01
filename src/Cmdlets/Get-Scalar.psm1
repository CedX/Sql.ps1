using namespace System.Data
using module ../SqlCommand.psm1
using module ../SqlMapper.psm1
using module ../SqlParameterCollection.psm1

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

	if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }

	$dbCommand = $Command.ToDbCommand($Connection, $Parameters)
	$value = $dbCommand.ExecuteScalar()
	$dbCommand.Dispose()
	($null -eq $Value) -or ($value -is [DBNull]) ? $null : [SqlMapper]::ChangeType($value, $As)
}
