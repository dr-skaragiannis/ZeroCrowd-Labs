#!/bin/bash
set -eu
cd /mnt/c/Users/bloodraven/Projects/got-lab
URL='https://download.vulnhub.com/gameofthrones/Game-of-Thrones-CTF-1.0.ova'
SIZE=2506974720
CHUNK=33554432
OUT=Game-of-Thrones-CTF-1.0.ova
rm -f "$OUT"
off=0
n=0
while [ "$off" -lt "$SIZE" ]; do
  end=$((off + CHUNK - 1))
  if [ "$end" -ge "$SIZE" ]; then
    end=$((SIZE - 1))
  fi
  tmp="$OUT.part"
  rm -f "$tmp"
  curl --http1.1 --retry 4 --retry-delay 2 --max-time 180 -A 'Mozilla/5.0' \
    -r "${off}-${end}" -o "$tmp" "$URL"
  got=$(wc -c < "$tmp")
  want=$((end - off + 1))
  if [ "$got" -ne "$want" ]; then
    echo "SHORT $off got $got want $want"
    exit 1
  fi
  cat "$tmp" >> "$OUT"
  rm -f "$tmp"
  off=$((end + 1))
  n=$((n + 1))
  echo "CHUNK $n OFF $off"
done
python3 - << 'PY'
import hashlib, pathlib
p = pathlib.Path('/mnt/c/Users/bloodraven/Projects/got-lab/Game-of-Thrones-CTF-1.0.ova')
h = hashlib.md5()
s = hashlib.sha1()
n = 0
with p.open('rb') as f:
    head = f.read(20)
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
