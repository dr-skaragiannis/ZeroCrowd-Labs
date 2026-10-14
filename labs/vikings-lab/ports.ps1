$procs = Get-CimInstance Win32_Process -Filter "Name='VBoxHeadless.exe'" | Where-Object { $_.CommandLine -match 'Vikings' }
$procs | ForEach-Object { "PID $($_.ProcessId)" }
$ids = @($procs | ForEach-Object { $_.ProcessId })
netstat -ano | ForEach-Object {
  foreach ($id in $ids) {
    if ($_ -match "\s$id$") { $_ }
  }
}
