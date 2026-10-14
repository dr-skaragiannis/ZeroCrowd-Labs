#!/bin/bash
set -eu
dmsetup mknodes
ls -l /dev/mapper
mkdir -p /mnt/vikings
if ! mount /dev/mapper/ubuntu--vg-ubuntu--lv /mnt/vikings; then
  mknod -m 660 /dev/mapper/ubuntu--vg-ubuntu--lv b 254 0
  mount /dev/mapper/ubuntu--vg-ubuntu--lv /mnt/vikings
fi
echo MOUNTED
cat /mnt/vikings/etc/os-release
echo "=== shadow lock fields ==="
awk -F: '($3==0 || $3>=1000) {print $1}' /mnt/vikings/etc/passwd
echo "=== fstab ==="
cat /mnt/vikings/etc/fstab
