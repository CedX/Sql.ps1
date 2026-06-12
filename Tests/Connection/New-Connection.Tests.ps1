using namespace System.Data
using namespace System.Data.SQLite
using assembly ../../Binaries/System.Data.SQLite.dll
using module ../../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `New-Connection` cmdlet.
#>
Describe "New-Connection" {
	It "should create a connection of the specified type" -ForEach @(
		@{ Provider = [SQLiteConnection]; ConnectionString = "DataSource=:memory:"; Expected = [SQLiteConnection] }
		@{ Provider = "SqlClient"; ConnectionString = "Server=localhost; Database=TestDb; Uid=user; Pwd=password"; Expected = [System.Data.SqlClient.SqlConnection] }
	) {
		$connection = New-SqlConnection $provider $connectionString
		$connection | Should -BeOfType $expected
		$connection.State | Should -Be ([ConnectionState]::Closed)
	}

	It "should open the newly created connection" {
		$connection = New-SqlConnection ([SQLiteConnection]) "DataSource=:memory:" -Open
		$connection.State | Should -Be ([ConnectionState]::Open)
		$connection.Close()
		$connection.State | Should -Be ([ConnectionState]::Closed)
	}
}
