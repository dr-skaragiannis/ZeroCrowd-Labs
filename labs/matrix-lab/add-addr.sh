#!/bin/bash
set -eu
ip addr add 10.88.10.12/32 dev eth0 || true
python3 - <<'PY'
from pathlib import Path
p = Path("/etc/wsl.conf")
text = p.read_text() if p.exists() else ""
if "10.88.10.12" not in text and "command =" in text:
    text = text.replace("command = ", "command = ip addr add 10.88.10.12/32 dev eth0 || true; ", 1)
    p.write_text(text)
print(p.read_text())
PY
grep -q '10.88.10.12 matrix' /etc/hosts || echo '10.88.10.12 matrix' >> /etc/hosts
echo ADDR_OK
