using namespace System.Data
using namespace System.Data.Common
using namespace System.Linq
using module ./Reflection/DbTableInfo.psm1
using module ./SqlCommand.psm1
using module ./SqlMapper.psm1
using module ./SqlParameter.psm1
using module ./SqlParameterCollection.psm1

<#
.SYNOPSIS
	Automatically generates single-table commands.
#>
class SqlCommandBuilder {

	<#
	.SYNOPSIS
		The position of the catalog name in a qualified table name.
	#>
	[CatalogLocation] $CatalogLocation = [CatalogLocation]::Start

	<#
	.SYNOPSIS
		The string used as the catalog separator.
	#>
	[ValidateNotNullOrEmpty()]
	[string] $CatalogSeparator = "."

	<#
	.SYNOPSIS
		The SQL function to use when the `RETURNING` clause is not supported.
	#>
	[ValidateNotNullOrEmpty()]
	[string] $LastInsertIdFunction = "SCOPE_IDENTITY()"

	<#
	.SYNOPSIS
		The beginning string to use for naming parameters.
	#>
	[ValidateNotNullOrEmpty()]
	[string] $ParameterPrefix = "@"

	<#
	.SYNOPSIS
		The beginning string to use when specifying database objects.
	#>
	[ValidateNotNullOrEmpty()]
	[string] $QuotePrefix = "["

	<#
	.SYNOPSIS
		The ending string to use when specifying database objects.
	#>
	[ValidateNotNullOrEmpty()]
	[string] $QuoteSuffix = "]"

	<#
	.SYNOPSIS
		The string used as the schema separator.
	#>
	[ValidateNotNullOrEmpty()]
	[string] $SchemaSeparator = "."

	<#
	.SYNOPSIS
		Value indicating whether the ADO.NET provider supports the `RETURNING` clause.
	#>
	[bool] $SupportsReturningClause

	<#
	.SYNOPSIS
		Value indicating whether the ADO.NET provider uses positional parameters.
	#>
	[bool] $UsePositionalParameters

	<#
	.SYNOPSIS
		Creates a new command builder.
	.PARAMETER Connection
		The connection to the data source.
	#>
	SqlCommandBuilder([IDbConnection] $Connection) {
		switch ($Connection.GetType().FullName) {
			{ $_ -in "MySql.Data.MySqlClient.MySqlConnection", "MySqlConnector.MySqlConnection" } {
				$this.QuotePrefix = $this.QuoteSuffix = '`'
				$this.LastInsertIdFunction = "LAST_INSERT_ID()"
				break
			}
			{ $_ -in "FirebirdSql.Data.FirebirdClient.FbConnection", "Microsoft.Data.Sqlite.SqliteConnection", "Npgsql.NpgsqlConnection", "System.Data.SQLite.SQLiteConnection" } {
				$this.QuotePrefix = $this.QuoteSuffix = '"'
				$this.SupportsReturningClause = $true
				break
			}
			"Oracle.ManagedDataAccess.Client.OracleConnection" {
				$this.CatalogLocation = CatalogLocation.End
				$this.CatalogSeparator = "@"
				$this.ParameterPrefix = ":"
				$this.QuotePrefix = $this.QuoteSuffix = '"'
				$this.SupportsReturningClause = $true
				break
			}
			{ $_ -in "System.Data.Odbc.OdbcConnection", "System.Data.OleDb.OleDbConnection" } {
				$this.UsePositionalParameters = $true
				break
			}
		}
	}

	<#
	.SYNOPSIS
		Gets the generated command to delete an entity.
	.PARAMETER Entity
		The entity to delete.
	.OUTPUTS
		The generated command to delete an entity.
	#>
	[ValueTuple[SqlCommand, SqlParameterCollection]] GetDeleteCommand([object] $Entity) {
		$table = [SqlMapper]::Instance.GetTable($Entity.GetType())
		$idColumn = $table.IdentityColumn
		if (-not $idColumn) { throw [InvalidOperationException] "The identity column could not be found." }

		$parameter = [SqlParameter]::new($this.UsePositionalParameters ? "?1" : $this.GetParameterName($idColumn.Name), $idColumn.GetValue($Entity))
		$text = "
			DELETE FROM $($this.GetTableName($table))
			WHERE $($this.QuoteIdentifier($idColumn.Name)) = $($this.UsePositionalParameters ? "?" : $parameter.Name)"

		return [ValueTuple]::Create[SqlCommand, SqlParameterCollection]($text.Trim(), [SqlParameterCollection]::new($parameter))
	}

