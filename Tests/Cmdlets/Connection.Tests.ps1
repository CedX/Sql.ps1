using namespace System.Data
using assembly ../../Binaries/System.Data.SQLite.dll
using module ../../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `Close-SqlConnection` cmdlet.
#>
Describe "Close-SqlConnection" {
	It "should close the specified connection" {
		$connection = [System.Data.SQLite.SQLiteConnection] "DataSource=:memory:"
		$connection.Open()
		$connection.State | Should -Be ([ConnectionState]::Open)
		Close-SqlConnection $connection
		$connection.State | Should -Be ([ConnectionState]::Closed)
	}
}

<#
.SYNOPSIS
	Tests the features of the `New-SqlConnection` cmdlet.
#>
Describe "New-SqlConnection" {
	It "should create a connection of the specified type" -ForEach @(
		@{ Provider = [System.Data.SQLite.SQLiteConnection]; ConnectionString = "DataSource=:memory:"; Expected = [System.Data.SQLite.SQLiteConnection] }
		@{ Provider = "SqlClient"; ConnectionString = "Server=localhost; Database=TestDb; Uid=user; Pwd=password"; Expected = [System.Data.SqlClient.SqlConnection] }
	) {
		$connection = New-SqlConnection $provider $connectionString
		$connection | Should -BeOfType $expected
		$connection.State | Should -Be ([ConnectionState]::Closed)
		$connection.Dispose()
	}

	It "should open the newly created connection" {
		$connection = New-SqlConnection ([System.Data.SQLite.SQLiteConnection]) "DataSource=:memory:" -Open
		$connection.State | Should -Be ([ConnectionState]::Open)
		$connection.Close()
		$connection.State | Should -Be ([ConnectionState]::Closed)
	}
}
