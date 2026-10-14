#!/bin/bash
set -eu
LOOP=$(losetup -fP --show /mnt/c/Users/bloodraven/Projects/moria-lab/disk.raw)
vgchange -ay cl >/dev/null
if [ ! -e /dev/mapper/cl-root ]; then
  mknod /dev/mapper/cl-root b 254 1 || true
fi
# device may already exist from this boot
mkdir -p /mnt/moria
mount /dev/mapper/cl-root /mnt/moria
awk -F: '$1=="root" || $1=="abatchy" || $1=="Ori" || $1=="Balrog" || $1=="bloodraven" {print}' /mnt/moria/etc/shadow > /mnt/c/Users/bloodraven/Projects/moria-lab/import/shadow.snippet
chmod 600 /mnt/c/Users/bloodraven/Projects/moria-lab/import/shadow.snippet
awk -F: '{print $1}' /mnt/c/Users/bloodraven/Projects/moria-lab/import/shadow.snippet
umount /mnt/moria
vgchange -an cl >/dev/null
losetup -d "$LOOP"
echo SHADOW_OK
