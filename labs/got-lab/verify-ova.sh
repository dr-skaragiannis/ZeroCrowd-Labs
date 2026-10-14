#!/bin/bash
set -eu
cd /mnt/c/Users/bloodraven/Projects/got-lab
curl -fsS --http1.1 --max-time 30 -A 'Mozilla/5.0' -o page.html \
  'https://www.vulnhub.com/entry/game-of-thrones-ctf-1,657/'
python3 - << 'PY'
import re
from pathlib import Path
text = Path("page.html").read_text(errors="replace")
title = re.search(r"<title>([^<]+)", text)
print("TITLE", title.group(1).strip() if title else "none")
for line in re.findall(r".{0,30}(MD5|SHA1|Game-of-Thrones|\.ova).{0,80}", text, re.I):
    pass
for m in re.finditer(r".{0,40}(MD5|SHA1|Game-of-Thrones-CTF).{0,90}", text, re.I):
    s = re.sub(r"<[^>]+>", " ", m.group(0))
    s = re.sub(r"\s+", " ", s).strip()
    if s:
        print(s)
PY
echo "===== CHECKSUM FILE ====="
curl -fsS --http1.1 --max-time 40 -A 'Mozilla/5.0' -o checksum.txt \
  'https://download.vulnhub.com/checksum.txt' || echo CHECKSUM_FAIL
if [ -f checksum.txt ]; then
  grep -i -n 'game-of-thrones' checksum.txt | head -5 || echo NO_NAME
fi
echo "===== TAR ====="
tar -tf Game-of-Thrones-CTF-1.0.ova | head -10
rm -f page.html
echo VERIFY_DONE
