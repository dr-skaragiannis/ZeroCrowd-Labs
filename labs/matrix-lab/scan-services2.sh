#!/bin/bash
set -eu
echo "=== MODULES ==="
find /mnt/matrix/porteus/modules /mnt/matrix/porteus/optional /mnt/matrix/porteus/base -maxdepth 1 -type f -printf '%s %p\n'
echo "=== RC.LOCAL ==="
sed -E 's/[A-Za-z0-9+/=]{20,}/<redacted>/g' /mnt/matrix/porteus/changes/etc/rc.d/rc.local
echo "=== RC.SSHD HEAD ==="
head -n 30 /mnt/matrix/porteus/changes/etc/rc.d/rc.sshd
echo "=== CHANGES USR ==="
find /mnt/matrix/porteus/changes/usr /mnt/matrix/porteus/changes/var /mnt/matrix/porteus/changes/opt /mnt/matrix/porteus/changes/home -maxdepth 3 -type d -printf '%p\n' 2>/dev/null | head -n 80
echo "=== WWW ==="
find /mnt/matrix/porteus/changes -iname '*http*' -o -iname '*nginx*' -o -iname 'www' -o -iname 'htdocs' 2>/dev/null | head
echo "=== END2 ==="
