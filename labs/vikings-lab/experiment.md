# Lookup experiment

Date: 13 October 2026. This is a text lookup, not a second agent and not a task time.

Twenty-three rule sentences were taken from the apt, build, and parity skills. A PowerShell script searched those three skill files, then the replica files that record the finished settings (`Dockerfile`, `compose.yaml`, `entrypoint.sh`, `supervisord.conf`, `vm-inventory.md`, `replica-parity.md`). The guest web tree, the Python packages, and the shadow extract were not searched. Each condition was repeated five times with `System.Diagnostics.Stopwatch` in one process. Repetition 1 is the cold read. The median is the third value after sorting.

| Corpus | Files read | Sentences found | Sentences coded | Hit rate |
| --- | ---: | ---: | ---: | ---: |
| Three skills | 3 | 23 | 23 | 23/23 |
| Replica files | 6 | 1 | 23 | 1/23 |

The one replica-file hit is the apt assignment that disables `Check-Valid-Until`.

| Repetition | Skills (ms) | Replica files (ms) |
| --- | ---: | ---: |
| 1 | 3.116 | 0.717 |
| 2 | 0.760 | 0.633 |
| 3 | 0.618 | 0.675 |
| 4 | 0.586 | 0.635 |
| 5 | 0.595 | 0.608 |
| Median | 0.618 | 0.635 |

The parity score for this replica is in `replica-parity.md`: 9 pass, 2 partial, 0 missing. The partial rows are listening ports (systemd-resolved and containerd) and package versions (containerd and docker.io are not installed). The six service version strings that the image pins match the guest.
