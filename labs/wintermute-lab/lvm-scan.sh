#!/bin/bash
set -eu
echo "===== VGS BEFORE ====="
vgs || true
echo "===== PV ====="
pvscan || true
vgscan || true
echo "===== VGS AFTER SCAN ====="
vgs || true
echo LVM_SCAN_DONE
