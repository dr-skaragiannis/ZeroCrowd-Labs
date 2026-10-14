#!/bin/bash
set -eu
echo "=== PYTHON PKG ==="
ls /mnt/matrix-core/var/log/packages | grep -E '^python-' || true
echo "=== CROND ==="
ls -l /mnt/matrix-core/etc/rc.d/rc.crond /mnt/matrix/porteus/changes/etc/rc.d/rc.crond 2>/dev/null || echo no-rc-crond
echo "=== LOCAL CMDS ==="
grep -E '^(cd|python)' /mnt/matrix/porteus/changes/etc/rc.d/rc.local
echo "=== MAIN ==="
cat /mnt/matrix/porteus/changes/tmp/server/main.sh
echo "=== SUDOERS ADDED ==="
diff -u /mnt/matrix-core/etc/sudoers /mnt/matrix/porteus/changes/etc/sudoers | grep -E '^\+' | grep -v '^\+\+\+' || true
echo "=== MAIL ==="
ls /mnt/matrix/porteus/changes/var/spool/mail 2>/dev/null || true
ls /mnt/matrix-core/var/log/packages | grep -E 'postfix|sendmail|dma|ssmtp' || echo no-mail-pkg
echo "=== END4 ==="
