#!/bin/bash
set -eu
echo "===== LOOPS ====="
losetup -l || true
LOOP=$(losetup -fP --show /mnt/c/Users/bloodraven/Projects/got-lab/disk.raw)
echo "LOOP $LOOP"
lsblk -f "$LOOP"
parted -s /mnt/c/Users/bloodraven/Projects/got-lab/disk.raw unit B print
echo MAP_DONE
