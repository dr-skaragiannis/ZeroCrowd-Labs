#!/bin/bash
set -eu
IMG=/dev/loop0p4
OUT=/mnt/c/Users/bloodraven/Projects/necromancer-lab/extract
mkdir -p "$OUT"
icat "$IMG" 51611 > "$OUT/rc.conf"
icat "$IMG" 51861 > "$OUT/rc.conf.local"
icat "$IMG" 51860 > "$OUT/httpd.conf"
icat "$IMG" 51843 > "$OUT/myname"
icat "$IMG" 51842 > "$OUT/hostname.em0"
icat "$IMG" 51841 > "$OUT/fstab"
icat "$IMG" 51872 > "$OUT/sudoers"
icat "$IMG" 51877 > "$OUT/passwd"
icat "$IMG" 51871 > "$OUT/group"
icat "$IMG" 51883 > "$OUT/master.passwd"
chmod 600 "$OUT/master.passwd"
echo "===== SSH DIR ====="
fls "$IMG" 51696
echo "===== RC.D ====="
fls "$IMG" 51612
echo "===== SNMP ====="
fls "$IMG" 51721
echo "===== PREFIX ====="
awk -F: '{
  if ($2 ~ /^\$/) { split($2,a,"$"); print $1, $3, "$" a[2] "$" }
  else if ($2=="*" || $2=="!" || $2=="") print $1, $3, $2
  else print $1, $3, "set"
}' "$OUT/master.passwd"
echo EXTRACT_DONE
