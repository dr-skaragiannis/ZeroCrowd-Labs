#!/bin/bash
set -eu
cd /mnt/c/Users/bloodraven/Projects/got-lab
rm -f page.html
df -h /mnt/c | tail -1
curl -L --http1.1 --retry 5 --retry-delay 2 -C - --max-time 1800 \
  -A 'Mozilla/5.0' \
  -o Game-of-Thrones-CTF-1.0.ova \
  'https://download.vulnhub.com/gameofthrones/Game-of-Thrones-CTF-1.0.ova'
python3 - << 'PY'
import hashlib, pathlib
p = pathlib.Path('/mnt/c/Users/bloodraven/Projects/got-lab/Game-of-Thrones-CTF-1.0.ova')
h = hashlib.md5()
s = hashlib.sha1()
n = 0
with p.open('rb') as f:
    head = f.read(16)
    h.update(head)
    s.update(head)
    n += len(head)
    while True:
        b = f.read(1024 * 1024)
        if not b:
            break
        h.update(b)
        s.update(b)
        n += len(b)
print('SIZE', n)
print('HEAD', head)
print('MD5', h.hexdigest())
print('SHA1', s.hexdigest())
PY
echo DOWNLOAD_DONE
