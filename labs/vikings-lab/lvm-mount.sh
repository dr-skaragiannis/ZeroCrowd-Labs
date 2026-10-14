#!/bin/bash
set -eu
vgchange -ay ubuntu-vg
lvs -o lv_name,vg_name,lv_size,lv_path
mkdir -p /mnt/vikings
# mount the largest LV that contains /etc/shadow
for lv in $(lvs --noheadings -o lv_path ubuntu-vg | awk '{print $1}'); do
  echo "TRY $lv"
  mkdir -p /mnt/vikings-try
  if mount -o ro "$lv" /mnt/vikings-try 2>/tmp/mnt.err; then
    if [ -f /mnt/vikings-try/etc/shadow ]; then
      echo "ROOT=$lv"
      umount /mnt/vikings-try
      mount "$lv" /mnt/vikings
      echo MOUNTED
      ls /mnt/vikings/etc/os-release
      exit 0
    fi
    echo "no shadow"
    umount /mnt/vikings-try
  else
    echo "mount failed"
    cat /tmp/mnt.err
  fi
done
echo "NO ROOT"
exit 1
