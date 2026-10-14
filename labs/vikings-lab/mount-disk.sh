#!/bin/bash
set -u
RAW=/mnt/c/Users/bloodraven/Projects/vikings-lab/disk.raw
LOOP=$(losetup -fP --show "$RAW")
echo "LOOP=$LOOP"
lsblk -f "$LOOP"
parted -s "$RAW" unit B print
