#!/bin/bash
set -eu
echo "===== HEADERS ====="
curl -sI --http1.1 --max-time 20 -A 'Mozilla/5.0' -r 0-100 \
  'https://download.vulnhub.com/gameofthrones/Game-of-Thrones-CTF-1.0.ova' | head -25
echo "===== PAGE URLS ====="
curl -fsSL --http1.1 --max-time 30 -A 'Mozilla/5.0' -o /tmp/got-page.html \
  'https://www.vulnhub.com/entry/game-of-thrones-ctf-1,657/'
python3 - << 'PY'
import re
from pathlib import Path
text = Path("/tmp/got-page.html").read_text(errors="replace")
for m in re.findall(r'https?://[^"\'\s<>]+', text):
    if re.search(r'\.ova|mirror|download', m, re.I) and "walkthrough" not in m.lower():
        print(m)
PY
rm -f /tmp/got-page.html
echo ALT_DONE
