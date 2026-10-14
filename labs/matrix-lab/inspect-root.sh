#!/bin/bash
set -eu
RAW=/mnt/c/Users/bloodraven/Projects/matrix-lab/disk.raw
LOOP=$(losetup -j "$RAW" | head -n 1 | cut -d: -f1)
if [ -z "$LOOP" ]; then
  LOOP=$(losetup -fP --show "$RAW")
fi
echo "LOOP=$LOOP"
mkdir -p /mnt/matrix
if ! mountpoint -q /mnt/matrix; then
  mount -o rw "${LOOP}p1" /mnt/matrix
fi
echo "=== OS ==="
cat /mnt/matrix/etc/os-release 2>/dev/null || true
uname_file=$(ls /mnt/matrix/lib/modules 2>/dev/null | head -n 3 || true)
echo "modules: $uname_file"
echo "=== PASSWD ==="
awk -F: '($3==0 || $3>=1000) {print $1, $3, $4, $6, $7}' /mnt/matrix/etc/passwd
echo "=== SHADOW PREFIX ==="
awk -F: '{p=substr($2,1,3); print $1, p}' /mnt/matrix/etc/shadow
echo "=== GROUPS ==="
grep -E '^(sudo|wheel|admin):' /mnt/matrix/etc/group || true
echo "=== SUDOERS D ==="
ls -la /mnt/matrix/etc/sudoers.d 2>/dev/null || true
echo "=== INIT ==="
ls /mnt/matrix/etc/systemd/system/getty.target.wants 2>/dev/null || echo no-systemd-getty
ls /mnt/matrix/etc/inittab 2>/dev/null || true
echo "=== GRUB ==="
ls /mnt/matrix/boot/grub/grub.cfg /mnt/matrix/boot/grub2/grub.cfg /mnt/matrix/etc/default/grub 2>/dev/null || true
echo "=== SSH LINES ==="
grep -E '^(PermitRootLogin|PasswordAuthentication|#PermitRootLogin|#PasswordAuthentication)' /mnt/matrix/etc/ssh/sshd_config 2>/dev/null || echo no-sshd-config
echo "=== FSTAB ==="
cat /mnt/matrix/etc/fstab
echo "=== ENDINSPECT ==="
