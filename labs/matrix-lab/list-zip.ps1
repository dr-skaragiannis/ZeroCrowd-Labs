$path = "C:\Users\bloodraven\Projects\matrix-lab\Machine_Matrix.zip"
$item = Get-Item $path
Write-Output ("len=" + $item.Length)
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($path)
foreach ($e in $zip.Entries) {
  Write-Output ($e.FullName + " " + $e.Length)
}
$zip.Dispose()
