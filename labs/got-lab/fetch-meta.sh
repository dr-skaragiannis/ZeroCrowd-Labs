#!/bin/bash
set -eu
mkdir -p /mnt/c/Users/bloodraven/Projects/got-lab
cd /mnt/c/Users/bloodraven/Projects/got-lab
curl -fsSL --http1.1 --max-time 40 -A 'Mozilla/5.0' -o page.html 'https://www.vulnhub.com/entry/game-of-thrones-ctf-1,657/' || echo PAGE_FAIL
if [ -f page.html ]; then
  echo "PAGE_BYTES $(wc -c < page.html)"
  grep -ioE '.{0,20}(MD5|SHA1|Operating System).{0,60}' page.html | head -20 || true
fi
echo "===== HEAD ====="
curl -fsI --http1.1 --max-time 30 -A 'Mozilla/5.0' 'https://download.vulnhub.com/gameofthrones/Game-of-Thrones-CTF-1.0.ova' | head -20 || echo HEAD_FAIL
echo META_DONE
