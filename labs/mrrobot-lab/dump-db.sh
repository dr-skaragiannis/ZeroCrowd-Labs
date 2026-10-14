#!/bin/bash
set -eu
M=/mnt/mrrobot
echo '## VERSION'
chroot "$M" /opt/bitnami/mysql/bin/mysqld --version || echo VERSION_FAIL
rm -f "$M/opt/bitnami/mysql/tmp/mysql.sock"
mkdir -p "$M/opt/bitnami/mysql/tmp" "$M/run" "$M/var/run" "$M/tmp"
mountpoint -q "$M/proc" || mount --bind /proc "$M/proc"
mountpoint -q "$M/dev" || mount --bind /dev "$M/dev"
chroot "$M" /opt/bitnami/mysql/bin/mysqld \
  --user=mysql \
  --skip-networking \
  --skip-grant-tables \
  >/var/tmp/mrrobot-disk/mysqld.log 2>&1 &
echo $! > /var/tmp/mrrobot-disk/mysqld.pid
SOCK="$M/opt/bitnami/mysql/tmp/mysql.sock"
ok=0
i=0
while [ "$i" -lt 40 ]; do
  if [ -S "$SOCK" ]; then
    ok=1
    break
  fi
  if ! kill -0 "$(cat /var/tmp/mrrobot-disk/mysqld.pid)" 2>/dev/null; then
    echo DIED
    break
  fi
  i=$((i+1))
  sleep 1
done
if [ "$ok" -ne 1 ]; then
  echo SOCKET_MISSING
  tail -n 50 /var/tmp/mrrobot-disk/mysqld.log || true
  exit 1
fi
chroot "$M" /opt/bitnami/mysql/bin/mysql --socket=/opt/bitnami/mysql/tmp/mysql.sock -N -e "SHOW DATABASES;"
chroot "$M" /opt/bitnami/mysql/bin/mysql --socket=/opt/bitnami/mysql/tmp/mysql.sock -N -e "SELECT option_name, option_value FROM bitnami_wordpress.wp_options WHERE option_name IN ('siteurl','home');"
mkdir -p /mnt/c/Users/bloodraven/Projects/mrrobot-lab/replica
chroot "$M" /opt/bitnami/mysql/bin/mysqldump --socket=/opt/bitnami/mysql/tmp/mysql.sock --single-transaction --routines --databases bitnami_wordpress > /mnt/c/Users/bloodraven/Projects/mrrobot-lab/replica/app.sql
echo DUMP_BYTES
wc -c /mnt/c/Users/bloodraven/Projects/mrrobot-lab/replica/app.sql
chroot "$M" /opt/bitnami/mysql/bin/mysqladmin --socket=/opt/bitnami/mysql/tmp/mysql.sock shutdown || true
