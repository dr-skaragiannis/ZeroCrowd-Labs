#!/bin/bash
set -eu
mkdir -p /mnt/moria
mount /dev/dm-2 /mnt/moria
awk -F: '$1=="root" || $1=="abatchy" || $1=="Ori" || $1=="Balrog" || $1=="bloodraven" {print}' /mnt/moria/etc/shadow > /mnt/c/Users/bloodraven/Projects/moria-lab/import/shadow.snippet
chmod 600 /mnt/c/Users/bloodraven/Projects/moria-lab/import/shadow.snippet
awk -F: '{print $1}' /mnt/c/Users/bloodraven/Projects/moria-lab/import/shadow.snippet
umount /mnt/moria
vgchange -an cl >/dev/null || true
# detach only the moria raw loop, never every loop
losetup -j /mnt/c/Users/bloodraven/Projects/moria-lab/disk.raw | awk -F: '{print $1}' | while read -r dev; do losetup -d "$dev"; done
echo SHADOW_OK
