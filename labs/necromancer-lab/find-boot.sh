#!/bin/bash
set -eu
ROOT=/dev/loop0p4
OUT=/mnt/c/Users/bloodraven/Projects/necromancer-lab/extract
mkdir -p "$OUT"
icat "$ROOT" 25836 > "$OUT/flag1.sh"
echo "===== FLAG1 COMMANDS ====="
grep -nE 'python|nc |ncat|socat|httpd|snmp|cron|pfctl|listen|port' "$OUT/flag1.sh" || true
echo "===== CRON DIR ====="
fls "$ROOT" 77195
echo "===== PKG CONTENTS HEAD ====="
fls "$ROOT" 78583 | head -20
echo FIND4
