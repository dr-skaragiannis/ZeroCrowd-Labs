#!/bin/bash
set -eu
IMG=/dev/loop0p4
BASE=/mnt/c/Users/bloodraven/Projects/necromancer-lab/replica
HT="$BASE/htdocs"
mkdir -p "$HT" "$BASE/scripts"
walk() {
  local ino="$1" dest="$2"
  mkdir -p "$dest"
  local tmp
  tmp=$(mktemp)
  fls "$IMG" "$ino" > "$tmp"
  while IFS= read -r line; do
    case "$line" in
      r/r\ *)
        local id name
        id=$(printf '%s\n' "$line" | sed -n 's/^r\/r \([0-9][0-9]*\):.*/\1/p')
        name=$(printf '%s\n' "$line" | sed -n 's/^r\/r [0-9][0-9]*:[[:space:]]*//p')
        [ -n "$id" ] && [ -n "$name" ] && icat "$IMG" "$id" > "$dest/$name"
        ;;
      d/d\ *)
        local id name
        id=$(printf '%s\n' "$line" | sed -n 's/^d\/d \([0-9][0-9]*\):.*/\1/p')
        name=$(printf '%s\n' "$line" | sed -n 's/^d\/d [0-9][0-9]*:[[:space:]]*//p')
        [ -n "$id" ] && [ -n "$name" ] && walk "$id" "$dest/$name"
        ;;
    esac
  done < "$tmp"
  rm -f "$tmp"
}
walk 77250 "$HT"
icat "$IMG" 25833 > "$BASE/scripts/listenu666.py"
icat "$IMG" 25856 > "$BASE/scripts/netcatsend.sh"
icat "$IMG" 25855 > "$BASE/scripts/broadcastmsg.txt"
icat "$IMG" 25836 > "$BASE/scripts/flag1.sh"
icat "$IMG" 25858 > "$BASE/scripts/root.cron"
cp /mnt/c/Users/bloodraven/Projects/necromancer-lab/extract/snmpd.conf "$BASE/snmpd.conf"
awk -F: '$1=="root" || $1=="demonslayer"' /mnt/c/Users/bloodraven/Projects/necromancer-lab/extract/master.passwd > "$BASE/shadow-users.txt"
chmod 600 "$BASE/shadow-users.txt" "$BASE/scripts/broadcastmsg.txt"
echo "===== TREE ====="
find "$HT" -printf '%y %s %p\n' | sort
echo "===== HOME ====="
fls /dev/loop0p8 | head -20
echo EXTRACT_WEB_DONE
