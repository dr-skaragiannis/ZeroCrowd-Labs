#!/bin/bash
set -eu
RAW=/mnt/c/Users/bloodraven/Projects/matrix-lab/disk.raw
LOOP=$(losetup -j "$RAW" | head -n 1 | cut -d: -f1)
if [ -z "$LOOP" ]; then
  LOOP=$(losetup -fP --show "$RAW")
fi
mkdir -p /mnt/matrix /mnt/matrix-core
if ! mountpoint -q /mnt/matrix; then
  mount -o ro "${LOOP}p1" /mnt/matrix
fi
if ! mountpoint -q /mnt/matrix-core; then
  mount -o ro,loop /mnt/matrix/porteus/base/001-core.xzm /mnt/matrix-core
fi
echo "=== RC CHANGES ==="
ls -l /mnt/matrix/porteus/changes/etc/rc.d 2>/dev/null || true
echo "=== RC CORE EXEC ==="
find /mnt/matrix-core/etc/rc.d -maxdepth 1 -type f -executable -printf '%f\n' | sort
echo "=== WEB HINTS ==="
find /mnt/matrix/porteus/changes /mnt/matrix-core -name 'httpd.conf' -o -name 'nginx.conf' -o -name 'my.cnf' -o -name 'php.ini' 2>/dev/null | head -n 40
echo "=== PACKAGES SAMPLE ==="
ls /mnt/matrix-core/var/log/packages 2>/dev/null | awk 'BEGIN{c=0} /apache|httpd|nginx|mysql|mariadb|php|openssh|cron|sudo|postfix|sendmail|proftpd|vsftpd/{print; c++} END{print "listed", c}'
echo "=== ENDSCAN ==="
