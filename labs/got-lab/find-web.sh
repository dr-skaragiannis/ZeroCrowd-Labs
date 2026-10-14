#!/bin/bash
set -eu
D=/mnt/got/var/lib/docker/overlay2
echo "===== HTML ====="
find "$D" -path '*/var/www/html/*' -o -path '*/var/www/html2/*' -o -path '*/var/www/gitlist/*' | head -40
echo "===== WEBMIN SIZE ====="
du -sh "$D/b12fc6d5fd6df0b513d16f84bd334e4583f8b0ff762fbd4450bf8253b6838205/diff" "$D/43e39a397eb7158dfcfca3b8fe208ef2d533969f57d8bbc6a72efeef208c28a9/diff" 2>/dev/null || true
echo FIND2_DONE
