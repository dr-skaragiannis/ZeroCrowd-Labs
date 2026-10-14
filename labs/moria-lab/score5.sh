#!/bin/bash
docker exec -i moria python - <<'PY'
want = set([21, 22, 25, 80, 323])
for name in ("tcp", "tcp6", "udp", "udp6"):
    path = "/proc/net/" + name
    try:
        lines = open(path).read().splitlines()[1:]
    except IOError:
        continue
    for line in lines:
        parts = line.split()
        addr, port = parts[1].split(":")
        p = int(port, 16)
        if p in want:
            print(name, addr, p, parts[3])
PY
echo ---HTTP---
curl -s -o /dev/null -w "%{http_code}\n" http://127.0.0.1/ http://127.0.0.1/index.php
echo ---MEM---
docker inspect moria --format "{{.HostConfig.Memory}} {{.HostConfig.CapAdd}}"
