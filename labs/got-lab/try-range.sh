#!/bin/bash
set -eu
cd /mnt/c/Users/bloodraven/Projects/got-lab
rm -f Game-of-Thrones-CTF-1.0.ova
curl -fsSL --http1.1 --max-time 30 -A 'Mozilla/5.0' -o page.html 'https://www.vulnhub.com/entry/game-of-thrones-ctf-1,657/'
grep -oE 'https?://[^" ]+\.torrent' page.html | head -5 || true
rm -f page.html
echo "===== RANGE ====="
curl -fsSL --http1.1 --max-time 40 -A 'Mozilla/5.0' -r 0-1048575 -D - -o /tmp/got-range.bin \
  'https://download.vulnhub.com/gameofthrones/Game-of-Thrones-CTF-1.0.ova' | head -20
wc -c /tmp/got-range.bin
xxd -l 16 /tmp/got-range.bin
echo RANGE_DONE
