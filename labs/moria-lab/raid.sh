#!/bin/bash
set -eu
LOOP=$(losetup -fP --show /mnt/c/Users/bloodraven/Projects/moria-lab/disk.raw)
vgchange -ay cl >/dev/null
# pick the xfs LV, never swap
rootdev=""
for dev in /dev/dm-*; do
  t=$(blkid -o value -s TYPE "$dev" || true)
  if [ "$t" = "xfs" ]; then rootdev=$dev; fi
done
echo ROOTDEV "$rootdev"
mkdir -p /mnt/moria
mount "$rootdev" /mnt/moria
cp -a /mnt/moria/etc/cron.d/raid-check /mnt/c/Users/bloodraven/Projects/moria-lab/raid-check
wc -c /mnt/c/Users/bloodraven/Projects/moria-lab/raid-check
umount /mnt/moria
vgchange -an cl >/dev/null || true
losetup -d "$LOOP"
echo RAID_OK
