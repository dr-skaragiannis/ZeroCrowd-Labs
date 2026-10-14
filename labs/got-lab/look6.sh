#!/bin/bash
set -eu
python3 - << 'PY'
import json
from pathlib import Path
p = Path("/mnt/got/var/lib/docker/containers/12ff38b7af34f45d0b58edcb741d0d33e07b3607754a6839910cbc589a23c20a/config.v2.json")
cfg = json.loads(p.read_text(errors="replace"))
print("KEYS", sorted(cfg.keys()))
def walk(obj, prefix=""):
    if isinstance(obj, dict):
        for k, v in obj.items():
            if k.lower() in {"env", "envconfig"}:
                continue
            walk(v, prefix + "." + k)
    elif isinstance(obj, str) and ("overlay" in obj or "docker/overlay" in obj or obj.startswith("/var/lib/docker")):
        print(prefix, obj[:240])
walk(cfg)
print("NAME", cfg.get("Name"))
PY
echo "===== GRAPH ====="
ls /mnt/got/var/lib/docker
echo LOOK6_DONE
