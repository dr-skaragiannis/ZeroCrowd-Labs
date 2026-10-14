#!/bin/bash
set -eu
umount /mnt/vikings/boot || true
umount /mnt/vikings
vgchange -an ubuntu-vg
losetup -d /dev/loop0
echo UNMOUNTED
losetup -l || true
