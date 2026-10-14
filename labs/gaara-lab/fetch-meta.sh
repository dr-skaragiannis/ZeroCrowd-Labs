#!/bin/bash
set -eu
mkdir -p /mnt/c/Users/bloodraven/Projects/gaara-lab
cd /mnt/c/Users/bloodraven/Projects/gaara-lab
curl -fsSL --http1.1 --max-time 40 -A 'Mozilla/5.0' -o page.html 'https://www.vulnhub.com/entry/gaara-1,629/' || echo PAGE_FAIL
if [ -f page.html ]; then
  echo "PAGE_BYTES $(wc -c < page.html)"
  grep -ioE '.{0,40}(MD5|SHA1|SHA256|Operating System|Download).{0,80}' page.html | head -30 || true
fi
echo "===== HEAD ====="
curl -fsI --http1.1 --max-time 30 -A 'Mozilla/5.0' 'https://download.vulnhub.com/gaara/Gaara.ova' | head -20 || echo HEAD_FAIL
echo META_DONE
