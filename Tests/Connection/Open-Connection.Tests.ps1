using namespace System.Data
using assembly ../../Binaries/System.Data.SQLite.dll
using module ../../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `Open-Connection` cmdlet.
#>
Describe "Open-Connection" {
	It "should open the specified connection" {
		$connection = [System.Data.SQLite.SQLiteConnection]::new("DataSource=:memory:")
		Should-Be ([ConnectionState]::Closed) $connection.State
		Open-SqlConnection $connection
		Should-Be ([ConnectionState]::Open) $connection.State
		$connection.Close()
	}
}
