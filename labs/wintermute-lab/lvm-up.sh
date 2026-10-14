#!/bin/bash
set -eu
vgchange -ay neuromancer-vg
echo "===== LVS ====="
lvs -o lv_name,lv_size,lv_attr,lv_kernel_major,lv_kernel_minor
echo "===== MAPPER ====="
ls -la /dev/mapper
echo "===== DM ====="
dmsetup ls
echo "===== BLKID ====="
blkid /dev/mapper/neuromancer* || true
echo LVM_UP
