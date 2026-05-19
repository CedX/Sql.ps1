using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Creates a new database connection.
.INPUTS
	The connection string used to open the database.
.OUTPUTS
	The newly created database connection.
#>
function New-SqlConnection {
	[CmdletBinding(DefaultParameterSetName = "Type")]
	[OutputType([System.Data.IDbConnection])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The type of connection class to instantiate.
		[Parameter(Mandatory, ParameterSetName = "Type", Position = 0)]
		[Type] $Type,

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
			default { $Type }
		}

		$connection = [IDbConnection] [Activator]::CreateInstance($connectionType, $ConnectionString)
		if ($Open) { $connection.Open() }
		$connection
	}
}
