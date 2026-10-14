#!/bin/bash
set -eu
curl -fsSL "https://snapshot.ubuntu.com/" | head -n 80
echo "==== 301 ===="
curl -sI "http://snapshot.ubuntu.com/ubuntu/20210904T000000Z/dists/bionic-updates/Release" | head -n 20
echo "==== python pool guesses ===="
for u in \
  "http://archive.ubuntu.com/ubuntu/pool/main/p/python3-defaults/python3_3.6.7-1~18.04_amd64.deb" \
  "http://archive.ubuntu.com/ubuntu/pool/main/p/python3-defaults/python3_3.6.7-1~18.04_all.deb"
 do
  code=$(curl -sI -o /dev/null -w '%{http_code}' "$u" || true)
  echo "$code $u"
done
