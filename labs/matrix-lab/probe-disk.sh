#!/bin/bash
set -eu
RAW=/mnt/c/Users/bloodraven/Projects/matrix-lab/disk.raw
LOOP=$(losetup -fP --show "$RAW")
echo "LOOP=$LOOP"
lsblk -f "$LOOP"
echo "=== PARTED ==="
parted -s "$RAW" unit B print || true
echo "=== BLKID ==="
blkid "${LOOP}"* || true
