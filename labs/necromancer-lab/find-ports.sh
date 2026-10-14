#!/bin/bash
set -eu
ROOT=/dev/loop0p4
OUT=/mnt/c/Users/bloodraven/Projects/necromancer-lab/extract
icat "$ROOT" 25833 > "$OUT/listenu666.py"
icat "$ROOT" 25857 > "$OUT/root.orig.cron"
icat "$ROOT" 25858 > "$OUT/root.netcatsend.cron"
echo "===== PY BINDS ====="
grep -nE 'bind|AF_|SOCK_|port|listen' "$OUT/listenu666.py" | head -40
echo "===== CRON LINES ====="
# print schedule and command name only
awk '{print $1,$2,$3,$4,$5,$6}' "$OUT/root.netcatsend.cron"
echo "===== TABS ====="
fls "$ROOT" 77197
echo "===== SNMP CONF PATHS ====="
grep -a snmpd.conf "$OUT/../extract/+" 2>/dev/null || true
icat "$ROOT" 78855 | grep -a 'snmpd.conf' | head
echo "===== OSREV ====="
fls "$ROOT" | grep -E 'bsd$|os-release|release'
echo FIND5
