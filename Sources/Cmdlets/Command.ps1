using namespace System.Data
using namespace System.Diagnostics.CodeAnalysis
using module ../SortOrder.psm1
using module ../SqlCommand.psm1
using module ../SqlOrderHint.psm1
using module ../SqlOrderHintCollection.psm1
using module ../SqlParameter.psm1
using module ../SqlParameterCollection.psm1

<#
.SYNOPSIS
	Creates a new command.
.OUTPUTS
	The newly created command.
#>
function New-SqlCommand {
	[CmdletBinding()]
	[OutputType([SqlCommand])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The text of the SQL statement.
		[Parameter(Mandatory, Position = 0, ValueFromPipeline)]
		[string] $Text,

		# The wait time, in seconds, before terminating the attempt to execute the command and generating an error.
		[ValidateRange("NonNegative")]
		[int] $Timeout = 30,

		# The transaction within which the command executes.
		[IDbTransaction] $Transaction,

		# Value indicating how the command is interpreted.
		[CommandType] $Type = [CommandType]::Text
	)

	process {
		$command = [SqlCommand]::new($Text)
		$command.Timeout = $Timeout
		$command.Transaction = $Transaction
		$command.Type = $Type
		$command
	}
}

<#
.SYNOPSIS
	Creates a new order hint.
.OUTPUTS
	The newly created order hint.
#>
function New-SqlOrderHint {
	[CmdletBinding()]
	[OutputType([SqlOrderHint])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The name of the column for which the hint is being provided.
		[Parameter(Mandatory, Position = 0, ValueFromPipeline)]
		[string] $Column,

		# The sort order of the column.
		[Parameter(Position = 1)]
		[SortOrder] $SortOrder = [SortOrder]::Ascending
	)

	process {
		[SqlOrderHint]::new($Column, $SortOrder)
	}
}

<#
.SYNOPSIS
	Creates a new order hint collection.
.OUTPUTS
	The newly created order hint collection.
#>
function New-SqlOrderHintCollection {
	[CmdletBinding()]
	[OutputType([SqlOrderHintCollection])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The collection whose elements are copied to the order hint collection.
		[Parameter(Position = 0, ValueFromPipeline)]
		[ValidateNotNull()]
		[SqlOrderHint[]] $OrderHints = @()
	)

	process {
		[SqlOrderHintCollection]::new($OrderHints)
	}
}

<#
.SYNOPSIS
	Creates a new parameter.
.OUTPUTS
	The newly created parameter.
#>
function New-SqlParameter {
	[CmdletBinding()]
	[OutputType([SqlParameter])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The parameter name.
		[Parameter(Mandatory, Position = 0, ValueFromPipeline)]
		[AllowEmptyString()]
		[string] $Name,

		# The parameter value.
		[Parameter(Position = 1)]
		[object] $Value,

		# Value indicating whether this parameter is input-only, output-only, bidirectional, or a stored procedure return value parameter.
		[Nullable[ParameterDirection]] $Direction,

		# The database type of this parameter.
		[Nullable[DbType]] $DbType,

		# The maximum size of this parameter, in bytes.
		[Nullable[int]] $Size,

		# Indicates the precision of numeric parameters.
		[Nullable[byte]] $Precision,

		# Indicates the scale of numeric parameters.
		[Nullable[byte]] $Scale
	)

	process {
		$parameter = [SqlParameter]::new($Name, $Value)
		$parameter.DbType = $DbType
		$parameter.Direction = $Direction
		$parameter.Precision = $Precision
		$parameter.Scale = $Scale
		$parameter.Size = $Size
		$parameter
	}
}

<#
.SYNOPSIS
	Creates a new parameter collection.
.OUTPUTS
	The newly created parameter collection.
#>
function New-SqlParameterCollection {
	[CmdletBinding()]
	[OutputType([SqlParameterCollection])]
	[SuppressMessage("PSUseShouldProcessForStateChangingFunctions", "")]
	param (
		# The collection whose elements are copied to the parameter collection.
		[Parameter(Position = 0, ValueFromPipeline)]
		[ValidateNotNull()]
		[SqlParameter[]] $Parameters = @()
	)

	process {
		[SqlParameterCollection]::new($Parameters)
	}
}
