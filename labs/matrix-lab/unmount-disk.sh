#!/bin/bash
set -eu
echo "=== WHEEL ==="
grep '^wheel:' /mnt/matrix/porteus/changes/etc/group
echo "=== PREFIX ==="
awk -F: '$1=="root" || $1=="bloodraven" {print $1, substr($2,1,3)}' /mnt/matrix/porteus/changes/etc/shadow
echo "=== SERIAL ==="
head -n 2 /mnt/matrix/boot/syslinux/porteus.cfg
echo "=== GETTY ==="
grep '^s0:' /mnt/matrix/porteus/changes/etc/inittab
echo "=== SUDO FILE ==="
wc -c /mnt/matrix/porteus/changes/etc/sudoers.d/bloodraven
umount /mnt/matrix-core || true
umount /mnt/matrix
LOOP=$(losetup -j /mnt/c/Users/bloodraven/Projects/matrix-lab/disk.raw | head -n 1 | cut -d: -f1)
losetup -d "$LOOP"
echo UNMOUNTED
losetup -l || true
