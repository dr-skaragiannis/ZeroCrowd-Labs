$sentences = @(Get-Content -Path 'C:\Users\bloodraven\Projects\vikings-lab\experiment-sentences.txt' | Where-Object { $_.Trim() -ne '' })
$skills = @(
  'C:\Users\bloodraven\.cursor\skills\repairing-eol-apt-archives\SKILL.md',
  'C:\Users\bloodraven\.cursor\skills\building-docker-vm-replica\SKILL.md',
  'C:\Users\bloodraven\.cursor\skills\evaluating-docker-vm-parity\SKILL.md'
)
$replica = @(
  'C:\Users\bloodraven\Projects\necromancer-lab\replica\Dockerfile',
  'C:\Users\bloodraven\Projects\necromancer-lab\replica\compose.yaml',
  'C:\Users\bloodraven\Projects\necromancer-lab\replica\entrypoint.sh',
  'C:\Users\bloodraven\Projects\necromancer-lab\replica\supervisord.conf',
  'C:\Users\bloodraven\Projects\necromancer-lab\replica\nginx-site.conf',
  'C:\Users\bloodraven\Projects\necromancer-lab\replica\ifconfig-fmt',
  'C:\Users\bloodraven\Projects\necromancer-lab\replica\sudoers-replica',
  'C:\Users\bloodraven\Projects\necromancer-lab\vm-inventory.md',
  'C:\Users\bloodraven\Projects\necromancer-lab\replica-parity.md'
)
function Measure-Corpus([string[]]$files, [string[]]$needles) {
  $sw = [System.Diagnostics.Stopwatch]::StartNew()
  $text = (($files | ForEach-Object { Get-Content -Raw -Path $_ }) -join "`n")
  $found = 0
  foreach ($needle in $needles) {
    if ($text.Contains($needle)) { $found++ }
  }
  $sw.Stop()
  [pscustomobject]@{ Found = $found; Ms = [math]::Round($sw.Elapsed.TotalMilliseconds, 3) }
}
Write-Output ("sentences=" + $sentences.Count)
Write-Output ("skill_files=" + $skills.Count)
Write-Output ("replica_files=" + $replica.Count)
$skillMs = @()
$replicaMs = @()
$skillFound = 0
$replicaFound = 0
foreach ($i in 1..5) {
  $a = Measure-Corpus $skills $sentences
  $b = Measure-Corpus $replica $sentences
  $skillMs += $a.Ms
  $replicaMs += $b.Ms
  $skillFound = $a.Found
  $replicaFound = $b.Found
  Write-Output ("rep {0} skills {1} found {2} replica {3} found {4}" -f $i, $a.Ms, $a.Found, $b.Ms, $b.Found)
}
$sortedS = $skillMs | Sort-Object
$sortedR = $replicaMs | Sort-Object
Write-Output ("median_skills=" + $sortedS[2])
Write-Output ("median_replica=" + $sortedR[2])
Write-Output ("final_skills=" + $skillFound + "/" + $sentences.Count)
Write-Output ("final_replica=" + $replicaFound + "/" + $sentences.Count)
