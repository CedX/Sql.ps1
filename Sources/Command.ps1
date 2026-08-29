using namespace Belin.Sql
using namespace System.Data
using namespace System.Data.Common
using namespace System.Diagnostics.CodeAnalysis

<#
.SYNOPSIS
	Creates a new command.
.INPUTS
	The text of the SQL statement.
.OUTPUTS
	The newly created command.
#>
function New-Command {
	[CmdletBinding()]
	[OutputType([Belin.Sql.SqlCommand])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The text of the SQL statement.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[string] $Text,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction,

		# Value indicating how the command is interpreted.
		[CommandType] $Type = [CommandType]::Text
	)

	process {
		$command = [SqlCommand]::new($Text)
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction
		$command.Type = $Type
		$command
	}
}

<#
.SYNOPSIS
	Creates a new command builder.
.OUTPUTS
	The newly created command builder.
#>
function New-CommandBuilder {
	[CmdletBinding(DefaultParameterSetName = "Connection")]
	[OutputType([Belin.Sql.SqlCommandBuilder])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The connection to the data source.
		[Parameter(Mandatory, ParameterSetName = "Connection", Position = 1)]
		[IDbConnection] $Connection,

		#	The position of the catalog name in a qualified table name.
		[Parameter(ParameterSetName = "LastInsertIdFunction")]
		[Parameter(ParameterSetName = "SupportsReturningClause")]
		[CatalogLocation] $CatalogLocation = [CatalogLocation]::Start,

		# The string used as the catalog separator.
		[Parameter(ParameterSetName = "LastInsertIdFunction")]
		[Parameter(ParameterSetName = "SupportsReturningClause")]
		[ValidateNotNullOrWhiteSpace()]
		[string] $CatalogSeparator = ".",

		# The SQL function to use when the `RETURNING` clause is not supported.
		[Parameter(ParameterSetName = "LastInsertIdFunction")]
		[ValidateNotNullOrWhiteSpace()]
		[string] $LastInsertIdFunction = "SCOPE_IDENTITY()",

		# The beginning string to use for naming parameters.
		[Parameter(ParameterSetName = "LastInsertIdFunction")]
		[Parameter(ParameterSetName = "SupportsReturningClause")]
		[ValidateNotNullOrWhiteSpace()]
		[string] $ParameterPrefix = "@",

		# The beginning string to use when specifying database objects.
		[Parameter(ParameterSetName = "LastInsertIdFunction")]
		[Parameter(ParameterSetName = "SupportsReturningClause")]
		[ValidateNotNullOrWhiteSpace()]
		[string] $QuotePrefix = "[",

		# The ending string to use when specifying database objects.
		[Parameter(ParameterSetName = "LastInsertIdFunction")]
		[Parameter(ParameterSetName = "SupportsReturningClause")]
		[ValidateNotNullOrWhiteSpace()]
		[string] $QuoteSuffix = "]",

		# The string used as the schema separator.
		[Parameter(ParameterSetName = "LastInsertIdFunction")]
		[Parameter(ParameterSetName = "SupportsReturningClause")]
		[ValidateNotNullOrWhiteSpace()]
		[string] $SchemaSeparator = ".",

		# Value indicating whether the ADO.NET provider supports the `RETURNING` clause.
		[Parameter(ParameterSetName = "SupportsReturningClause")]
		[switch] $SupportsReturningClause,

		# Value indicating whether the ADO.NET provider uses positional parameters.
		[Parameter(ParameterSetName = "LastInsertIdFunction")]
		[Parameter(ParameterSetName = "SupportsReturningClause")]
		[switch] $UsePositionalParameters
	)

	return $Connection ? [SqlCommandBuilder]::Create($Connection) : [SqlCommandBuilder]@{
		CatalogLocation = $CatalogLocation
		CatalogSeparator = $CatalogSeparator
		LastInsertIdFunction = $LastInsertIdFunction
		ParameterPrefix = $ParameterPrefix
		QuotePrefix = $QuotePrefix
		QuoteSuffix = $QuoteSuffix
		SchemaSeparator = $SchemaSeparator
		SupportsReturningClause = $SupportsReturningClause
		UsePositionalParameters = $UsePositionalParameters
	}
}

<#
.SYNOPSIS
	Creates a new order hint.
.INPUTS
	The name of the column for which the hint is being provided.
.OUTPUTS
	The newly created order hint.
#>
function New-OrderHint {
	[CmdletBinding()]
	[OutputType([Belin.Sql.SqlOrderHint])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The name of the column for which the hint is being provided.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[string] $Column,

		# The sort order of the column.
		[Parameter(Position = 2)]
		[SortOrder] $SortOrder = [SortOrder]::Ascending
	)

	process {
		[SqlOrderHint]::new($Column, $SortOrder)
	}
}

<#
.SYNOPSIS
	Creates a new order hint collection.
.INPUTS
	The collection whose elements are copied to the order hint collection.
.OUTPUTS
	The newly created order hint collection.
#>
function New-OrderHintCollection {
	[CmdletBinding()]
	[OutputType([Belin.Sql.SqlOrderHintCollection])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The collection whose elements are copied to the order hint collection.
		[Parameter(Position = 1, ValueFromPipeline)]
		[ValidateNotNull()]
		[SqlOrderHint[]] $OrderHints = @()
	)

	process {
		Write-Output ([SqlOrderHintCollection]::new($OrderHints)) -NoEnumerate
	}
}

<#
.SYNOPSIS
	Creates a new parameter.
.INPUTS
	The parameter name.
.OUTPUTS
	The newly created parameter.
#>
function New-Parameter {
	[CmdletBinding()]
	[OutputType([Belin.Sql.SqlParameter])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The parameter name.
		[Parameter(Mandatory, Position = 1, ValueFromPipeline)]
		[AllowEmptyString()]
		[string] $Name,

		# The parameter value.
		[Parameter(Position = 2)]
		[object] $Value,

		# Value indicating whether this parameter is input-only, output-only, bidirectional, or a stored procedure return value parameter.
		[Nullable[ParameterDirection]] $Direction,

		# The database type of this parameter.
		[Nullable[DbType]] $DbType,

		# The maximum size of this parameter, in bytes.
		[Nullable[int]] $Size,

		# Indicates the precision of numeric parameters.
		[Nullable[byte]] $Precision,

		# Indicates the scale of numeric parameters.
		[Nullable[byte]] $Scale
	)

	process {
		$parameter = [SqlParameter]::new($Name, $Value)
		$parameter.DbType = $DbType
		$parameter.Direction = $Direction
		$parameter.Precision = $Precision
		$parameter.Scale = $Scale
		$parameter.Size = $Size
		$parameter
	}
}

<#
.SYNOPSIS
	Creates a new parameter collection.
.INPUTS
	The collection whose elements are copied to the parameter collection.
.OUTPUTS
	The newly created parameter collection.
#>
function New-ParameterCollection {
	[CmdletBinding()]
	[OutputType([Belin.Sql.SqlParameterCollection])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The collection whose elements are copied to the parameter collection.
		[Parameter(Position = 1, ValueFromPipeline)]
		[ValidateNotNull()]
		[SqlParameter[]] $Parameters = @()
	)

	process {
		Write-Output ([SqlParameterCollection]::new($Parameters)) -NoEnumerate
	}
}
