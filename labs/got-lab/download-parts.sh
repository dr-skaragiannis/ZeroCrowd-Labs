#!/bin/bash
set -eu
cd /mnt/c/Users/bloodraven/Projects/got-lab
rm -f Game-of-Thrones-CTF-1.0.ova Game-of-Thrones-CTF-1.0.ova.part
python3 - << 'PY'
import hashlib, os, subprocess
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

url = "https://download.vulnhub.com/gameofthrones/Game-of-Thrones-CTF-1.0.ova"
size = 2506974720
chunk = 8 * 1024 * 1024
parts = Path("/mnt/c/Users/bloodraven/Projects/got-lab/parts")
parts.mkdir(exist_ok=True)
n = (size + chunk - 1) // chunk

def fetch(i):
    start = i * chunk
    end = min(start + chunk, size) - 1
    want = end - start + 1
    path = parts / f"{i:04d}"
    if path.exists() and path.stat().st_size == want:
        return i
    tmp = parts / f"{i:04d}.tmp"
    cmd = [
        "curl", "-fsS", "--http1.1", "--retry", "5", "--retry-delay", "2",
        "--max-time", "90", "-A", "Mozilla/5.0",
        "-r", f"{start}-{end}", "-o", str(tmp), url,
    ]
    subprocess.check_call(cmd, stdout=subprocess.DEVNULL)
    if tmp.stat().st_size != want:
        tmp.unlink(missing_ok=True)
        raise RuntimeError(f"short {i}")
    tmp.replace(path)
    return i

done = 0
with ThreadPoolExecutor(max_workers=4) as pool:
    futures = [pool.submit(fetch, i) for i in range(n)]
    for fut in as_completed(futures):
        fut.result()
        done += 1
        if done % 20 == 0 or done == n:
            print(f"PARTS {done}/{n}", flush=True)

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
