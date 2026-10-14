#!/bin/bash
set -eu
IMG=/dev/loop0p4
echo "===== ROOT ====="
fls -l "$IMG" | head -40
echo "===== ETC ====="
# find etc directory inode from the root listing
etc_inode=$(fls "$IMG" | awk '/etc$/ {print $2}' | tr -d ':')
echo "ETC_INODE $etc_inode"
fls -l "$IMG" "$etc_inode" | head -80
echo LIST_DONE
