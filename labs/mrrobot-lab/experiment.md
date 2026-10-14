# Lookup experiment

Date: 13 October 2026. This is a text lookup, not a second agent and not a task time.

Twenty-three rule sentences were taken from the apt, build, and parity skills. A PowerShell script searched those three skill files, then the replica files that record the finished settings (`Dockerfile`, `compose.yaml`, `entrypoint.sh`, `supervisord.conf`, `sudoers-replica`, `vm-inventory.md`, `replica-parity.md`). The guest web tree and the shadow extract were not searched. Each condition was repeated five times with `System.Diagnostics.Stopwatch` in one process. Repetition 1 is the cold read. The median is the third value after sorting.

| Corpus | Files read | Sentences found | Sentences coded | Hit rate |
| --- | ---: | ---: | ---: | ---: |
| Three skills | 3 | 23 | 23 | 23/23 |
| Replica files | 7 | 1 | 23 | 1/23 |

The one replica-file hit is the apt assignment that disables `Check-Valid-Until`.

| Repetition | Skills (ms) | Replica files (ms) |
| --- | ---: | ---: |
| 1 | 8.241 | 4.239 |
| 2 | 2.171 | 3.871 |
| 3 | 2.118 | 4.171 |
| 4 | 2.129 | 4.050 |
| 5 | 2.075 | 3.960 |
| Median | 2.129 | 4.050 |

The parity score for this replica is in `replica-parity.md`: 8 pass, 3 partial, 0 missing. The partial rows are package versions, users, and the application URL. cron `3.0pl1-124ubuntu2` and vsftpd `3.0.2-1ubuntu2.14.04.1` match the guest. The archive revisions of OpenSSH and sudo are newer.
