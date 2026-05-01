using namespace System.Data.SQLite
using namespace System.Diagnostics.CodeAnalysis

$connection = [SQLiteConnection] "DataSource=:memory:"
$connection.Open()

$command = $connection.CreateCommand()
$command.CommandText = Get-Content "$PSScriptRoot/../../res/Schema.sql" -Raw
$command.ExecuteNonQuery() | Out-Null
$command.Dispose()
