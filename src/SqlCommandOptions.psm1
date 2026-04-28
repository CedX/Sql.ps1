using namespace System.Data

<#
.SYNOPSIS
	Defines the options of a SQL command.
#>
class SqlCommandOptions {

	<#
	.SYNOPSIS
		The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
	#>
	[ValidateRange("Positive")]
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
}
