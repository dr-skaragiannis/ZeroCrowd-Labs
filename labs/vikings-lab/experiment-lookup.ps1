$sentences = Get-Content -Encoding UTF8 "C:\Users\bloodraven\Projects\vikings-lab\experiment-sentences.txt" | Where-Object { $_.Trim().Length -gt 0 }
$skillFiles = @(
  "C:\Users\bloodraven\.cursor\skills\repairing-eol-apt-archives\SKILL.md",
  "C:\Users\bloodraven\.cursor\skills\building-docker-vm-replica\SKILL.md",
  "C:\Users\bloodraven\.cursor\skills\evaluating-docker-vm-parity\SKILL.md"
)
$replicaFiles = @(
  "C:\Users\bloodraven\Projects\vikings-lab\replica\Dockerfile",
  "C:\Users\bloodraven\Projects\vikings-lab\replica\compose.yaml",
  "C:\Users\bloodraven\Projects\vikings-lab\replica\entrypoint.sh",
  "C:\Users\bloodraven\Projects\vikings-lab\replica\supervisord.conf",
  "C:\Users\bloodraven\Projects\vikings-lab\vm-inventory.md",
  "C:\Users\bloodraven\Projects\vikings-lab\replica-parity.md"
)
function Read-Corpus($files) {
  $text = ""
  foreach ($f in $files) { $text += [IO.File]::ReadAllText($f) }
  return $text
}
$skillHits = 0
$replicaHitSentences = @()
$missing = @()
foreach ($s in $sentences) {
  $inSkill = $false
  foreach ($f in $skillFiles) {
    if ([IO.File]::ReadAllText($f).Contains($s)) { $inSkill = $true; break }
  }
  if ($inSkill) { $skillHits++ } else { $missing += $s }
  foreach ($f in $replicaFiles) {
    if ([IO.File]::ReadAllText($f).Contains($s)) { $replicaHitSentences += $s; break }
  }
}
Write-Output ("SENTENCES " + $sentences.Count)
Write-Output ("SKILL_HITS " + $skillHits)
Write-Output ("REPLICA_HITS " + $replicaHitSentences.Count)
foreach ($m in $missing) { Write-Output ("MISSING_SKILL " + $m) }
foreach ($h in $replicaHitSentences) { Write-Output ("REPLICA_HIT " + $h) }
$sw = New-Object System.Diagnostics.Stopwatch
foreach ($rep in 1..5) {
  $sw.Restart()
  $corpus = Read-Corpus $skillFiles
  $n = 0
  foreach ($s in $sentences) { if ($corpus.Contains($s)) { $n++ } }
  $sw.Stop()
  $skillMs = $sw.Elapsed.TotalMilliseconds
  $sw.Restart()
  $corpus = Read-Corpus $replicaFiles
  $n2 = 0
  foreach ($s in $sentences) { if ($corpus.Contains($s)) { $n2++ } }
  $sw.Stop()
  $replicaMs = $sw.Elapsed.TotalMilliseconds
  Write-Output ("REP {0} skills {1:N3} replica {2:N3} hits {3}/{4}" -f $rep, $skillMs, $replicaMs, $n, $n2)
}
