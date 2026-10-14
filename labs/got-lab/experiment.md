# Lookup experiment

Date: 13 October 2026. This is a text lookup, not a second agent and not a task time.

Twenty-three rule sentences were taken from the apt, build, and parity skills. A PowerShell script searched those three skill files, then the replica files that record the finished settings (`Dockerfile`, `compose.yaml`, `entrypoint.sh`, `nginx-1337.conf`, `nginx-10000.conf`, `winterfell.conf`, `sudoers-replica`, `vm-inventory.md`, `replica-parity.md`). The guest web tree and the shadow extract were not searched. Each condition was repeated five times with `System.Diagnostics.Stopwatch` in one process. Repetition 1 is the cold read. The median is the third value after sorting.

| Corpus | Files read | Sentences found | Sentences coded | Hit rate |
| --- | ---: | ---: | ---: | ---: |
| Three skills | 3 | 23 | 23 | 23/23 |
| Replica files | 9 | 1 | 23 | 1/23 |

The one replica-file hit is the apt assignment that disables `Check-Valid-Until`.

| Repetition | Skills (ms) | Replica files (ms) |
| --- | ---: | ---: |
| 1 | 14.616 | 4.43 |
| 2 | 1.829 | 4.211 |
| 3 | 1.732 | 4.284 |
| 4 | 1.878 | 4.298 |
| 5 | 1.874 | 4.253 |
| Median | 1.874 | 4.284 |

The parity score for this replica is in `replica-parity.md`: 7 pass, 4 partial, 0 missing. The partial rows are listening ports, package versions, web paths, and databases. fail2ban `0.9.6-2` matches the guest. The archive revisions of OpenSSH, sudo, and cron are newer.
