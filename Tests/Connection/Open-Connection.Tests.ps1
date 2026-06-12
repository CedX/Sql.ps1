using namespace System.Data
using namespace System.Data.SQLite
using assembly ../../Binaries/System.Data.SQLite.dll
using module ../../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `Open-Connection` cmdlet.
#>
Describe "Open-Connection" {
	It "should open the specified connection" {
		$connection = [SQLiteConnection]::new("DataSource=:memory:")
		$connection.State | Should -Be ([ConnectionState]::Closed)
		Open-SqlConnection $connection
		$connection.State | Should -Be ([ConnectionState]::Open)
		$connection.Close()
	}
}
