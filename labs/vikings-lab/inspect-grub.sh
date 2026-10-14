#!/bin/bash
set -eu
RAW=/mnt/c/Users/bloodraven/Projects/vikings-lab/disk.raw
LOOP=$(losetup -fP --show "$RAW")
echo "LOOP=$LOOP"
vgchange -ay ubuntu-vg
dmsetup mknodes || true
ls -l /dev/mapper
mkdir -p /mnt/vikings
mount /dev/mapper/ubuntu--vg-ubuntu--lv /mnt/vikings
mount "${LOOP}p2" /mnt/vikings/boot
echo "=== getty ==="
ls -l /mnt/vikings/etc/systemd/system/getty.target.wants/ || true
echo "=== linux lines ==="
grep -n "linux " /mnt/vikings/boot/grub/grub.cfg | head -20
echo "=== default grub ==="
grep -E "CMDLINE|TERMINAL|SERIAL" /mnt/vikings/etc/default/grub || true
