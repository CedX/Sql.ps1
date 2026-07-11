using namespace Belin.Sql
using namespace System.Data
using namespace System.Data.Common
using namespace System.Diagnostics.CodeAnalysis

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
