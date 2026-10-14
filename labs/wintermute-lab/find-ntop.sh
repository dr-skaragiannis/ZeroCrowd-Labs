#!/bin/bash
set -eu
LOOP=$(losetup -fP --show /mnt/c/Users/bloodraven/Projects/wintermute-lab/straylight-disk.raw)
mkdir -p /mnt/straylight
mount "${LOOP}p1" /mnt/straylight
find /mnt/straylight/usr /mnt/straylight/var /mnt/straylight/etc -iname '*ntopng*' | head -80
echo FIND_NTOP_DONE