	<#
	.SYNOPSIS
		Gets the generated command to check the existence of an entity.
	.PARAMETER Type
		The entity type.
	.PARAMETER Id
		The value of the entity's primary key.
	.OUTPUTS
		The generated command to check the existence of an entity.
	#>
	[ValueTuple[SqlCommand, SqlParameterCollection]] GetExistsCommand([Type] $Type, [object] $Id) {
		$table = [SqlMapper]::Instance.GetTable($Type)
		$idColumn = $table.IdentityColumn
		if (-not $idColumn) { throw [InvalidOperationException] "The identity column could not be found." }

		$parameter = [SqlParameter]::new($this.UsePositionalParameters ? "?1" : $this.GetParameterName($idColumn.Name), $Id)
		$text = "
			SELECT 1
			FROM $($this.GetTableName($table))
			WHERE $($this.QuoteIdentifier($idColumn.Name)) = $($this.UsePositionalParameters ? "?" : $parameter.Name)"

		return [ValueTuple]::Create[SqlCommand, SqlParameterCollection]($text.Trim(), [SqlParameterCollection]::new($parameter))
	}

	<#
	.SYNOPSIS
		Gets the generated command to find an entity.
	.PARAMETER Type
		The entity type.
	.PARAMETER Id
		The value of the entity's primary key.
	.OUTPUTS
		The generated command to find an entity.
	#>
	[ValueTuple[SqlCommand, SqlParameterCollection]] GetFindCommand([Type] $Type, [object] $Id) {
		return $this.GetFindCommand($Type, $Id, @())
	}

	<#
	.SYNOPSIS
		Gets the generated command to find an entity.
	.PARAMETER Type
		The entity type.
	.PARAMETER Id
		The value of the entity's primary key.
	.PARAMETER Columns
		The list of columns to select. By default, all columns.
	.OUTPUTS
		The generated command to find an entity.
	#>
	[ValueTuple[SqlCommand, SqlParameterCollection]] GetFindCommand([Type] $Type, [object] $Id, [string[]] $Columns) {
		$table = [SqlMapper]::Instance.GetTable($Type)
		$idColumn = $table.IdentityColumn
		if (-not $idColumn) { throw [InvalidOperationException] "The identity column could not be found." }

		$fields = ($Columns ? $table.Columns.Values.Where{ $Columns.Contains($_.Name) } : $table.Columns.Values).Where{ $_.CanWrite }.ForEach{ $_.Name }
		if (-not $fields.Contains($idColumn.Name)) { $fields += $idColumn.Name }

		$parameter = [SqlParameter]::new($this.UsePositionalParameters ? "?1" : $this.GetParameterName($idColumn.Name), $id)
		$text = "
			SELECT $($fields.ForEach{ $this.QuoteIdentifier($_) } -join ", ")
			FROM $($this.GetTableName($table))
			WHERE $($this.QuoteIdentifier($idColumn.Name)) = $($this.UsePositionalParameters ? "?" : $parameter.Name)"

		return [ValueTuple]::Create[SqlCommand, SqlParameterCollection]($text.Trim(), [SqlParameterCollection]::new($parameter))
	}

	<#
	.SYNOPSIS
		Gets the generated command to insert an entity.
	.PARAMETER Entity
		The entity to insert.
	.OUTPUTS
		The generated command to insert an entity.
	#>
	[ValueTuple[SqlCommand, SqlParameterCollection]] GetInsertCommand([object] $Entity) {
		$table = [SqlMapper]::Instance.GetTable($Entity.GetType())
		$idColumn = $table.IdentityColumn
		if (-not $idColumn) { throw [InvalidOperationException] "The identity column could not be found." }

		$fields = $table.Columns.Values.Where{ $_.CanRead -and (-not $_.IsComputed) }
		$text = "
			INSERT INTO $($this.GetTableName($table)) ($($fields.ForEach{ $this.QuoteIdentifier($_) } -join ", "))
			VALUES ($($fields.ForEach{ $this.UsePositionalParameters ? "?" : $this.GetParameterName($_.Name) } -join ", "))
			$($this.SupportsReturningClause ? "RETURNING $($this.QuoteIdentifier($idColumn.Name))" : "; SELECT $($this.LastInsertIdFunction);")"

		$parameters = [SqlParameterCollection]::new()
		for ($index = 0; $index -lt $fields.Count; $index++) {
			$name = $this.UsePositionalParameters ? "?$($index + 1)" : $this.GetParameterName($fields[$index].Name)
			$parameters.Add([SqlParameter]::new($name, $fields[$index].GetValue($Entity)))
		}

		return [ValueTuple]::Create[SqlCommand, SqlParameterCollection]($text.Trim(), $parameters)
	}

