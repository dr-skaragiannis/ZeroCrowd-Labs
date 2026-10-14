#!/bin/bash
set -eu
dmsetup ls
echo ---
lvs -o lv_name,lv_path,lv_kernel_major,lv_kernel_minor
echo ---
ls -l /dev/mapper /dev/dm-*
