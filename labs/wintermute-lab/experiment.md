# Lookup experiment

Date: 13 October 2026. This is a text lookup, not a second agent and not a task time.

Twenty-three rule sentences were taken from the apt, build, and parity skills. A PowerShell script searched those three skill files, then the replica files that record the finished settings (both Dockerfiles, `compose.yaml`, both entrypoints, both supervisor files, `vm-inventory.md`, `replica-parity.md`). The guest web trees, the JDK, the Tomcat tree, and the shadow extracts were not searched. Each condition was repeated five times with `System.Diagnostics.Stopwatch` in one process. Repetition 1 is the cold read. The median is the third value after sorting.

| Corpus | Files read | Sentences found | Sentences coded | Hit rate |
| --- | ---: | ---: | ---: | ---: |
| Three skills | 3 | 23 | 23 | 23/23 |
| Replica files | 9 | 1 | 23 | 1/23 |

The one replica-file hit is the apt assignment that disables `Check-Valid-Until`.

| Repetition | Skills (ms) | Replica files (ms) |
| --- | ---: | ---: |
| 1 | 4.064 | 1.186 |
| 2 | 0.758 | 1.039 |
| 3 | 0.744 | 0.993 |
| 4 | 0.667 | 0.947 |
| 5 | 0.781 | 1.123 |
| Median | 0.758 | 1.039 |

The parity score for this replica is in `replica-parity.md`: 8 pass, 3 partial, 0 missing. The partial rows are listening ports, package versions, and mail. The JDK is 1.8.0_171 and the Tomcat tree is the guest copy. Neuromancer's cron package string matches the guest.
