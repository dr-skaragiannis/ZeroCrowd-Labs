#!/bin/bash
set -eu
cd /mnt/c/Users/bloodraven/Projects/got-lab
curl -fsSL --http1.1 --max-time 30 -A 'Mozilla/5.0' -o page.html 'https://www.vulnhub.com/entry/game-of-thrones-ctf-1,657/'
python3 - << 'PY'
from pathlib import Path
import re
text = Path('page.html').read_text(errors='replace')
for m in re.findall(r'https?://[^"\'\s<>]+', text):
    if re.search(r'torrent|magnet:|bittorrent', m, re.I):
        print(m)
print('LINKS', len(re.findall(r'href="[^"]+"', text)))
PY
rm -f page.html
echo "===== SPEED ====="
rm -f /tmp/got-speed.bin
curl --http1.1 --max-time 60 -A 'Mozilla/5.0' -r 0-8388607 -o /tmp/got-speed.bin \
  'https://download.vulnhub.com/gameofthrones/Game-of-Thrones-CTF-1.0.ova' || true
wc -c /tmp/got-speed.bin
echo SPEED_DONE
