# Changelog

## Version [1.1.0](https://github.com/cedx/sql.ps1/compare/v1.0.2...v1.1.0)
- Added the `New-SqlOrderHint` and `New-SqlOrderHintCollection` cmdlets.
- Added the `-All` and `-OrderBy` parameters to the `Find-SqlObject` cmdlet.
- Removed the module's `DefaultCommandPrefix` in favor of a hard-coded command prefix.

## Version [1.0.2](https://github.com/cedx/sql.ps1/compare/v1.0.1...v1.0.2)
- Fixed the enumeration of columns in the `[DbTableInfo]` constructor.

## Version [1.0.1](https://github.com/cedx/sql.ps1/compare/v1.0.0...v1.0.1)
- Fixed the handling of `$null` values in the `[SqlMapper]::CreateInstance()` method.

## Version 1.0.0
- Initial release.
