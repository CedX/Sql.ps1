using module ./SqlCommandOptions.psm1

<#
.SYNOPSIS
	Defines the options of a SQL query.
#>
class SqlQueryOptions: SqlCommandOptions {

	<#
	.SYNOPSIS
		Value indicating whether to prevent from buffering the rows in memory.
	#>
	[bool] $Stream
}
