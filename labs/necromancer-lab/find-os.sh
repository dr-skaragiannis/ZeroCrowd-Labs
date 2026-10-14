#!/bin/bash
set -eu
ROOT=/dev/loop0p4
OUT=/mnt/c/Users/bloodraven/Projects/necromancer-lab/extract
icat "$ROOT" 25856 > "$OUT/netcatsend.sh"
echo "===== NETCAT DEST ====="
grep -nE 'nc |ncat|127\.|em0|UDP|PORT|port' "$OUT/netcatsend.sh" | head -20
echo "===== OS ====="
icat "$ROOT" 3 | strings | grep -m 1 'OpenBSD [0-9]'
echo "===== HTDOCS FILES ====="
fls "$ROOT" 77250
icat "$ROOT" 51743 > "$OUT/snmpd.conf"
echo "===== SNMP LINES ====="
grep -nE 'listen|agentAddress|rocommunity|com2sec|udp' "$OUT/snmpd.conf" | head -20
echo "===== GROUP DEMON ====="
grep demonslayer "$OUT/group" || true
echo FIND6
