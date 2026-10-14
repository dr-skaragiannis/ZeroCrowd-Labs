$path = "C:\Users\bloodraven\Projects\mrrobot-lab\mrRobot.ova"
$item = Get-Item $path
Write-Output ("len=" + $item.Length)
Write-Output ("attrs=" + $item.Attributes)
$fs = [System.IO.File]::Open($path, 'Open', 'Read', 'Read')
$buf = New-Object byte[] 128
$n = $fs.Read($buf, 0, 128)
$fs.Close()
Write-Output ("read=" + $n)
Write-Output ([System.BitConverter]::ToString($buf, 0, $n))
$text = [System.Text.Encoding]::ASCII.GetString($buf, 0, [Math]::Min(80, $n))
Write-Output $text
