#!/bin/bash
set -eu
echo SECURE
grep ttyS0 /mnt/moria/etc/securetty || true
echo GETTY
ls -l /mnt/moria/etc/systemd/system/getty.target.wants/ || true
echo BOOT
mountpoint /mnt/moria/boot || mount /dev/loop0p1 /mnt/moria/boot
python3 - <<'PY'
p="/mnt/moria/boot/grub2/grub.cfg"
text=open(p).read()
out=[]
n=0
for line in text.splitlines(True):
    stripped=line.lstrip()
    if (stripped.startswith("linux16") or stripped.startswith("linuxefi") or stripped.startswith("linux ")) and "console=ttyS0" not in line:
        line=line.rstrip("\n")+" console=ttyS0,115200\n"
        n+=1
    out.append(line)
open(p,"w").write("".join(out))
print("KERNEL_LINES", n)
PY
