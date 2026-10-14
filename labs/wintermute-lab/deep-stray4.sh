#!/bin/bash
set -eu
for f in run.sh fside.sh freeside.sh frun.sh loop.sh; do
  echo "== $f"
  cat -A "/mnt/straylight/root/scripts/$f"
done
echo "== find units"
find /mnt/straylight -name 'fside.service' 2>/dev/null || true
echo "== pg listen"
grep listen_addresses /mnt/straylight/etc/postgresql/9.6/main/postgresql.conf || true
echo "== ntop"
ls -la /mnt/straylight/usr/local/bin/ntopng || true
echo "== mysql schemas"
ls /mnt/straylight/var/lib/mysql
echo "== pg clusters"
ls /mnt/straylight/var/lib/postgresql/9.6/main 2>/dev/null | head || true
echo "== apache mods"
ls /mnt/straylight/etc/apache2/mods-enabled
echo DONE4
