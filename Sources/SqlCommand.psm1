using namespace System.Data
using module ./SqlParameterCollection.psm1

<#
.SYNOPSIS
	Represents an SQL statement that is executed while connected to a data source.
#>
[NoRunspaceAffinity()]
class SqlCommand {

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
		$this.Text = $Text
	}

	<#
	.SYNOPSIS
		Creates a new command from the specified text.
	.PARAMETER Parameter
		The text providing the SQL statement.
	.OUTPUTS
		The command corresponding to the specified text.
	#>
	static [SqlCommand] op_Implicit([string] $Text) {
		return [SqlCommand]::new($Text)
	}

	<#
	.SYNOPSIS
		Converts this command into an `IDbCommand` object.
	.PARAMETER Connection
		The connection to associate with the created command.
	.OUTPUTS
		The `IDbCommand` object corresponding to this command.
	#>
	[IDbCommand] ToDbCommand([IDbConnection] $Connection) {
		return $this.ToDbCommand($Connection, [SqlParameterCollection]::new())
	}

	<#
	.SYNOPSIS
		Converts this command into an `IDbCommand` object.
	.PARAMETER Connection
		The connection to associate with the created command.
	.PARAMETER Parameters
		The parameters of the SQL statement.
	.OUTPUTS
		The `IDbCommand` object corresponding to this command.
	#>
	[IDbCommand] ToDbCommand([IDbConnection] $Connection, [SqlParameterCollection] $Parameters) {
		$command = $Connection.CreateCommand()
		$command.CommandText = $this.Text
		$command.CommandTimeout = $this.Timeout
		$command.CommandType = $this.Type
		$command.Transaction = $this.Transaction
		foreach ($parameter in $Parameters) { $command.Parameters.Add($parameter.ToDbParameter($command)) }
		return $command
	}
}
