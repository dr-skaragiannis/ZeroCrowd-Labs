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
| 1 | 7.056 | 3.808 |
| 2 | 1.900 | 3.470 |
| 3 | 1.890 | 3.453 |
| 4 | 1.781 | 3.461 |
| 5 | 1.956 | 3.164 |
| Median | 1.900 | 3.461 |

The parity score for this replica is in `replica-parity.md`: 10 pass, 1 partial, 0 missing. The partial row is package versions. cron `3.0pl1-134+deb10u1` and anacron `2.3-28` match the guest. The archive revisions of apache2, OpenSSH, and sudo are newer.
