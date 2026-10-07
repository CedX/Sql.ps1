using assembly ../Binaries/System.Data.SQLite.dll
using namespace System.Data
using module ../Sql.psd1

<#
.SYNOPSIS
	Tests the features of the `Close-Connection` cmdlet.
#>
Describe "Close-Connection" {
	It "should close the specified connection" {
		$connection = [System.Data.SQLite.SQLiteConnection]::new("DataSource=:memory:")
		$connection.Open()
		$connection.State | Should-Be ([System.Data.ConnectionState]::Open)
		$connection | Close-SqlConnection
		$connection.State | Should-Be ([System.Data.ConnectionState]::Closed)
		$connection.Dispose()
	}
}

<#
.SYNOPSIS
	Tests the features of the `New-Connection` cmdlet.
#>
Describe "New-Connection" {
	It "should create a connection of the specified type" -ForEach @(
		@{ Provider = [System.Data.SQLite.SQLiteConnection]; ConnectionString = "DataSource=:memory:"; Expected = [System.Data.SQLite.SQLiteConnection] }
		@{ Provider = "SqlClient"; ConnectionString = "Server=localhost; Database=TestDb; Uid=user; Pwd=password"; Expected = [System.Data.SqlClient.SqlConnection] }
	) {
		$connection = New-SqlConnection $provider $connectionString
		$connection | Should-HaveType $expected
		$connection.State | Should-Be ([ConnectionState]::Closed)
		$connection.Dispose()
	}

	It "should open the newly created connection" {
		$connection = New-SqlConnection ([System.Data.SQLite.SQLiteConnection]) "DataSource=:memory:" -Open
		$connection.State | Should-Be ([ConnectionState]::Open)
		$connection.Dispose()
	}
}

<#
.SYNOPSIS
	Tests the features of the `Open-Connection` cmdlet.
#>
Describe "Open-Connection" {
	It "should open the specified connection" {
		$connection = [System.Data.SQLite.SQLiteConnection]::new("DataSource=:memory:")
		$connection.State | Should-Be ([System.Data.ConnectionState]::Closed)
		$connection | Open-SqlConnection
		$connection.State | Should-Be ([System.Data.ConnectionState]::Open)
		$connection.Dispose()
	}
}
