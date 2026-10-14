#!/bin/bash
set -eu
echo "=== PORTEUS CFG ==="
cat /mnt/matrix/boot/syslinux/porteus.cfg
echo "=== CHANGES ETC ==="
ls /mnt/matrix/porteus/changes/etc
echo "=== MOUNT CORE ==="
mkdir -p /mnt/matrix-core
if ! mountpoint -q /mnt/matrix-core; then
  mount -o ro,loop /mnt/matrix/porteus/base/001-core.xzm /mnt/matrix-core
fi
echo "=== CORE OS bits ==="
ls /mnt/matrix-core/etc/inittab /mnt/matrix-core/etc/sudoers /mnt/matrix-core/etc/ssh/sshd_config 2>/dev/null || true
echo "=== INITTAB HEAD ==="
head -n 40 /mnt/matrix-core/etc/inittab 2>/dev/null || echo no-inittab
echo "=== SUDO GROUP ==="
grep -E '^(sudo|wheel|admin):' /mnt/matrix-core/etc/group /mnt/matrix/porteus/changes/etc/group 2>/dev/null || true
echo "=== SSH ==="
grep -E '^(PermitRootLogin|PasswordAuthentication|#PermitRootLogin|#PasswordAuthentication)' /mnt/matrix-core/etc/ssh/sshd_config 2>/dev/null || echo no-sshd
echo "=== ENDCORE ==="
