#!/bin/bash
set -eu
mkdir -p /mnt/necro
for p in /dev/loop0p6 /dev/loop0p7 /dev/loop0p8 /dev/loop0p5 /dev/loop0p4; do
  echo "===== $p ====="
  if mount -t ufs -o ro,ufstype=44bsd "$p" /mnt/necro 2>/tmp/mnt.err; then
    echo MOUNTED
    ls /mnt/necro | head
    if [ -f /mnt/necro/etc/master.passwd ]; then echo HAS_MASTER; fi
    umount /mnt/necro
  else
    echo FAIL
    cat /tmp/mnt.err
  fi
done
echo TRY_DONE
