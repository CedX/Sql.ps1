using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Closes the specified database connection.
.INPUTS
	The connection to the data source.
#>
function Close-Connection {
	[CmdletBinding()]
	[OutputType([void])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0, ValueFromPipeline)]
		[IDbConnection] $InputObject,

		# Value indicating whether the connection should also be disposed.
		[switch] $Dispose
	)

	process {
		try { $InputObject.Close() }
		catch { Write-Error $_ }
		finally { if ($Dispose) { $InputObject.Dispose() } }
	}
}

<#
.SYNOPSIS
	Creates a new database connection.
.INPUTS
	The connection string used to open the database.
.OUTPUTS
	The newly created database connection.
#>
function New-Connection {
	[CmdletBinding(DefaultParameterSetName = "Type")]
	[OutputType([System.Data.IDbConnection])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The type of connection class to instantiate.
		[Parameter(Mandatory, ParameterSetName = "Type", Position = 0)]
		[Type] $Class,

		# The name of an ADO.NET provider.
		[Parameter(Mandatory, ParameterSetName = "Provider", Position = 0)]
		[ValidateSet("Odbc", "OleDb", "SqlClient")]
		[string] $Provider,

		# The connection string used to open the database.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[string] $ConnectionString,

		# Value indicating whether to open the connection.
		[switch] $Open
	)

	process {
		$connectionType = switch ($Provider) {
			"Odbc" { [Odbc.OdbcConnection]; break }
			"OleDb" { [OleDb.OleDbConnection]; break }
			"SqlClient" { [SqlClient.SqlConnection]; break }
			default { $Class }
		}

		$connection = [IDbConnection] [Activator]::CreateInstance($connectionType, $ConnectionString)
		if ($Open) { $connection.Open() }
		$connection
	}
}
