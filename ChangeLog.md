# Changelog

## Version [3.2.2](https://github.com/CedX/Sql.ps1/compare/v3.2.1...v3.2.2)
- Optimized the packaging.

## Version [3.2.1](https://github.com/CedX/Sql.ps1/compare/v3.2.0...v3.2.1)
- Fixed a packaging issue.

## Version [3.2.0](https://github.com/CedX/Sql.ps1/compare/v3.1.0...v3.2.0)
- Updated the package dependencies.

## Version [3.1.0](https://github.com/CedX/Sql.ps1/compare/v3.0.3...v3.1.0)
- Added support for SQL parameter values wrapped in `[PSObject]` instances.

## Version [3.0.3](https://github.com/CedX/Sql.ps1/compare/v3.0.2...v3.0.3)
- Fixed the `(Get-Mapper).ChangeType()` method when the value to convert is `DBNull.Value`.

## Version [3.0.2](https://github.com/CedX/Sql.ps1/compare/v3.0.1...v3.0.2)
- Fixed the `Get-Scalar` cmdlet when using a nullable type or a reference type as target type.

## Version [3.0.1](https://github.com/CedX/Sql.ps1/compare/v3.0.0...v3.0.1)
- Fixed the `New-CommandBuilder` cmdlet when using the [SQL Server](https://www.microsoft.com/en-us/sql-server) provider.

## Version [3.0.0](https://github.com/CedX/Sql.ps1/compare/v2.0.1...v3.0.0)
- Breaking change: renamed the `Approve-Transaction` cmdlet to `Complete-Transaction`.
- Breaking change: renamed the `Deny-Transaction` cmdlet to `Undo-Transaction`.
- Breaking change: renamed the `New-Transaction` cmdlet to `Start-Transaction`.
- Added the `Measure-Object` and `Open-Connection` cmdlets.
- Replaced the [PowerShell](https://learn.microsoft.com/en-us/powershell) classes by [C#](https://learn.microsoft.com/en-us/dotnet/csharp) classes.
- Restored the module's `DefaultCommandPrefix`.

## Version [2.0.1](https://github.com/CedX/Sql.ps1/compare/v2.0.0...v2.0.1)
- Fixed the default value of the `SqlCommandBuilder.SupportsTruncateTable` property.

## Version [2.0.0](https://github.com/CedX/Sql.ps1/compare/v1.4.1...v2.0.0)
- Breaking change: renamed the `-Type` parameter of the `New-Connection` cmdlet to `-Class`.
- Added the `-All`, `-Class` and `-Truncate` parameters to the `Remove-Object` cmdlet.
- Added the `SqlCommandBuilder.GetDeleteAllCommand()` method.

## Version [1.4.1](https://github.com/CedX/Sql.ps1/compare/v1.4.0...v1.4.1)
- Fixed the `New-Transaction` cmdlet, which did not automatically open the connection.

## Version [1.4.0](https://github.com/CedX/Sql.ps1/compare/v1.3.0...v1.4.0)
- Added the `-Dispose` parameter to the `Close-Connection` cmdlet.
- Fixed the `DbColumnInfo` and `SqlMapper` classes when used in multiple runspaces.

## Version [1.3.0](https://github.com/CedX/Sql.ps1/compare/v1.2.0...v1.3.0)
- Added the `New-CommandBuilder` cmdlet.
- Added the `-Builder` parameter to the `Find-Object`, `Publish-Object`, `Remove-Object`, `Test-Object` and `Update-Object` cmdlets.
- Disabled the runspace affinity of all classes.

## Version [1.2.0](https://github.com/CedX/Sql.ps1/compare/v1.1.0...v1.2.0)
- Added the `-Provider` parameter to the `New-Connection` cmdlet.

## Version [1.1.0](https://github.com/CedX/Sql.ps1/compare/v1.0.2...v1.1.0)
- Added the `New-OrderHint` and `New-OrderHintCollection` cmdlets.
- Added the `-All` and `-OrderBy` parameters to the `Find-Object` cmdlet.
- Removed the module's `DefaultCommandPrefix` in favor of a hard-coded command prefix.

## Version [1.0.2](https://github.com/CedX/Sql.ps1/compare/v1.0.1...v1.0.2)
- Fixed the enumeration of columns in the `DbTableInfo` constructor.

## Version [1.0.1](https://github.com/CedX/Sql.ps1/compare/v1.0.0...v1.0.1)
- Fixed the handling of `$null` values in the `[SqlMapper]::CreateInstance()` method.

## Version 1.0.0
- Initial release.
