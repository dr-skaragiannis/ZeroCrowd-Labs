#!/bin/bash
set -eu
M=/mnt/gaara
echo "===== FILE ====="
file "$M/var/www/html/"*
echo "===== HOST ====="
cat "$M/etc/hostname"
grep -v '^#' "$M/etc/hosts" | head
echo "===== RC ====="
if [ -f "$M/etc/rc.local" ]; then grep -vE '^#|^$' "$M/etc/rc.local" || true; fi
echo "===== HOME ====="
find "$M/home/gaara" -maxdepth 2 -printf '%y %s %p\n' | head -40
echo "===== UNITS CUSTOM ====="
find "$M/etc/systemd/system" -maxdepth 2 -type f -printf '%p\n' | head -40
echo "===== MAIL ====="
ls "$M/etc/postfix" "$M/etc/exim4" 2>/dev/null || echo no_mail_cfg
echo "===== CONF ENABLED ====="
ls "$M/etc/apache2/conf-enabled"
echo LOOK4_DONE
