#!/bin/bash
set -eu
RAW=/var/tmp/mrrobot-disk/disk.raw
LOOP=$(losetup -fP --show "$RAW")
echo "LOOP=$LOOP"
lsblk -f "$LOOP"
echo '-----PARTED-----'
parted -s "$RAW" unit B print || true
echo '-----FSTAB-CANDIDATES-----'
blkid || true
