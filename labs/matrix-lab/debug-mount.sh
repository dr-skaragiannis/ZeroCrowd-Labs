#!/bin/bash
set -eu
echo "=== MOUNT ==="
mount | grep matrix || true
echo "=== LS ==="
ls -la /mnt/matrix | head -n 30
echo "=== FIND PASSWD ==="
find /mnt/matrix -name passwd -o -name os-release 2>/dev/null | head
echo "=== LOSETUP ==="
losetup -l
ls -l /dev/loop0*
