#!/bin/bash
set -eu
echo "--- fside link ---"
ls -la /mnt/straylight/etc/systemd/system/multi-user.target.wants/fside.service
echo "--- scripts ---"
ls -la /mnt/straylight/root/scripts
echo "--- ntop unit ---"
cat /mnt/straylight/etc/systemd/system/ntopng.service
echo "--- ntop conf ---"
grep -vE '^#|^$' /mnt/straylight/etc/ntopng/ntopng.conf || true
echo "--- vhost ---"
cat /mnt/straylight/etc/apache2/sites-enabled/000-default.conf
echo "--- pg ---"
grep -E '^(listen_addresses|port)' /mnt/straylight/etc/postgresql/9.6/main/postgresql.conf || true
echo "--- web ---"
ls -la /mnt/straylight/var/www/html
echo "--- crontab root ---"
cat /mnt/straylight/var/spool/cron/crontabs/root 2>/dev/null || echo no-root-cron
echo "--- cron.d php ---"
cat /mnt/straylight/etc/cron.d/php
echo SCRIPT_HEADS
# show only lines that name a port, bind, or listen
grep -nE 'port|listen|bind|nc |python|php|node|socat|ncat' /mnt/straylight/root/scripts/* || true
echo DONE3
