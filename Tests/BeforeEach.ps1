using assembly ../Binaries/System.Data.SQLite.dll

$connection = [System.Data.SQLite.SQLiteConnection]::new("DataSource=:memory:")
$connection.Open()

$command = $connection.CreateCommand()
$command.CommandText = Get-Content "$PSScriptRoot/../Resources/Schema.sql" -Raw
$command.ExecuteNonQuery() | Out-Null
$command.Dispose()
