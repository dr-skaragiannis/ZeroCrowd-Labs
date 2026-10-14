#!/bin/bash
set -eu
echo "=== SERVER TREE ==="
find /mnt/matrix/porteus/changes/tmp /mnt/matrix-core/tmp /mnt/matrix/porteus/changes/root -path '*server*' -printf '%y %s %p\n' 2>/dev/null | head -n 50
echo "=== NAMES ==="
find /mnt/matrix/porteus/changes/tmp/server -maxdepth 2 -type f -printf '%f\n' 2>/dev/null || true
echo "=== BIND LINES ==="
find /mnt/matrix/porteus/changes/tmp/server -type f -name '*.py' -print 2>/dev/null | while read -r f; do
  echo "-- $(basename "$f")"
  grep -n -E 'bind|listen|port|HTTPServer|TCPServer|31337|80' "$f" | head -n 20
done
echo "=== CRON ==="
ls -la /mnt/matrix/porteus/changes/var/spool/cron/crontabs 2>/dev/null || echo no-crontabs
echo "=== SSHD PORT ==="
grep -n -E '^Port|^#Port|^ListenAddress' /mnt/matrix-core/etc/ssh/sshd_config /mnt/matrix/porteus/changes/etc/ssh/sshd_config 2>/dev/null || true
echo "=== END3 ==="
