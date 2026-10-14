#!/bin/bash
set -eu
ls -l /dev/dm-* 2>/dev/null || true
mkdir -p /dev/mapper
if [ ! -e /dev/mapper/cl-root ]; then
  mknod /dev/mapper/cl-root b 254 1
  chmod 660 /dev/mapper/cl-root
fi
mkdir -p /mnt/moria
mount /dev/mapper/cl-root /mnt/moria
findmnt /mnt/moria
echo ---OS---
cat /mnt/moria/etc/os-release
echo ---PASSWD---
awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1, $3, $6, $7}' /mnt/moria/etc/passwd
echo ---FSTAB---
cat /mnt/moria/etc/fstab
echo ---SHADOWROOT---
awk -F: '$1=="root" {print $1, length($2), substr($2,1,3)}' /mnt/moria/etc/shadow
