#!/bin/bash
set -eu
ip addr add 10.88.10.18/32 dev eth0 || true
python3 - <<'PY'
from pathlib import Path
p = Path("/etc/wsl.conf")
text = p.read_text()
needle = "ip addr add 10.88.10.18/32 dev eth0 || true; "
if "10.88.10.18/32" not in text:
    text = text.replace("command = ", "command = " + needle, 1)
    p.write_text(text)
    print("WSL_CONF_UPDATED")
else:
    print("WSL_CONF_ALREADY")
PY
ip -4 addr show eth0 | awk '/10\.88\.10\.18/'
