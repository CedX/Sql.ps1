namespace Belin.Sql

open System
open System.Data
open System.Data.Common
open System.Management.Automation

/// Creates a new command.
[<Cmdlet(VerbsCommon.New, "Command"); OutputType(typeof<SqlCommand>)>]
type NewCommand() =
  inherit Cmdlet()

  /// The text of the SQL statement.
  [<Parameter(Mandatory = true, Position = 1, ValueFromPipeline = true)>]
  member val Text = "" with get, set

  /// The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
  [<Parameter; ValidateRange(ValidateRangeKind.NonNegative)>]
  member val Timeout = 30 with get, set

  /// The transaction within which the command executes.
  [<Parameter>]
  member val Transaction: IDbTransaction | null = null with get, set

  /// Value indicating how the command is interpreted.
  [<Parameter>]
  member val Type = CommandType.Text with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () = this.WriteObject (SqlCommand (
    this.Text,
    Timeout = this.Timeout,
    Transaction = this.Transaction,
    Type = this.Type
  ))

/// Creates a new command builder.
[<Cmdlet(VerbsCommon.New, "CommandBuilder", DefaultParameterSetName = "Connection"); OutputType(typeof<SqlCommandBuilder>)>]
type NewCommandBuilder() =
  inherit PSCmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, ParameterSetName = "Connection", Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The position of the catalog name in a qualified table name.
  [<Parameter(ParameterSetName = "LastInsertIdFunction"); Parameter(ParameterSetName = "SupportsReturningClause")>]
  member val CatalogLocation = CatalogLocation.Start with get, set

  /// The string used as the catalog separator.
  [<Parameter(ParameterSetName = "LastInsertIdFunction"); Parameter(ParameterSetName = "SupportsReturningClause")>]
  [<ValidateNotNullOrWhiteSpace>]
  member val CatalogSeparator = "." with get, set

  /// The SQL type to use when the `RETURNING` clause is not supported.
  [<Parameter(ParameterSetName = "LastInsertIdFunction")>]
  [<ValidateNotNullOrWhiteSpace>]
  member val LastInsertIdFunction = "SCOPE_IDENTITY()" with get, set

  /// The beginning string to use for naming parameters.
  [<Parameter(ParameterSetName = "LastInsertIdFunction"); Parameter(ParameterSetName = "SupportsReturningClause")>]
  [<ValidateNotNullOrWhiteSpace>]
  member val ParameterPrefix = "@" with get, set

  /// The beginning string to use when specifying database objects.
  [<Parameter(ParameterSetName = "LastInsertIdFunction"); Parameter(ParameterSetName = "SupportsReturningClause")>]
  [<ValidateNotNullOrWhiteSpace>]
  member val QuotePrefix = "[" with get, set

  /// The ending string to use when specifying database objects.
  [<Parameter(ParameterSetName = "LastInsertIdFunction"); Parameter(ParameterSetName = "SupportsReturningClause")>]
  [<ValidateNotNullOrWhiteSpace>]
  member val QuoteSuffix = "]" with get, set

  /// The string used as the schema separator.
  [<Parameter(ParameterSetName = "LastInsertIdFunction"); Parameter(ParameterSetName = "SupportsReturningClause")>]
  [<ValidateNotNullOrWhiteSpace>]
  member val SchemaSeparator = "." with get, set

  /// Value indicating whether the ADO.NET provider supports the `RETURNING` clause.
  [<Parameter(ParameterSetName = "SupportsReturningClause")>]
  member val SupportsReturningClause = SwitchParameter false with get, set

  /// Value indicating whether the ADO.NET provider uses positional parameters.
  [<Parameter(ParameterSetName = "LastInsertIdFunction"); Parameter(ParameterSetName = "SupportsReturningClause")>]
  member val UsePositionalParameters = SwitchParameter false with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    match this.ParameterSetName with
    | "Connection" -> this.WriteObject (SqlCommandBuilder.Create(nonNull this.Connection))
    | _ -> this.WriteObject (SqlCommandBuilder(
      CatalogLocation = this.CatalogLocation,
      CatalogSeparator = this.CatalogSeparator,
      LastInsertIdFunction = this.LastInsertIdFunction,
      ParameterPrefix = this.ParameterPrefix,
      QuotePrefix = this.QuotePrefix,
      QuoteSuffix = this.QuoteSuffix,
      SchemaSeparator = this.SchemaSeparator,
      SupportsReturningClause = this.SupportsReturningClause,
      UsePositionalParameters = this.UsePositionalParameters
    ))

/// Creates a new order hint.
[<Cmdlet(VerbsCommon.New, "OrderHint"); OutputType(typeof<SqlOrderHint>)>]
type NewOrderHint() =
  inherit Cmdlet()

  /// The name of the column for which the hint is being provided.
  [<Parameter(Mandatory = true, Position = 1, ValueFromPipeline = true)>]
  member val Column = "" with get, set

  /// The sort order of the column.
  [<Parameter(Position = 2)>]
  member val SortOrder = SortOrder.Ascending with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () = this.WriteObject (SqlOrderHint(this.Column, this.SortOrder))

/// Creates a new order hint collection.
[<Cmdlet(VerbsCommon.New, "OrderHintCollection"); OutputType(typeof<SqlOrderHintCollection>)>]
type NewOrderHintCollection() =
  inherit Cmdlet()

  /// The collection whose elements are copied to the order hint collection.
  [<Parameter(Position = 1, ValueFromPipeline = true); ValidateNotNull>]
  member val OrderHints: SqlOrderHint array = [||] with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    this.WriteObject(SqlOrderHintCollection this.OrderHints, enumerateCollection = false)

/// Creates a new parameter.
[<Cmdlet(VerbsCommon.New, "Parameter"); OutputType(typeof<SqlParameter>)>]
type NewParameter() =
  inherit Cmdlet()

  /// The parameter name.
  [<Parameter(Mandatory = true, Position = 1, ValueFromPipeline = true); AllowEmptyString>]
  member val Name = "" with get, set

  /// The parameter value.
  [<Parameter(Position = 2)>]
  member val Value: objnull = null with get, set

  /// Value indicating whether this parameter is input-only, output-only, bidirectional, or a stored procedure return value parameter.
  [<Parameter>]
  member val Direction = Nullable<ParameterDirection>() with get, set

  /// The database type of this parameter.
  [<Parameter>]
  member val DbType = Nullable<DbType>() with get, set

  /// The maximum size of this parameter, in bytes.
  [<Parameter>]
  member val Size = Nullable<int>() with get, set

  /// Indicates the precision of numeric parameters.
  [<Parameter>]
  member val Precision = Nullable<byte>() with get, set

  /// Indicates the scale of numeric parameters.
  [<Parameter>]
  member val Scale = Nullable<byte>() with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () = this.WriteObject (SqlParameter (
    this.Name,
    this.Value,
    DbType = this.DbType,
    Direction = this.Direction,
    Precision = this.Precision,
    Scale = this.Scale,
    Size = this.Size
  ))

/// Creates a new parameter collection.
[<Cmdlet(VerbsCommon.New, "ParameterCollection"); OutputType(typeof<SqlParameterCollection>)>]
type NewParameterCollection() =
  inherit Cmdlet()

  /// The collection whose elements are copied to the parameter collection.
  [<Parameter(Position = 1, ValueFromPipeline = true); ValidateNotNull>]
  member val Parameters: SqlParameter array = [||] with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    this.WriteObject(SqlParameterCollection this.Parameters, enumerateCollection = false)
