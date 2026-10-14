# Lookup experiment

Date: 13 October 2026. This is a text lookup, not a second agent and not a task time.

Twenty-three rule sentences were taken from the apt, build, and parity skills. A PowerShell script searched those three skill files, then the replica files that record the finished settings (`Dockerfile`, `compose.yaml`, `entrypoint.sh`, `supervisord.conf`, `nginx-site.conf`, `ifconfig-fmt`, `sudoers-replica`, `vm-inventory.md`, `replica-parity.md`). The guest web tree, the boot scripts, the SNMP config, and the shadow extract were not searched. Each condition was repeated five times with `System.Diagnostics.Stopwatch` in one process. Repetition 1 is the cold read. The median is the third value after sorting.

| Corpus | Files read | Sentences found | Sentences coded | Hit rate |
| --- | ---: | ---: | ---: | ---: |
| Three skills | 3 | 23 | 23 | 23/23 |
| Replica files | 9 | 1 | 23 | 1/23 |

The one replica-file hit is the apt assignment that disables `Check-Valid-Until`.

| Repetition | Skills (ms) | Replica files (ms) |
| --- | ---: | ---: |
| 1 | 14.345 | 4.503 |
| 2 | 1.724 | 4.261 |
| 3 | 1.637 | 4.127 |
| 4 | 1.820 | 4.040 |
| 5 | 1.674 | 4.014 |
| Median | 1.724 | 4.127 |

The parity score for this replica is in `replica-parity.md`: 8 pass, 3 partial, 0 missing. The partial rows are package versions, vhosts, and cron. The guest is OpenBSD 5.9, so the image is Debian 11 and the package strings cannot match.
