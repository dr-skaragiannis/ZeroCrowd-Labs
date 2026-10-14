#!/bin/bash
set -eu
M=/mnt/gaara
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
ls "$M/etc/systemd/system/multi-user.target.wants" 2>/dev/null || true
echo "===== SSH ====="
grep -nE '^[Pp]ort |^[Ll]istenAddress |^[Pp]ermitRootLogin |^[Pp]asswordAuthentication ' "$M/etc/ssh/sshd_config" || true
echo "===== WEB DIRS ====="
ls -d "$M"/etc/apache2 "$M"/etc/nginx "$M"/var/www "$M"/var/www/html 2>/dev/null || true
echo MAP2_DONE
