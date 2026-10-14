#!/bin/bash
set -eu
umount /mnt/moria/boot
umount /mnt/moria
vgchange -an cl
losetup -d /dev/loop0
echo UNMOUNTED
stat -c '%s %n' /mnt/c/Users/bloodraven/Projects/moria-lab/disk.raw
