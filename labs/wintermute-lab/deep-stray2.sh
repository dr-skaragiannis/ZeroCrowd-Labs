#!/bin/bash
set -eu
echo "--- bolo ---"
cat /mnt/straylight/etc/systemd/system/bolo.service
echo "--- free ---"
cat /mnt/straylight/etc/systemd/system/free.service
echo "--- fside ---"
cat /mnt/straylight/etc/systemd/system/fside.service
echo "--- ntop unit ---"
cat /mnt/straylight/etc/systemd/system/ntopng.service
echo "--- ntop conf ---"
grep -vE '^#|^$' /mnt/straylight/etc/ntopng/ntopng.conf || true
echo "--- vhost ---"
cat /mnt/straylight/etc/apache2/sites-enabled/000-default.conf
echo "--- pg conf ---"
grep -E '^(listen_addresses|port)' /mnt/straylight/etc/postgresql/9.6/main/postgresql.conf || true
echo "--- web root ---"
ls -la /mnt/straylight/var/www/html | head -50
echo "--- php db fields ---"
grep -RIn --include='*.php' -E 'db_name|database|DB_NAME|mysqli_connect|new PDO|pg_connect' /mnt/straylight/var/www/html 2>/dev/null | head -40 || true
echo DEEP2
