#!/bin/bash
set -eu
umount /mnt/straylight 2>/dev/null || true
for dev in $(losetup -j /mnt/c/Users/bloodraven/Projects/wintermute-lab/straylight-disk.raw | cut -d: -f1); do
  losetup -d "$dev" || true
done
echo LOOPS
losetup -j /mnt/c/Users/bloodraven/Projects/wintermute-lab/straylight-disk.raw || true
test -d /mnt/c/Users/bloodraven/Projects/wintermute-lab/replica/straylight/ntopng-share/ntopng/httpdocs && echo DOCS_OK
