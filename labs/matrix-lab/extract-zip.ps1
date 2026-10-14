Add-Type -AssemblyName System.IO.Compression.FileSystem
$src = "C:\Users\bloodraven\Projects\matrix-lab\Machine_Matrix.zip"
$dst = "C:\Users\bloodraven\Projects\matrix-lab"
[System.IO.Compression.ZipFile]::ExtractToDirectory($src, $dst)
Get-Item "C:\Users\bloodraven\Projects\matrix-lab\Machine_Matrix.ova" | ForEach-Object { Write-Output ("ova=" + $_.Length) }
