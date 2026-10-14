#!/bin/bash
set -eu
umount /mnt/straylight || true
umount /mnt/neuromancer || true
vgchange -an neuromancer-vg || true
losetup -d /dev/loop0 || true
losetup -d /dev/loop1 || true
echo UNMOUNTED
# addresses
python3 - <<'PY'
from pathlib import Path
p = Path("/etc/wsl.conf")
text = p.read_text()
extra = "ip addr add 10.88.10.13/32 dev eth0 || true; ip addr add 10.88.10.14/32 dev eth0 || true; grep -q '10.88.10.13 straylight' /etc/hosts || echo 10.88.10.13 straylight >> /etc/hosts; grep -q '10.88.10.14 neuromancer' /etc/hosts || echo 10.88.10.14 neuromancer >> /etc/hosts; "
if "10.88.10.13/32" not in text:
    text = text.replace("command = ", "command = " + extra, 1)
    p.write_text(text)
print("WSL_CONF_OK")
PY
ip addr add 10.88.10.13/32 dev eth0 || true
ip addr add 10.88.10.14/32 dev eth0 || true
grep -q '10.88.10.13 straylight' /etc/hosts || echo '10.88.10.13 straylight' >> /etc/hosts
grep -q '10.88.10.14 neuromancer' /etc/hosts || echo '10.88.10.14 neuromancer' >> /etc/hosts
ip -4 addr show eth0 | awk '/10.88.10.1/ {print}'
