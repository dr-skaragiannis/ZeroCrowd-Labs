Get-CimInstance Win32_Process -Filter "Name='VBoxHeadless.exe'" | ForEach-Object {
  $cmd = $_.CommandLine
  if ($cmd.Length -gt 180) { $cmd = $cmd.Substring(0, 180) }
  "PID $($_.ProcessId) $cmd"
}
