$client = New-Object System.Net.Sockets.TcpClient
$client.Connect("127.0.0.1", 2025)
$stream = $client.GetStream()
$stream.ReadTimeout = 1000
$enc = [System.Text.Encoding]::ASCII
1..3 | ForEach-Object {
  $b = $enc.GetBytes("`n")
  $stream.Write($b, 0, $b.Length)
  Start-Sleep -Milliseconds 300
}
$buf = New-Object byte[] 8192
$all = New-Object System.Collections.Generic.List[byte]
$end = (Get-Date).AddSeconds(20)
while ((Get-Date) -lt $end) {
  if ($stream.DataAvailable) {
    $n = $stream.Read($buf, 0, $buf.Length)
    for ($i = 0; $i -lt $n; $i++) { $all.Add($buf[$i]) }
  } else { Start-Sleep -Milliseconds 200 }
}
Write-Output ("BYTES=" + $all.Count)
if ($all.Count -gt 0) {
  $bytes = $all.ToArray()
  Write-Output ([System.Text.Encoding]::UTF8.GetString($bytes))
}
$client.Close()
