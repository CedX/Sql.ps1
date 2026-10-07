namespace Belin.Sql

open System.Management.Automation

/// Gets the singleton instance of the data mapper.
[<Cmdlet(VerbsCommon.Get, "Mapper"); OutputType(typeof<SqlMapper>)>]
type GetMapper() =
  inherit Cmdlet()

  /// Performs execution of this command.
  override this.ProcessRecord () = this.WriteObject SqlMapper.Instance
