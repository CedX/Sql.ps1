# Changelog

## Version [3.0.1](https://github.com/CedX/Sql.ps1/compare/v3.0.0...v3.0.1)
- Fixed the `New-SqlCommandBuilder` cmdlet when using the [SQL Server](https://www.microsoft.com/en-us/sql-server) provider.

## Version [3.0.0](https://github.com/CedX/Sql.ps1/compare/v2.0.1...v3.0.0)
- Breaking change: renamed the `Approve-SqlTransaction` cmdlet to `Complete-SqlTransaction`.
- Breaking change: renamed the `Deny-SqlTransaction` cmdlet to `Undo-SqlTransaction`.
- Breaking change: renamed the `New-SqlTransaction` cmdlet to `Start-SqlTransaction`.
- Added the `Measure-SqlObject` and `Open-SqlConnection` cmdlets.
- Replaced the [PowerShell](https://learn.microsoft.com/en-us/powershell) classes by [C#](https://learn.microsoft.com/en-us/dotnet/csharp) classes.
- Restored the module's `DefaultCommandPrefix`.

## Version [2.0.1](https://github.com/CedX/Sql.ps1/compare/v2.0.0...v2.0.1)
- Fixed the default value of the `SqlCommandBuilder.SupportsTruncateTable` property.

## Version [2.0.0](https://github.com/CedX/Sql.ps1/compare/v1.4.1...v2.0.0)
- Breaking change: renamed the `-Type` parameter of the `New-SqlConnection` cmdlet to `-Class`.
- Added the `-All`, `-Class` and `-Truncate` parameters to the `Remove-SqlObject` cmdlet.
- Added the `SqlCommandBuilder.GetDeleteAllCommand()` method.

## Version [1.4.1](https://github.com/CedX/Sql.ps1/compare/v1.4.0...v1.4.1)
- Fixed the `New-SqlTransaction` cmdlet, which did not automatically open the connection.

## Version [1.4.0](https://github.com/CedX/Sql.ps1/compare/v1.3.0...v1.4.0)
- Added the `-Dispose` parameter to the `Close-SqlConnection` cmdlet.
- Fixed the `DbColumnInfo` and `SqlMapper` classes when used in multiple runspaces.

## Version [1.3.0](https://github.com/CedX/Sql.ps1/compare/v1.2.0...v1.3.0)
- Added the `New-SqlCommandBuilder` cmdlet.
- Added the `-Builder` parameter to the `Find-SqlObject`, `Publish-SqlObject`, `Remove-SqlObject`, `Test-SqlObject` and `Update-SqlObject` cmdlets.
- Disabled the runspace affinity of all classes.

## Version [1.2.0](https://github.com/CedX/Sql.ps1/compare/v1.1.0...v1.2.0)
- Added the `-Provider` parameter to the `New-SqlConnection` cmdlet.

## Version [1.1.0](https://github.com/CedX/Sql.ps1/compare/v1.0.2...v1.1.0)
- Added the `New-SqlOrderHint` and `New-SqlOrderHintCollection` cmdlets.
- Added the `-All` and `-OrderBy` parameters to the `Find-SqlObject` cmdlet.
- Removed the module's `DefaultCommandPrefix` in favor of a hard-coded command prefix.

## Version [1.0.2](https://github.com/CedX/Sql.ps1/compare/v1.0.1...v1.0.2)
- Fixed the enumeration of columns in the `DbTableInfo` constructor.

## Version [1.0.1](https://github.com/CedX/Sql.ps1/compare/v1.0.0...v1.0.1)
- Fixed the handling of `$null` values in the `[SqlMapper]::CreateInstance()` method.

## Version 1.0.0
- Initial release.
