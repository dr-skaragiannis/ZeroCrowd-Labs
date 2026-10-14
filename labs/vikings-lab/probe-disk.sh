#!/bin/bash
set -u
echo "=== blkid ==="
blkid /dev/loop0p1 /dev/loop0p2 /dev/loop0p3 || true
echo "=== file ==="
file -s /dev/loop0p2 /dev/loop0p3
echo "=== pvs ==="
pvs 2>/dev/null || true
vgscan 2>/dev/null || true
