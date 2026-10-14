#!/bin/bash
set -eu
RAW=/mnt/c/Users/bloodraven/Projects/vikings-lab/disk.raw
LOOP=$(losetup -fP --show "$RAW")
vgchange -ay ubuntu-vg
dmsetup mknodes || true
mkdir -p /mnt/vikings
mount /dev/mapper/ubuntu--vg-ubuntu--lv /mnt/vikings
mount "${LOOP}p2" /mnt/vikings/boot
python3 - << 'PY'
from pathlib import Path
p = Path("/mnt/vikings/boot/grub/grub.cfg")
text = p.read_text(errors="replace")
snippet = "serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1\nterminal_input serial console\nterminal_output serial console\n"
if "terminal_output serial" not in text:
    lines = text.splitlines(True)
    # insert after the header comments, before the first menuentry
    out = []
    inserted = False
    for line in lines:
        if not inserted and line.startswith("menuentry"):
            out.append(snippet)
            inserted = True
        out.append(line)
    if not inserted:
        out.insert(0, snippet)
    p.write_text("".join(out))
    print("GRUB_SERIAL_INSERTED")
else:
    print("GRUB_SERIAL_PRESENT")
PY
if ! grep -q '^PermitRootLogin yes' /mnt/vikings/etc/ssh/sshd_config; then
  printf '\nPermitRootLogin yes\n' >> /mnt/vikings/etc/ssh/sshd_config
fi
if [ -f /mnt/vikings/etc/ufw/ufw.conf ]; then
  sed -i 's/^ENABLED=.*/ENABLED=no/' /mnt/vikings/etc/ufw/ufw.conf
  grep '^ENABLED=' /mnt/vikings/etc/ufw/ufw.conf
fi
umount /mnt/vikings/boot
umount /mnt/vikings
vgchange -an ubuntu-vg
losetup -d "$LOOP"
echo SHELL_ACCESS_PREPARED
