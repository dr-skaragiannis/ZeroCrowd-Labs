#!/bin/bash
set -eu
python3 - << 'PY'
import json
from pathlib import Path
root = Path("/mnt/got/var/lib/docker/containers")
for d in sorted(root.iterdir()):
    cfg = json.loads((d / "config.v2.json").read_text(errors="replace"))
    gd = cfg.get("GraphDriver", {}).get("Data", {})
    print("NAME", cfg.get("Name"))
    print(" UPPER", gd.get("UpperDir"))
    print(" LOWER", (gd.get("LowerDir") or "")[:180])
print("--- REPOS ---")
text = Path("/mnt/got/var/lib/docker/image/overlay2/repositories.json").read_text(errors="replace")
print(text[:2000])
PY
echo LOOK5_DONE
