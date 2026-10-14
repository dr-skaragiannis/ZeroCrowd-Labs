#!/bin/bash
set -eu
RAW=/mnt/c/Users/bloodraven/Projects/vikings-lab/disk.raw
DEST=/mnt/c/Users/bloodraven/Projects/vikings-lab/replica
LOOP=$(losetup -j "$RAW" | head -n 1 | cut -d: -f1)
if [ -z "$LOOP" ]; then
  LOOP=$(losetup -fP --show "$RAW")
fi
echo "LOOP=$LOOP"
if ! mountpoint -q /mnt/vikings; then
  vgchange -ay ubuntu-vg
  dmsetup mknodes
  mkdir -p /mnt/vikings
  mount -o ro /dev/mapper/ubuntu--vg-ubuntu--lv /mnt/vikings
fi
rm -rf "$DEST"
mkdir -p "$DEST/webroot" "$DEST/pylib" "$DEST/cron.d" "$DEST/sudoers.d"
tar -C /mnt/vikings/var/www/html -cf - . | tar -C "$DEST/webroot" -xf -
cp -a /mnt/vikings/usr/local/lib/python3.6/dist-packages/. "$DEST/pylib/"
cp -a /mnt/vikings/usr/local/bin/rpyc_classic.py "$DEST/rpyc_classic.py"
cp -a /mnt/vikings/etc/sudoers.d/bloodraven "$DEST/sudoers.d/bloodraven"
if [ -f /mnt/vikings/etc/sudoers.d/99-snapd.conf ]; then
  cp -a /mnt/vikings/etc/sudoers.d/99-snapd.conf "$DEST/sudoers.d/99-snapd.conf"
fi
cp -a /mnt/vikings/var/spool/cron/crontabs/root "$DEST/root.crontab"
cp -a /mnt/vikings/etc/crontab "$DEST/crontab"
cp -a /mnt/vikings/etc/apache2/sites-enabled/000-default.conf "$DEST/000-default.conf"
for f in dma cron-apt mdadm popularity-contest; do
  if [ -f "/mnt/vikings/etc/cron.d/$f" ]; then
    cp -a "/mnt/vikings/etc/cron.d/$f" "$DEST/cron.d/$f"
  fi
done
awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1}' /mnt/vikings/etc/passwd > "$DEST/human-users.txt"
: > "$DEST/shadow-users.txt"
while read -r user; do
  grep "^${user}:" /mnt/vikings/etc/shadow >> "$DEST/shadow-users.txt"
done < "$DEST/human-users.txt"
chmod 600 "$DEST/shadow-users.txt"
{
  echo "=== HTML ==="
  ls -la /mnt/vikings/var/www/html
  echo "=== MODS ==="
  ls /mnt/vikings/etc/apache2/mods-enabled
} > "$DEST/notes.txt"
echo COPIED
wc -c "$DEST/shadow-users.txt" "$DEST/rpyc_classic.py"
du -sh "$DEST/webroot" "$DEST/pylib"
cat "$DEST/notes.txt"
umount /mnt/vikings
vgchange -an ubuntu-vg || true
losetup -d "$LOOP"
echo UNMOUNTED
