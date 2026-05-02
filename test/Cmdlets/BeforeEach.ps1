using assembly ../../bin/System.Data.SQLite.dll

$connection = [System.Data.SQLite.SQLiteConnection] "DataSource=:memory:"
$connection.Open()

$command = $connection.CreateCommand()
$command.CommandText = Get-Content "$PSScriptRoot/../../res/Schema.sql" -Raw
$command.ExecuteNonQuery() | Out-Null
$command.Dispose()
