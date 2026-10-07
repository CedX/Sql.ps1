namespace Belin.Sql

open System
open System.Collections.Generic
open System.Data
open System.Management.Automation
open System.Runtime.CompilerServices

/// Executes a parameterized SQL query and returns the first row.
[<Cmdlet(VerbsCommon.Get, "First"); OutputType(typeof<obj>)>]
type GetFirst() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The command to be executed.
  [<Parameter(Mandatory = true, Position = 2)>]
  member val Command: SqlCommand | null = null with get, set

  /// The parameters of the SQL statement.
  [<Parameter(Position = 3)>]
  member val Parameters: SqlParameterCollection | null = null with get, set

  /// The type of objects to return.
  [<Parameter; ValidateNotNull>]
  member val As = typeof<PSObject> with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.Connection
    try this.WriteObject (connection.QueryFirst(this.As, nonNull this.Command, this.Parameters))
    with :? InvalidOperationException as ex ->
      this.WriteError (ErrorRecord(ex, "Connection.QueryFirst", ErrorCategory.InvalidOperation, connection))

/// Executes a parameterized SQL query that selects a single value.
[<Cmdlet(VerbsCommon.Get, "Scalar"); OutputType(typeof<objnull>)>]
type GetScalar() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The command to be executed.
  [<Parameter(Mandatory = true, Position = 2)>]
  member val Command: SqlCommand | null = null with get, set

  /// The parameters of the SQL statement.
  [<Parameter(Position = 3)>]
  member val Parameters: SqlParameterCollection | null = null with get, set

  /// The type of object to return.
  [<Parameter; ValidateNotNull>]
  member val As = typeof<objnull> with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.Connection
    this.WriteObject (connection.ExecuteScalar(this.As, nonNull this.Command, this.Parameters))

/// Executes a parameterized SQL query and returns the single row.
[<Cmdlet(VerbsCommon.Get, "Single"); OutputType(typeof<obj>)>]
type GetSingle() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The command to be executed.
  [<Parameter(Mandatory = true, Position = 2)>]
  member val Command: SqlCommand | null = null with get, set

  /// The parameters of the SQL statement.
  [<Parameter(Position = 3)>]
  member val Parameters: SqlParameterCollection | null = null with get, set

  /// The type of objects to return.
  [<Parameter; ValidateNotNull>]
  member val As = typeof<PSObject> with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.Connection
    try this.WriteObject (connection.QuerySingle(this.As, nonNull this.Command, this.Parameters))
    with :? InvalidOperationException as ex ->
      this.WriteError (ErrorRecord(ex, "Connection.QuerySingle", ErrorCategory.InvalidOperation, connection))

/// Executes a parameterized SQL statement.
/// Returns the number of rows affected.
[<Cmdlet(VerbsLifecycle.Invoke, "NonQuery"); OutputType(typeof<int>)>]
type InvokeNonQuery() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The command to be executed.
  [<Parameter(Mandatory = true, Position = 2)>]
  member val Command: SqlCommand | null = null with get, set

  /// The parameters of the SQL statement.
  [<Parameter(Position = 3)>]
  member val Parameters: SqlParameterCollection | null = null with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.Connection
    this.WriteObject (connection.Execute(nonNull this.Command, this.Parameters))

/// Executes a parameterized SQL query and returns a sequence of objects whose properties correspond to the columns.
[<Cmdlet(VerbsLifecycle.Invoke, "Query"); OutputType(typeof<obj>, typeof<ITuple>)>]
type InvokeQuery() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The command to be executed.
  [<Parameter(Mandatory = true, Position = 2)>]
  member val Command: SqlCommand | null = null with get, set

  /// The parameters of the SQL statement.
  [<Parameter(Position = 3)>]
  member val Parameters: SqlParameterCollection | null = null with get, set

  /// The type of objects to return.
  [<Parameter; ValidateCount(1, 7)>]
  member val As: Type array = [| typeof<PSObject> |] with get, set

  /// The fields from which to split and read the next objects.
  [<Parameter; ValidateCount(0, 6)>]
  member val SplitOn: string array = [||] with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.Connection
    match this.As.Length with
    | 1 -> this.WriteObject (connection.Query(this.As[0], nonNull this.Command, this.Parameters))
    | _ -> this.WriteObject (connection.Query(this.As, nonNull this.Command, this.Parameters, this.SplitOn))