	<#
	.SYNOPSIS
		Gets the generated command to update an entity.
	.PARAMETER Entity
		The entity to update.
	.OUTPUTS
		The generated command to update an entity.
	#>
	[ValueTuple[SqlCommand, SqlParameterCollection]] GetUpdateCommand([object] $Entity) {
		return $this.GetUpdateCommand($Entity, @())
	}

	<#
	.SYNOPSIS
		Gets the generated command to update an entity.
	.PARAMETER Entity
		The entity to update.
	.PARAMETER Columns
		The list of columns to update. By default, all columns.
	.OUTPUTS
		The generated command to update an entity.
	#>
	[ValueTuple[SqlCommand, SqlParameterCollection]] GetUpdateCommand([object] $Entity, [string[]] $Columns) {
		$table = [SqlMapper]::Instance.GetTable($Entity.GetType())
		$idColumn = $table.IdentityColumn
		if (-not $idColumn) { throw [InvalidOperationException] "The identity column could not be found." }

		$fields = ($Columns ? $table.Columns.Values.Where{ $Columns.Contains($_.Name) } : $table.Columns.Values).Where{ $_.CanRead -and (-not $_.IsComputed) }
		$text = "
			UPDATE $($this.GetTableName($table))
			SET $($fields.ForEach{ "$($this.QuoteIdentifier($_.Name)) = $($this.UsePositionalParameters ? "?" : $this.GetParameterName($_.Name))" } -join ", ")
			WHERE $($this.QuoteIdentifier($idColumn.Name)) = $($this.UsePositionalParameters ? "?" : $this.GetParameterName($idColumn.Name))"

		$parameters = [SqlParameterCollection]::new()
		for ($index = 0; $index -lt $fields.Count; $index++) {
			$name = $this.UsePositionalParameters ? "?$($index + 1)" : $this.GetParameterName($fields[$index].Name)
			$parameters.Add([SqlParameter]::new($name, $fields[$index].GetValue($Entity)))
		}

		$parameters.Add([SqlParameter]::new($idColumn.Name, $idColumn.GetValue($Entity)))
		return [ValueTuple]::Create[SqlCommand, SqlParameterCollection]($text.Trim(), $parameters)
	}

	<#
	.SYNOPSIS
		Given an unquoted identifier, returns the correct quoted form of that identifier.
	.PARAMETER UnquotedIdentifier
		The original unquoted identifier.
	.OUTPUTS
		The quoted version of the identifier.
	#>
	[string] QuoteIdentifier([string] $UnquotedIdentifier) {
		return "$($this.QuotePrefix)$($UnquotedIdentifier.Replace($this.QuoteSuffix, $this.QuoteSuffix + $this.QuoteSuffix))$($this.QuoteSuffix)"
	}

	<#
	.SYNOPSIS
		Given a quoted identifier, returns the correct unquoted form of that identifier.
	.PARAMETER QuotedIdentifier
		The original quoted identifier.
	.OUTPUTS
		The unquoted version of the identifier.
	#>
	[string] UnquoteIdentifier([string] $QuotedIdentifier) {
		if ($QuotedIdentifier.StartsWith($this.QuotePrefix, [StringComparison]::Ordinal)) { $QuotedIdentifier = $QuotedIdentifier.Substring($this.QuotePrefix.Length) }
		if ($QuotedIdentifier.EndsWith($this.QuoteSuffix, [StringComparison]::Ordinal)) { $QuotedIdentifier = $QuotedIdentifier.Substring(0, $QuotedIdentifier.Length - $this.QuoteSuffix.Length) }
		return $QuotedIdentifier.Replace($this.QuoteSuffix + $this.QuoteSuffix, $this.QuoteSuffix)
	}

	<#
	.SYNOPSIS
		Returns the full parameter name corresponding to the specified partial parameter name.
	.PARAMETER ParameterName
		The partial name of the parameter.
	.OUTPUTS
		The full parameter name corresponding to the specified partial parameter name.
	#>
	hidden [string] GetParameterName([string] $ParameterName) {
		return "$($this.ParameterPrefix)$ParameterName"
	}

	<#
	.SYNOPSIS
		Returns the fully qualified name corresponding to the specified table.
	.PARAMETER Table
		The table.
	.OUTPUTS
		The fully qualified name corresponding to the specified table.
	#>
	hidden [string] GetTableName([DbTableInfo] $Table) {
		return $Table.Schema ? "$($this.QuoteIdentifier($Table.Schema))$($this.SchemaSeparator)$($this.QuoteIdentifier($Table.Name))" : $this.QuoteIdentifier($Table.Name)
	}
}
