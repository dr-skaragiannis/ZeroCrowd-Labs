#!/bin/bash
set -eu
M=/mnt/got
mkdir -p "$M"
if ! mountpoint -q "$M"; then
  mount -o ro /dev/loop0p1 "$M"
fi
echo "===== OS ====="
cat "$M/etc/os-release"
echo "===== KERNEL ====="
ls "$M/lib/modules" 2>/dev/null || true
echo "===== USERS ====="
awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1, $3, $4, $6, $7}' "$M/etc/passwd"
echo "===== GROUPS ====="
grep -E '^(sudo|wheel|admin):' "$M/etc/group" || true
echo "===== WANTS ====="
ls "$M/etc/systemd/system/multi-user.target.wants" 2>/dev/null || ls "$M/etc/rc2.d" 2>/dev/null | head -40
echo "===== HOST ====="
cat "$M/etc/hostname"
echo LOOK_DONE
