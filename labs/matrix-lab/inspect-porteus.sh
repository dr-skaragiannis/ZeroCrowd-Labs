#!/bin/bash
set -eu
echo "=== TREE ==="
find /mnt/matrix -maxdepth 3 \( -type d -o -type f \) -printf '%y %s %p\n' | sort
echo "=== OS ==="
cat /mnt/matrix/porteus/changes/etc/os-release
echo "=== PASSWD ==="
awk -F: '($3==0 || $3>=1000) {print $1, $3, $4, $6, $7}' /mnt/matrix/porteus/changes/etc/passwd
echo "=== SHADOW PREFIX ==="
if [ -f /mnt/matrix/porteus/changes/etc/shadow ]; then
  awk -F: '{print $1, substr($2,1,3)}' /mnt/matrix/porteus/changes/etc/shadow
else
  echo no-shadow-in-changes
fi
echo "=== BOOT CFG ==="
find /mnt/matrix/boot -name 'porteus.cfg' -o -name 'grub.cfg' -o -name '*.cfg' | head
echo "=== ENDTREE ==="
