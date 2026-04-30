using namespace System.Data
using namespace System.Dynamic
using module ../SqlParameterCollection.psm1

<#
.SYNOPSIS
	An array of types representing the number, order, and type of the parameters of the underlying method to invoke.
#>
$ParameterTypes = @(
	([IDbConnection], [string], [SqlParameterCollection], [QueryOptions]),
	([IDbConnection], [string], [SqlParameterCollection], [string], [QueryOptions]),
	([IDbConnection], [string], [SqlParameterCollection], [Nullable[ValueTuple[[string], [string]]]], [QueryOptions]),
	([IDbConnection], [string], [SqlParameterCollection], [Nullable[ValueTuple[[string], [string], [string]]]], [QueryOptions])
)

<#
.SYNOPSIS
	Executes a parameterized SQL query and returns a sequence of objects whose properties correspond to the columns.
.OUTPUTS
	The sequence of object tuples whose properties correspond to the columns.
#>
function Invoke-Query {
	[CmdletBinding()]
	[OutputType([object], [ValueTuple[[object], [object]]], [ValueTuple[[object], [object], [object]]], [ValueTuple[[object], [object], [object], [object]]])]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, Position = 0)]
		[IDbConnection] $Connection,

		# The SQL query to be executed.
		[Parameter(Mandatory, Position = 1)]
		[string] $Command,

		# The parameters of the SQL query.
		[Parameter(Position = 2)]
		[SqlParameterCollection] $Parameters = @(),

		# The type of objects to return.
		[ValidateCount(1, 4)]
		[Type[]] $As = @([ExpandoObject]),

		# The field from which to split and read the next object.
		[ValidateCount(1, 3)]
		[ValidateNotNullOrWhiteSpace()]
		[string[]] $SplitOn = @("Id"),

		# Value indicating how the command is interpreted.
		[CommandType] $CommandType = [CommandType]::Text,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction to use, if any.
		[IDbTransaction] $Transaction,

		# Value indicating whether to prevent from enumerating the rows.
		[switch] $NoEnumerate,

		# Value indicating whether to prevent from buffering the rows in memory.
		[switch] $Stream
	)

	if ($Connection.State -eq [ConnectionState]::Closed) { $Connection.Open() }

	$queryOptions = [QueryOptions]@{ Stream = $Stream; Timeout = $Timeout; Transaction = $Transaction; Type = $CommandType }
	$arguments = switch ($As.Count) {
		1 { @($Connection, $Command, $Parameters, $queryOptions); break }
		2 { @($Connection, $Command, $Parameters, $SplitOn[0], $queryOptions); break }
		3 { @($Connection, $Command, $Parameters, [ValueTuple]::Create($SplitOn[0], $SplitOn.Count -le 1 ? "Id" : $SplitOn[1]), $queryOptions); break }
		default { @($Connection, $Command, $Parameters, [ValueTuple]::Create($SplitOn[0], $SplitOn.Count -le 1 ? "Id" : $SplitOn[1], $SplitOn.Count -le 2 ? "Id" : $SplitOn[2]), $queryOptions) }
	}

	$method = [ConnectionExtensions].GetMethod("Query", $As.Count, $Script:ParameterTypes[$As.Count - 1]).MakeGenericMethod($As)
	Write-Output $method.Invoke($null, $arguments) -NoEnumerate:$NoEnumerate
}
