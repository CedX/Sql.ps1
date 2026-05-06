using namespace System.Data
using assembly ../../bin/System.Data.SQLite.dll

<#
.SYNOPSIS
	Tests the features of the `Close-Connection` cmdlet.
#>
Describe "Close-Connection" {
	BeforeAll {
		Import-Module "$PSScriptRoot/../../Sql.psd1"
	}

	It "should close the specified connection" {
		$connection = [System.Data.SQLite.SQLiteConnection] "DataSource=:memory:"
		$connection.Open()
		$connection.State | Should -Be ([ConnectionState]::Open)
		Close-SqlConnection $connection
		$connection.State | Should -Be ([ConnectionState]::Closed)
	}
}
