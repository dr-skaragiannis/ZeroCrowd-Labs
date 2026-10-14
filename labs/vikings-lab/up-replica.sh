#!/bin/bash
set -eu
ip addr add 10.88.10.11/32 dev eth0 || true
python3 - <<'PY'
from pathlib import Path
p = Path("/etc/wsl.conf")
text = p.read_text() if p.exists() else ""
old = "ip addr add 10.88.10.10/32 dev eth0 || true; grep -q raven.local /etc/hosts || echo 10.88.10.10 raven.local >> /etc/hosts"
new = old + "; ip addr add 10.88.10.11/32 dev eth0 || true; grep -q '10.88.10.11 vikings' /etc/hosts || echo 10.88.10.11 vikings >> /etc/hosts"
if "10.88.10.11" not in text:
    text = text.replace(old, new)
    p.write_text(text)
print(p.read_text())
PY
grep -q '10.88.10.11 vikings' /etc/hosts || echo '10.88.10.11 vikings' >> /etc/hosts
cd /mnt/c/Users/bloodraven/Projects/vikings-lab/replica
docker compose up -d
docker compose ps
