#!/bin/bash
set -eu
python3 - <<'PY'
from pathlib import Path
p = Path("/mnt/c/Users/bloodraven/Projects/mrrobot-lab/replica/shadow-users.txt")
data = p.read_bytes()
print("bytes", len(data))
print("cr", data.count(b"\r"))
print("lines", data.count(b"\n"))
print("names", [line.split(b":", 1)[0].decode() for line in data.splitlines() if line])
PY
find /mnt/c/Users/bloodraven/Projects/mrrobot-lab/replica/bitnami -name 'bitnami_ftp_false' -o -name 'bitnami_ftp_false*' | head
