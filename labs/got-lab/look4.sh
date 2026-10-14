#!/bin/bash
set -eu
python3 - << 'PY'
import json
from pathlib import Path
root = Path("/mnt/got/var/lib/docker/containers")
for d in sorted(root.iterdir()):
    cfg = json.loads((d / "config.v2.json").read_text(errors="replace"))
    host = json.loads((d / "hostconfig.json").read_text(errors="replace"))
    c = cfg.get("Config", {})
    print("NAME", cfg.get("Name"))
    print(" CMD", c.get("Cmd"))
    print(" ENTRY", c.get("Entrypoint"))
    print(" USER", c.get("User"))
    print(" RESTART", host.get("RestartPolicy"))
PY
echo "===== ENGINE PKG ====="
awk -F': ' '
  $1=="Package" {p=$2}
  $1=="Status" {s=$2}
  $1=="Version" && s ~ /install ok installed/ && p ~ /docker/ {print p, $2}
' /mnt/got/var/lib/dpkg/status
echo "===== DOCKER SIZE ====="
du -sh /mnt/got/var/lib/docker 2>/dev/null || true
echo LOOK4_DONE
