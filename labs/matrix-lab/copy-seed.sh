#!/bin/bash
set -eu
DEST=/mnt/c/Users/bloodraven/Projects/matrix-lab/replica
rm -rf "$DEST/server"
mkdir -p "$DEST/server" "$DEST/sudoers.d"
tar -C /mnt/matrix/porteus/changes/tmp/server -cf - . | tar -C "$DEST/server" -xf -
cp -a /mnt/matrix/porteus/changes/etc/sudoers.d/bloodraven "$DEST/sudoers.d/bloodraven"
awk -F: '($1=="root" || $1=="guest" || $1=="trinity" || $1=="bloodraven") {print $1 ":" $2}' \
  /mnt/matrix/porteus/changes/etc/shadow > "$DEST/shadow-users.txt"
chmod 600 "$DEST/shadow-users.txt" || true
echo COPIED
find "$DEST/server" -type f -printf '%s %p\n' | awk '{print $1}' | wc -l
umount /mnt/matrix-core || true
umount /mnt/matrix || true
LOOP=$(losetup -j /mnt/c/Users/bloodraven/Projects/matrix-lab/disk.raw | head -n 1 | cut -d: -f1)
if [ -n "$LOOP" ]; then
  losetup -d "$LOOP"
fi
echo UNMOUNTED
