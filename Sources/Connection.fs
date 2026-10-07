namespace Belin.Sql

open System
open System.Data
open System.Data.Common
open System.Management.Automation

/// Closes the specified database connection.
[<Cmdlet(VerbsCommon.Close, "Connection"); OutputType(typeof<Void>)>]
type CloseConnection() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1, ValueFromPipeline = true)>]
  member val InputObject: IDbConnection | null = null with get, set

  /// Value indicating whether the connection should also be disposed.
  [<Parameter>]
  member val Dispose = SwitchParameter false with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.InputObject
    try
      try connection.Close()
      with :? DbException as ex -> this.WriteError (ErrorRecord(ex, "Connection.Close", ErrorCategory.CloseError, connection))
    finally
      if this.Dispose.IsPresent then connection.Dispose()

/// Creates a new database connection.
[<Cmdlet(VerbsCommon.New, "Connection", DefaultParameterSetName = "Class"); OutputType(typeof<IDbConnection>)>]
type NewConnection() =
  inherit PSCmdlet()

  /// The type of connection class to instantiate.
  [<Parameter(Mandatory = true, ParameterSetName = "Class", Position = 1)>]
  member val Class = typeof<IDbConnection> with get, set

  /// The name of an ADO.NET provider.
  [<Parameter(Mandatory = true, ParameterSetName = "Provider", Position = 1)>]
  [<ValidateSet("Odbc", "OleDb", "SqlClient")>]
  member val Provider = "SqlClient" with get, set

  /// The connection string used to open the database.
  [<Parameter(Mandatory = true, Position = 2, ValueFromPipeline = true)>]
  member val ConnectionString = "" with get, set

  /// Value indicating whether to open the connection.
  [<Parameter>]
  member val Open = SwitchParameter false with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connectionType =
      match this.ParameterSetName with
      | "Provider" ->
        match this.Provider with
        | "Odbc" -> typeof<Odbc.OdbcConnection>
        | "OleDb" -> typeof<OleDb.OleDbConnection>
        | _ -> typeof<SqlClient.SqlConnection>
      | _ -> this.Class

    let errorCategory = ErrorCategory.InvalidType
    let errorId = "Activator.CreateInstance"
    let errorMessage = "The specified connection type is not supported."

    try
      match Activator.CreateInstance(connectionType, this.ConnectionString) with
      | :? IDbConnection as connection ->
        if this.Open.IsPresent then connection.Open()
        this.WriteObject connection
      | _ -> this.ThrowTerminatingError (ErrorRecord(ArgumentException errorMessage, errorId, errorCategory, connectionType))
    with ex ->
      this.ThrowTerminatingError (ErrorRecord(ArgumentException(errorMessage, ex), errorId, errorCategory, connectionType))

/// Opens the specified database connection.
[<Cmdlet(VerbsCommon.Open, "Connection"); OutputType(typeof<Void>)>]
type OpenConnection() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1, ValueFromPipeline = true)>]
  member val InputObject: IDbConnection | null = null with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.InputObject
    try connection.Open()
    with :? DbException as ex -> this.WriteError (ErrorRecord(ex, "Connection.Open", ErrorCategory.OpenError, connection))
