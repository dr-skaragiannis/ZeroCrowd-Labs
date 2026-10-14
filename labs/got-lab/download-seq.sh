#!/bin/bash
set -eu
cd /mnt/c/Users/bloodraven/Projects/got-lab
python3 - << 'PY'
import hashlib, subprocess, time
from pathlib import Path

url = "https://download.vulnhub.com/gameofthrones/Game-of-Thrones-CTF-1.0.ova"
size = 2506974720
chunk = 8 * 1024 * 1024
parts = Path("/mnt/c/Users/bloodraven/Projects/got-lab/parts")
parts.mkdir(exist_ok=True)
for p in parts.glob("*.tmp"):
    p.unlink()
n = (size + chunk - 1) // chunk
for i in range(n):
    start = i * chunk
    end = min(start + chunk, size) - 1
    want = end - start + 1
    path = parts / f"{i:04d}"
    if path.exists() and path.stat().st_size == want:
        continue
    tmp = parts / f"{i:04d}.tmp"
    cmd = [
        "curl", "-fsS", "--http1.1", "--retry", "6", "--retry-delay", "3",
        "--max-time", "90", "-A", "Mozilla/5.0",
        "-r", f"{start}-{end}", "-o", str(tmp), url,
    ]
    subprocess.check_call(cmd)
    if tmp.stat().st_size != want:
        tmp.unlink(missing_ok=True)
        raise SystemExit(f"short {i}")
    tmp.replace(path)
    if (i + 1) % 10 == 0 or i + 1 == n:
        print(f"PARTS {i+1}/{n}", flush=True)
    time.sleep(0.2)

out = Path("/mnt/c/Users/bloodraven/Projects/got-lab/Game-of-Thrones-CTF-1.0.ova")
h = hashlib.md5()
s = hashlib.sha1()
total = 0
with out.open("wb") as dest:
    for i in range(n):
        data = (parts / f"{i:04d}").read_bytes()
        if i == 0:
            print("HEAD", data[:20], flush=True)
        dest.write(data)
        h.update(data)
        s.update(data)
        total += len(data)
print("SIZE", total, flush=True)
print("MD5", h.hexdigest(), flush=True)
print("SHA1", s.hexdigest(), flush=True)
PY
echo DOWNLOAD_DONE
