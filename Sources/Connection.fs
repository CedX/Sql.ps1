namespace Belin.Sql

open System.Data
open System.Management.Automation

/// Closes the specified database connection.
[<Cmdlet(VerbsCommon.Close, "Connection")>]
[<OutputType(typeof<unit>)>]
type NewConnectionCommand() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1, ValueFromPipeline = true)>]
  member val InputObject: IDbConnection|null = null with get, set

  /// Value indicating whether the connection should also be disposed.
  [<Parameter>]
  member val Dispose = SwitchParameter false with get, set

  /// Performs execution of this command.
  override this.ProcessRecord() =
    // try this.InputObject.Close()
    // catch this.WriteError "TODO"
    // finally { if this.Dispose then this.InputObject.Dispose() }
    ()
