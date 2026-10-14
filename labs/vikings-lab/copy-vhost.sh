#!/bin/bash
set -eu
RAW=/mnt/c/Users/bloodraven/Projects/vikings-lab/disk.raw
DEST=/mnt/c/Users/bloodraven/Projects/vikings-lab/replica
LOOP=$(losetup -fP --show "$RAW")
echo "LOOP=$LOOP"
vgchange -ay ubuntu-vg
dmsetup mknodes
mkdir -p /mnt/vikings
mount -o ro /dev/mapper/ubuntu--vg-ubuntu--lv /mnt/vikings
rm -f "$DEST/000-default.conf"
cp -a /mnt/vikings/etc/apache2/sites-available/000-default.conf "$DEST/000-default.conf"
wc -c "$DEST/000-default.conf"
umount /mnt/vikings
vgchange -an ubuntu-vg
losetup -d "$LOOP"
echo UNMOUNTED
