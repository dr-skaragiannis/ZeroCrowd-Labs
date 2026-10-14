#!/bin/bash
set -eu
URL='https://download.vulnhub.com/gameofthrones/Game-of-Thrones-CTF-1.0.ova'
ok=0
for i in 1 2 3 4 5 6 7 8; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --http1.1 --max-time 20 -A 'Mozilla/5.0' -r 0-100 "$URL" || echo ERR)
  echo "TRY $i $code"
  if [ "$code" = "206" ] || [ "$code" = "200" ]; then
    ok=1
    break
  fi
  sleep 90
done
if [ "$ok" -ne 1 ]; then
  echo HOST_DOWN
  exit 1
fi
exec bash /mnt/c/Users/bloodraven/Projects/got-lab/download-seq.sh
