using namespace System.Data
using module ./SqlParameterCollection.psm1

<#
.SYNOPSIS
	Represents an SQL statement that is executed while connected to a data source.
#>
class SqlCommand {

	<#
	.SYNOPSIS
		The parameters of the SQL statement.
	#>
	[ValidateNotNull()]
	[SqlParameterCollection] $Parameters

	<#
	.SYNOPSIS
		The text of the SQL statement.
	#>
	[ValidateNotNullOrWhiteSpace()]
	[string] $Text

	<#
	.SYNOPSIS
		The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
	#>
	[ValidateRange("NonNegative")]
	[int] $Timeout = 30

	<#
	.SYNOPSIS
		The transaction within which the command executes.
	#>
	[IDbTransaction] $Transaction

	<#
	.SYNOPSIS
		Value indicating how the command is interpreted.
	#>
	[CommandType] $Type = [CommandType]::Text

	<#
	.SYNOPSIS
		Creates a new command.
	.PARAMETER Text
		The text of the SQL statement.
	#>
	SqlCommand([string] $Text) {
		$this.Parameters = [SqlParameterCollection]::new()
		$this.Text = $Text
	}

	<#
	.SYNOPSIS
		Creates a new command.
	.PARAMETER Text
		The text of the SQL statement.
	.PARAMETER Parameters
		The parameters of the SQL statement.
	#>
	SqlCommand([string] $Text, [SqlParameterCollection] $Parameters) {
		$this.Parameters = $Parameters
		$this.Text = $Text
	}

	# TODO ??? Implicit cast from string?
	# static [SqlCommand] op_Implicit([string] $Text)

	<#
	.SYNOPSIS
		Converts this command into an `IDbCommand` object.
	.PARAMETER Connection
		The connection to associate with the created command.
	.OUTPUTS
		The `IDbCommand` object corresponding to this command.
	#>
	[IDbCommand] ToDbCommand([IDbConnection] $Connection) {
		$command = $Connection.CreateCommand()
		$command.CommandText = $this.Text
		$command.CommandTimeout = $this.Timeout
		$command.CommandType = $this.Type
		$command.Transaction = $this.Transaction
		foreach ($parameter in $this.Parameters) { $command.Parameters.Add($parameter.ToDbParameter($command)) }
		return $command
	}
}
