using namespace System.Data

<#
.SYNOPSIS
	Defines the options of an SQL command.
#>
class SqlCommandOptions {

	<#
	.SYNOPSIS
		The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
	#>
	[Nullable[int]] $Timeout

	<#
	.SYNOPSIS
		The transaction within which the command executes.
	#>
	[IDbTransaction] $Transaction

	<#
	.SYNOPSIS
		Value indicating how the command is interpreted.
	#>
	[Nullable[CommandType]] $Type

	<#
	.SYNOPSIS
		Creates new options from the specified hash table.
	.PARAMETER HashTable
		The text providing the SQL statement.
	.OUTPUTS
		The options corresponding to the specified hash table.
	#>
	static [SqlCommandOptions] op_Implicit([hashtable] $HashTable) {
		return [SqlCommandOptions]@{
			Timeout = $HashTable.Timeout
			Transaction = $HashTable.Transaction
			Type = $HashTable.Type
		}
	}
}
