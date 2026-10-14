#!/bin/bash
set -eu
dmsetup mknodes
ls -la /dev/mapper
echo "===== BLKID ROOT ====="
blkid /dev/mapper/neuromancer--vg-root || true
echo "===== BLKID SWAP ====="
blkid /dev/mapper/neuromancer--vg-swap_1 || true
mkdir -p /mnt/neuromancer
mount /dev/mapper/neuromancer--vg-root /mnt/neuromancer
echo "===== OS ====="
cat /mnt/neuromancer/etc/os-release
echo "===== KERNEL ====="
ls /mnt/neuromancer/lib/modules || true
echo "===== PASSWD ====="
awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1, $3, $4, $6, $7}' /mnt/neuromancer/etc/passwd
echo "===== GROUPS ====="
grep -E '^(sudo|wheel|admin):' /mnt/neuromancer/etc/group || true
echo "===== SHADOW PREFIX ====="
awk -F: '{split($2,a,"$"); print $1, (a[2]?"$"a[2]"$":substr($2,1,1))}' /mnt/neuromancer/etc/shadow
echo MOUNT_NEURO
