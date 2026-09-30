namespace Belin.Sql

open System.Data
open System.Data.Common
open System.Management.Automation

/// Closes the specified database connection.
[<Cmdlet(VerbsCommon.Close, "Connection")>]
[<OutputType(typeof<unit>)>]
type CloseConnectionCommand() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1, ValueFromPipeline = true)>]
  member val InputObject: IDbConnection|null = null with get, set

  /// Value indicating whether the connection should also be disposed.
  [<Parameter>]
  member val Dispose = SwitchParameter false with get, set

  /// Performs execution of this command.
  override this.ProcessRecord() =
    let connection = nonNull this.InputObject
    try
      try connection.Close()
      with :? DbException as ex ->
        this.WriteError (ErrorRecord(ex, "Db", ErrorCategory.CloseError, this.InputObject))
    finally
      if this.Dispose.IsPresent then connection.Dispose()

/// Opens the specified database connection.
[<Cmdlet(VerbsCommon.Open, "Connection")>]
[<OutputType(typeof<unit>)>]
type OpenConnectionCommand() =
  inherit Cmdlet()

  /// The connection to the data source.
  [<Parameter(Mandatory = true, Position = 1, ValueFromPipeline = true)>]
  member val InputObject: IDbConnection|null = null with get, set

  /// Value indicating whether the connection should also be disposed.
  [<Parameter>]
  member val Dispose = SwitchParameter false with get, set

  /// Performs execution of this command.
  override this.ProcessRecord() = (nonNull this.InputObject).Open()
