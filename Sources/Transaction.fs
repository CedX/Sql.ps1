namespace Belin.Sql

open System
open System.Data
open System.Management.Automation

/// Commits the specified transaction.
[<Cmdlet(VerbsLifecycle.Complete, "Transaction"); OutputType(typeof<Void>)>]
type CompleteTransaction() =
  inherit Cmdlet()

  /// The transaction to commit.
  [<Parameter(Mandatory = true, Position = 1, ValueFromPipeline = true)>]
  member val InputObject: IDbTransaction | null = null with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () = (nonNull this.InputObject).Commit()

/// Starts a new transaction.
[<Cmdlet(VerbsLifecycle.Start, "Transaction"); OutputType(typeof<IDbTransaction>)>]
type StartTransaction() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1)>]
  member val Connection: IDbConnection | null = null with get, set

  /// The isolation level for the transaction to use.
  [<Parameter(Position = 2)>]
  member val IsolationLevel = IsolationLevel.Unspecified with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () =
    let connection = nonNull this.Connection
    if connection.State = ConnectionState.Closed then connection.Open()
    this.WriteObject(connection.BeginTransaction this.IsolationLevel)

/// Rolls back the specified transaction.
[<Cmdlet(VerbsCommon.Undo, "Transaction"); OutputType(typeof<Void>)>]
type UndoTransaction() =
  inherit Cmdlet()

  /// The transaction to roll back.
  [<Parameter(Mandatory = true, Position = 1, ValueFromPipeline = true)>]
  member val InputObject: IDbTransaction | null = null with get, set

  /// Performs execution of this command.
  override this.ProcessRecord () = (nonNull this.InputObject).Rollback()
