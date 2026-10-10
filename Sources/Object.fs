namespace Belin.Sql

open System
open System.Data
open System.Management.Automation

/// Finds either an entity with the specified primary key, or all entities.
[<Cmdlet(VerbsCommon.Find, "Object", DefaultParameterSetName = "Id"); OutputType(typeof<obj>)>]
type FindObject() =
  inherit PSCmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The type of object to find.
  [<Parameter(Mandatory = true, Position = 2)>]
  member val Class = typeof<obj> with get, set

  /// The primary key value.
  [<Parameter(Mandatory = true, ParameterSetName = "Id", Position = 3, ValueFromPipeline = true)>]
  member val Id = Object() with get, set

  /// Value indicating whether to find all entities.
  [<Parameter(ParameterSetName = "All")>]
  member val All = SwitchParameter false with get, set

  /// The hints describing the sort order of columns.
  [<Parameter(ParameterSetName = "All")>]
  member val OrderBy = SqlOrderHintCollection [||] with get, set

  /// Value indicating whether to prevent this cmdlet from enumerating its output.
  [<Parameter(ParameterSetName = "All")>]
  member val NoEnumerate = SwitchParameter false with get, set

  /// An optional command builder used to build the SQL query to be executed.
  [<Parameter>]
  member val Builder: SqlCommandBuilder | null = null with get, set

  /// The list of columns to select. By default, all columns.
  [<Parameter; ValidateNotNull>]
  member val Columns: string array = [||] with get, set

  /// The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
  [<Parameter; ValidateRange(ValidateRangeKind.NonNegative)>]
  member val Timeout = 30 with get, set

  /// The transaction within which the command executes.
  [<Parameter>]
  member val Transaction: IDbTransaction | null = null with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.Connection
    let enumerateCollection = not this.NoEnumerate.IsPresent
    match this.ParameterSetName with
    | "All" -> this.WriteObject(connection.FindAll(this.Class, this.OrderBy, this.Columns, this.Timeout, this.Transaction, this.Builder), enumerateCollection)
    | _ -> this.WriteObject(connection.Find(this.Class, this.Id, this.Columns, this.Timeout, this.Transaction, this.Builder))

/// Counts all entities.
[<Cmdlet(VerbsDiagnostic.Measure, "Object"); OutputType(typeof<int>)>]
type MeasureObject() =
  inherit PSCmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The type of object to count.
  [<Parameter(Mandatory = true, Position = 2, ValueFromPipeline = true)>]
  member val Class = typeof<obj> with get, set

  /// Value indicating whether to count all entities.
  [<Parameter(Mandatory = true, ParameterSetName = "All")>]
  member val All = SwitchParameter false with get, set

  /// An optional command builder used to build the SQL query to be executed.
  [<Parameter>]
  member val Builder: SqlCommandBuilder | null = null with get, set

  /// The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
  [<Parameter; ValidateRange(ValidateRangeKind.NonNegative)>]
  member val Timeout = 30 with get, set

  /// The transaction within which the command executes.
  [<Parameter>]
  member val Transaction: IDbTransaction | null = null with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.Connection
    this.WriteObject(connection.CountAll(this.Class, this.Timeout, this.Transaction, this.Builder))

/// Inserts the specified entity.
/// Returns the generated primary key value.
[<Cmdlet(VerbsData.Publish, "Object"); OutputType(typeof<int64>)>]
type PublishObject() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The entity to insert.
  [<Parameter(Mandatory = true, Position = 2, ValueFromPipeline = true)>]
  member val InputObject = Object() with get, set

  /// An optional command builder used to build the SQL query to be executed.
  [<Parameter>]
  member val Builder: SqlCommandBuilder | null = null with get, set

  /// The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
  [<Parameter; ValidateRange(ValidateRangeKind.NonNegative)>]
  member val Timeout = 30 with get, set

  /// The transaction within which the command executes.
  [<Parameter>]
  member val Transaction: IDbTransaction | null = null with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.Connection
    let inputObject = match this.InputObject with :? PSObject as object -> object.BaseObject | value -> value
    this.WriteObject(connection.Insert(inputObject, this.Timeout, this.Transaction, this.Builder))

