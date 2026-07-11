using namespace System.Data
using assembly ../../Binaries/System.Data.SQLite.dll
using module ../../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `Close-Connection` cmdlet.
#>
Describe "Close-Connection" {
	It "should close the specified connection" {
		$connection = [System.Data.SQLite.SQLiteConnection]::new("DataSource=:memory:")
		$connection.Open()
		Should-Be ([ConnectionState]::Open) $connection.State
		Close-SqlConnection $connection
		Should-Be ([ConnectionState]::Closed) $connection.State
	}
}
