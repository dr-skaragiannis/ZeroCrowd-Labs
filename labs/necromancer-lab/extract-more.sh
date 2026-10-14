#!/bin/bash
set -eu
IMG=/dev/loop0p4
OUT=/mnt/c/Users/bloodraven/Projects/necromancer-lab/extract
icat "$IMG" 51846 > "$OUT/sshd_config"
echo "===== SSHD ====="
grep -nE '^[Pp]ort|^[Ll]isten|^[Pp]ermit|^[Pp]assword' "$OUT/sshd_config" || true
echo "===== RC SSH ====="
grep -n sshd "$OUT/rc.conf" || true
echo "===== PASSWD HUMANS ====="
awk -F: '($3==0 || $3>=1000) && $7 !~ /nologin/ {print $1,$3,$4,$7}' "$OUT/passwd"
echo "===== WHEEL ====="
grep -E '^(wheel|sudo|operator):' "$OUT/group" || true
echo "===== MOTD HEAD ====="
icat "$IMG" 51722 | head -3
echo "===== NETSNMP RC ====="
icat "$IMG" 51867 | head -40
echo "===== VAR ====="
fls "$IMG" 77189 | head -30
echo MORE_DONE
