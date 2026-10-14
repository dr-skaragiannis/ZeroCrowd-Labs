#!/bin/bash
set -eu
inspect() {
  local name="$1" raw="$2"
  echo "===== $name ====="
  parted -s "$raw" unit B print || true
  local loop
  loop=$(losetup -fP --show "$raw")
  echo "LOOP $loop"
  lsblk -f "$loop"
  echo "PARTS"
  lsblk -o NAME,SIZE,FSTYPE,LABEL,UUID "$loop"
}
inspect straylight /mnt/c/Users/bloodraven/Projects/wintermute-lab/straylight-disk.raw
inspect neuromancer /mnt/c/Users/bloodraven/Projects/wintermute-lab/neuromancer-disk.raw
echo INSPECT_DONE
