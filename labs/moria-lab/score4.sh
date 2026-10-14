#!/bin/bash
set -eu
sed -i "s/\r$//" /mnt/c/Users/bloodraven/Projects/moria-lab/entrypoint.sh
cd /mnt/c/Users/bloodraven/Projects/moria-lab
docker compose build
docker compose up -d --force-recreate
sleep 2
docker exec moria python - <<'PY'
import os
want = {21, 22, 25, 80, 323}
for name in ("tcp", "tcp6", "udp", "udp6"):
    path = "/proc/net/" + name
    if not os.path.exists(path):
        continue
    lines = open(path).read().splitlines()[1:]
    for line in lines:
        parts = line.split()
        addr, port = parts[1].split(":")
        p = int(port, 16)
        if p in want:
            print(name, addr, p, parts[3])
PY
echo ---LOG---
docker logs moria 2>&1 | tail -n 12
