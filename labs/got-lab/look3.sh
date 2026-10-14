#!/bin/bash
set -eu
M=/mnt/got
python3 - << 'PY'
import json
from pathlib import Path
root = Path("/mnt/got/var/lib/docker/containers")
for d in sorted(root.iterdir()):
    cfg = json.loads((d / "config.v2.json").read_text(errors="replace"))
    host = json.loads((d / "hostconfig.json").read_text(errors="replace"))
    name = cfg.get("Name")
    image = cfg.get("Config", {}).get("Image")
    state = cfg.get("State", {})
    running = state.get("Running")
    ports = host.get("PortBindings") or {}
    exposed = list((cfg.get("Config", {}).get("ExposedPorts") or {}).keys())
    net = host.get("NetworkMode")
    print(f"NAME {name} IMAGE {image} RUNNING {running} NET {net}")
    print(" BIND", ports)
    print(" EXPOSE", exposed)
PY
echo "===== DOCKER PKGS ====="
awk -F': ' '
  $1=="Package" {p=$2}
  $1=="Status" {s=$2}
  $1=="Version" && s ~ /install ok installed/ && p ~ /docker/ {print p, $2}
' "$M/var/lib/dpkg/status"
echo "===== GRUB ====="
grep -E 'menuentry |linux ' "$M/boot/grub/grub.cfg" | head -20
echo LOOK3_DONE
