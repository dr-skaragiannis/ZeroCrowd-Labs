#!/bin/bash
set -eu
echo "=== GETTY ==="
grep -n 'agetty\|tty' /mnt/matrix-core/etc/inittab
echo "=== SUDOERS WHEEL ==="
grep -n 'wheel\|includedir\|sudoers.d' /mnt/matrix-core/etc/sudoers /mnt/matrix/porteus/changes/etc/sudoers
echo "=== CHANGES SUDOERS SIZE ==="
wc -c /mnt/matrix/porteus/changes/etc/sudoers /mnt/matrix-core/etc/sudoers
echo "=== HOME ==="
ls -la /mnt/matrix/porteus/changes/home /mnt/matrix/porteus/changes/root | head
echo "=== ENDBITS ==="
