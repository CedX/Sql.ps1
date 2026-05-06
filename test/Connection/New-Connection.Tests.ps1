using namespace System.Data
using assembly ../../bin/System.Data.SQLite.dll

<#
.SYNOPSIS
	Tests the features of the `New-Connection` cmdlet.
#>
Describe "New-Connection" {
	BeforeAll {
		Import-Module "$PSScriptRoot/../../Sql.psd1"
	}

	It "should create a connection of the specified type" {
		$connection = New-SqlConnection ([System.Data.SQLite.SQLiteConnection]) "DataSource=:memory:"
		$connection | Should -BeOfType ([System.Data.SQLite.SQLiteConnection])
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
