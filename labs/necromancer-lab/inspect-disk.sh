#!/bin/bash
set -eu
parted -s /mnt/c/Users/bloodraven/Projects/necromancer-lab/disk.raw unit B print || true
LOOP=$(losetup -fP --show /mnt/c/Users/bloodraven/Projects/necromancer-lab/disk.raw)
echo "LOOP $LOOP"
lsblk -o NAME,SIZE,FSTYPE,TYPE "$LOOP"
echo "FILE"
file -s "$LOOP"* || true
echo INSPECT_DONE
