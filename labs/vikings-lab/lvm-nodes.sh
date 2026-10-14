#!/bin/bash
set -u
echo "=== mapper ==="
ls -l /dev/mapper /dev/ubuntu-vg 2>&1 || true
echo "=== dmsetup ==="
dmsetup ls 2>&1 || true
dmsetup info -c 2>&1 || true
echo "=== lvdisplay ==="
lvdisplay ubuntu-vg 2>&1 | head -40