/// Deletes either the specified entity, or all entities.
/// Returns `true` if the specified entity has been deleted, otherwise `false`.
/// Returns nothing when the command has been invoked with the `-All` parameter.
[<Cmdlet(VerbsCommon.Remove, "Object", DefaultParameterSetName = "InputObject")>]
[<OutputType(typeof<bool>, ParameterSetName = [| "InputObject" |]); OutputType(typeof<Void>, ParameterSetName = [| "All" |])>]
type RemoveObject() =
  inherit PSCmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The entity to delete.
  [<Parameter(Mandatory = true, ParameterSetName = "InputObject", Position = 2, ValueFromPipeline = true)>]
  member val InputObject = Object() with get, set

  /// The type of object to delete.
  [<Parameter(Mandatory = true, ParameterSetName = "All", Position = 2)>]
  member val Class = typeof<obj> with get, set

  /// Value indicating whether to delete all entities.
  [<Parameter(ParameterSetName = "All")>]
  member val All = SwitchParameter false with get, set

  /// Value indicating whether to truncate the underlying table.
  [<Parameter(ParameterSetName = "All")>]
  member val Truncate = SwitchParameter false with get, set

  /// An optional command builder used to build the SQL query to be executed.
  [<Parameter>]
  member val Builder: SqlCommandBuilder | null = null with get, set

  /// The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
  [<Parameter; ValidateRange(ValidateRangeKind.NonNegative)>]
  member val Timeout = 30 with get, set

  /// The transaction within which the command executes.
  [<Parameter>]
  member val Transaction: IDbTransaction | null = null with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.Connection
    let inputObject = match this.InputObject with :? PSObject as object -> object.BaseObject | value -> value
    match this.ParameterSetName with
    | "All" -> connection.DeleteAll(this.Class, this.Truncate.IsPresent, this.Timeout, this.Transaction, this.Builder)
    | _ -> this.WriteObject(connection.Delete(inputObject, this.Timeout, this.Transaction, this.Builder))

/// Checks whether an entity with the specified primary key exists.
/// Returns `true` if an entity with the specified primary key exists, otherwise `false`.
[<Cmdlet(VerbsDiagnostic.Test, "Object"); OutputType(typeof<bool>)>]
type TestObject() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The type of object to check.
  [<Parameter(Mandatory = true, Position = 2)>]
  member val Class = typeof<obj> with get, set

  /// The primary key value.
  [<Parameter(Mandatory = true, Position = 3, ValueFromPipeline = true)>]
  member val Id = Object() with get, set

  /// An optional command builder used to build the SQL query to be executed.
  [<Parameter>]
  member val Builder: SqlCommandBuilder | null = null with get, set

  /// The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
  [<Parameter; ValidateRange(ValidateRangeKind.NonNegative)>]
  member val Timeout = 30 with get, set

  /// The transaction within which the command executes.
  [<Parameter>]
  member val Transaction: IDbTransaction | null = null with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.Connection
    this.WriteObject(connection.Exists(this.Class, this.Id, this.Timeout, this.Transaction, this.Builder))

/// Updates the specified entity.
/// Returns the number of rows affected.
[<Cmdlet(VerbsData.Update, "Object"); OutputType(typeof<int>)>]
type UpdateObject() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The entity to update.
  [<Parameter(Mandatory = true, Position = 2, ValueFromPipeline = true)>]
  member val InputObject = Object() with get, set

  /// An optional command builder used to build the SQL query to be executed.
  [<Parameter>]
  member val Builder: SqlCommandBuilder | null = null with get, set

  /// The list of columns to update. By default, all columns.
  [<Parameter; ValidateNotNull>]
  member val Columns: string array = [||] with get, set

  /// The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
  [<Parameter; ValidateRange(ValidateRangeKind.NonNegative)>]
  member val Timeout = 30 with get, set

  /// The transaction within which the command executes.
  [<Parameter>]
  member val Transaction: IDbTransaction | null = null with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.Connection
    let inputObject = match this.InputObject with :? PSObject as object -> object.BaseObject | value -> value
    this.WriteObject(connection.Update(inputObject, this.Columns, this.Timeout, this.Transaction, this.Builder))
