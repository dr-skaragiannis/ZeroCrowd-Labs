#!/bin/bash
set -eu
ROOT=/dev/loop0p4
USR=/dev/loop0p7
OUT=/mnt/c/Users/bloodraven/Projects/necromancer-lab/extract
echo "===== ROOT DIR ====="
fls "$ROOT" 25761
echo "===== WWW ====="
fls "$ROOT" 77240
echo "===== NET-SNMP VAR ====="
fls "$ROOT" 78858
echo "===== PKG DB ====="
fls "$ROOT" 77198 | head -40
echo "===== USR LOCAL ETC ====="
# find etc under /usr if present
fls "$USR" | head -30
echo FIND2
