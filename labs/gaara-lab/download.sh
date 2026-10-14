#!/bin/bash
set -eu
cd /mnt/c/Users/bloodraven/Projects/gaara-lab
rm -f page.html
df -h /mnt/c | tail -1
curl -L --http1.1 --retry 5 --retry-delay 2 -C - --max-time 900 \
  -A 'Mozilla/5.0' \
  -o Gaara.ova \
  'https://download.vulnhub.com/gaara/Gaara.ova'
python3 - << 'PY'
import hashlib, pathlib
p = pathlib.Path('/mnt/c/Users/bloodraven/Projects/gaara-lab/Gaara.ova')
data = p.read_bytes()
print('SIZE', len(data))
print('HEAD', data[:16])
print('MD5', hashlib.md5(data).hexdigest())
print('SHA1', hashlib.sha1(data).hexdigest())
PY
echo DOWNLOAD_DONE
