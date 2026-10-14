---
name: recovering-linux-admin-offline
description: >-
  Recovers local root and sudo on an owned Linux virtual appliance when the
  login password is unknown, by cloning the disk to RAW, parsing partitions,
  and editing the guest filesystem offline. Use when the user asks to reset a
  forgotten guest password, gain local admin on a Linux VM they already own,
  clone a VirtualBox medium, set a root password, add a sudo user with a home
  directory and sudoers entry, set PermitRootLogin, or verify login with a
  serial console (uart tcpserver). Offline disk recovery only; no exploit or
  attack procedure.
---

# Recover Linux admin from an offline disk

## When to use

The operator already owns the virtual appliance and needs a local root or sudo login, and the guest password is unknown. Access is recovered by editing a clone of the powered-off disk.

Use `importing-ova-nat-network` first when the OVA is not registered yet. After login works, use `repairing-eol-apt-archives` if package installs fail, then `inventorying-linux-vm`.

## Related skills

`importing-ova-nat-network`, `repairing-eol-apt-archives`, `inventorying-linux-vm`, `building-docker-vm-replica`, `evaluating-docker-vm-parity`

## Prerequisites

- The operator owns the appliance and is allowed to change its local accounts.
- The VM `<VM_NAME>` is powered off.
- The host can run `VBoxManage` and can mount a Linux filesystem (native Linux or a Linux environment on the same machine).
- `<WORK_DIR>` has room for a full RAW clone.
- The operator chooses `<OPERATOR_PASSWORD>` and `<SUDO_USER>` at runtime. Do not invent a published password, and do not write the password, shadow fields, or hashes into chat, skills, or tickets.

## Procedure

Copy this checklist and update it as you go:

```
Recovery progress:
- [ ] VM powered off
- [ ] Medium cloned to RAW
- [ ] Root filesystem mounted
- [ ] Root password set
- [ ] Sudo user, home, group, and sudoers written
- [ ] SSH root login changed only if SSH is required
- [ ] Clone attached and login verified
```

1. Confirm the VM is powered off and identify its hard-disk medium and storage controller. Edit nothing else.

```
VBoxManage showvminfo "<VM_NAME>" --machinereadable
```

2. Clone that medium to RAW. Leave the original medium file in place until login on the clone is verified.

```
VBoxManage clonemedium disk "<SRC_MEDIUM>" "<WORK_DIR>/disk.raw" --format RAW
```

If `clonemedium` cannot read the source, fall back to `qemu-img convert -O raw "<SRC_MEDIUM>" "<WORK_DIR>/disk.raw"`.

3. Map partitions and find the Linux root filesystem. Prefer kernel partition scan:

```
LOOP=$(sudo losetup -fP --show "<WORK_DIR>/disk.raw")
lsblk -f "$LOOP"
```

Mount the filesystem that contains `/etc/shadow` at `<MOUNT_POINT>`. That filesystem may be ext4 or XFS, and it may be an LVM logical volume under a partition (`vgchange -ay` after the loop is attached). If `losetup` cannot scan the table, read byte offsets from `parted -s "<WORK_DIR>/disk.raw" unit B print` and mount with `mount -o loop,offset=<START_BYTES>`.

On a host that does not create `/dev/mapper` nodes for a foreign volume group, read `lvs -o lv_name,lv_size,lv_kernel_major,lv_kernel_minor` and mount the root LV by that major:minor (`/dev/dm-N` or a `mknod` of the same pair). If `dmsetup` lists the logical volume and `/dev/mapper` still has no node, run `dmsetup mknodes` and mount `/dev/mapper/<vg>-<lv>`. Do not mount a node named `cl-root` until `blkid` shows the root filesystem type. A stale mapper node can point at the swap LV after `vgchange`. Detach only the loop that backs this RAW file. `losetup -D` detaches every loop on the host.

Stop when the filesystem type is `crypto_LUKS` or another full-disk encryption and the operator has no passphrase. Match a separate `/etc` or `/home` mount to the guest `fstab` when those directories are not on the root filesystem.

4. Set the root password inside the mount. Prefer chroot:

```
sudo chroot "<MOUNT_POINT>" chpasswd <<'EOF'
root:<OPERATOR_PASSWORD>
EOF
```

If chroot cannot run because libraries do not match the host, set the root shadow field on the mounted file to a new hash from `openssl passwd`. Match the algorithm prefix already used on that guest (`-6`, `-5`, or `-1`). Replace a locked `!` or `*` field with the new hash. Clear an expired account-expiry field. Set root's shell in `passwd` to `/bin/bash` when it is `nologin` or `false`.

5. Add `<SUDO_USER>` as an interactive admin. Use uid and gid at or above 1000. `<ADMIN_GROUP>` is `sudo` on Debian/Ubuntu and `wheel` on many other distributions.

```
sudo chroot "<MOUNT_POINT>" groupadd -g <GID> <SUDO_USER>
sudo chroot "<MOUNT_POINT>" useradd -u <UID> -g <GID> -G <ADMIN_GROUP> -m -d /home/<SUDO_USER> -s /bin/bash <SUDO_USER>
sudo chroot "<MOUNT_POINT>" chown -R <SUDO_USER>:<SUDO_USER> /home/<SUDO_USER>
echo '<SUDO_USER> ALL=(ALL:ALL) ALL' | sudo tee "<MOUNT_POINT>/etc/sudoers.d/<SUDO_USER>"
sudo chmod 440 "<MOUNT_POINT>/etc/sudoers.d/<SUDO_USER>"
```

`useradd -m` copies `/etc/skel` into the home directory. Check syntax with `visudo -c -f /etc/sudoers.d/<SUDO_USER>` inside the chroot when `visudo` exists. Set `<OPERATOR_PASSWORD>` for this user with `chpasswd` the same way as root.

6. Change SSH only when the later steps need SSH. Prefer the sudo user. Set `PermitRootLogin yes` in the mounted `sshd_config` only when the operator specifically needs root over SSH. If password login is required and `PasswordAuthentication` is off, turn that one setting on and record the change. Leave the daemon unbound to any new public address; this skill only edits the disk.

7. Unmount, detach the loop, and convert the RAW clone back to a VDI. Attach that VDI only to `<VM_NAME>`.

```
sudo umount "<MOUNT_POINT>"
sudo losetup -d "$LOOP"
VBoxManage convertfromraw "<WORK_DIR>/disk.raw" "<WORK_DIR>/disk.vdi" --format VDI
VBoxManage storageattach "<VM_NAME>" --storagectl "<CONTROLLER>" --port <PORT> --device <DEVICE> --medium none
VBoxManage storageattach "<VM_NAME>" --storagectl "<CONTROLLER>" --port <PORT> --device <DEVICE> --type hdd --medium "<WORK_DIR>/disk.vdi"
```

8. Verify through a serial console on this VM only. Enable a guest getty on `ttyS0` before boot when the image has no serial console: a systemd `serial-getty@ttyS0` want, or an inittab getty, plus `console=ttyS0` on the active kernel line.

```
VBoxManage modifyvm "<VM_NAME>" --uart1 0x3F8 4 --uartmode1 tcpserver <HOST_PORT>
VBoxManage startvm "<VM_NAME>" --type headless
```

Connect with `nc 127.0.0.1 <HOST_PORT>` and log in. Pass only the port number to `tcpserver`. A value of `127.0.0.1:<HOST_PORT>` makes this VirtualBox listen on port 127, and a second VM then collides with the first. If the kernel line already contains `console=ttyS0` and the TCP port still receives nothing, the bootloader is using the graphical terminal. Before the first menu entry in `grub.cfg`, set `serial --speed=115200 --unit=0 --word=8 --parity=no --stop=1`, `terminal_input serial console`, and `terminal_output serial console`. A RAW edit made after a VDI was converted is not on that VDI; convert again and attach the new image. If the serial port stays silent after that, use the graphical console for the same login check.

Porteus and other live images keep the writable root in a changes directory over squashfs modules. Edit accounts in that changes tree. Their boot menu is often syslinux, not GRUB. Add `SERIAL 0 115200` at the top of the menu file and `console=ttyS0,115200n8` on the default `APPEND` line, and enable the serial getty in the changes copy of `inittab`.

Do not kill a hung `showvminfo` or `modifyvm`. A killed client can leave that machine locked inside VirtualBox until the service process restarts, and restarting that service interrupts every other running guest. If the settings file on disk already shows the change, leave the client running and keep working from that file.

## Verification

- Root and `<SUDO_USER>` log in with `<OPERATOR_PASSWORD>`.
- `<SUDO_USER>` can run `sudo -l` and the sudoers file passes `visudo -c`.
- The home directory exists and is owned by that user.
- `VBoxManage list vms` matches the pre-change list except for this appliance's disk attachment.

Report that local admin was recovered. Omit the password and every hash.

## Stop conditions

- The operator does not own the appliance, or the disk is not this VM's clone.
- The VM is running. Power it off before cloning; do not edit a live medium.
- The root filesystem cannot be identified, or it is encrypted and no passphrase is available.
- `visudo` reports an error. Fix that file before booting.
- Login still fails after one serial attempt and one graphical attempt. Remount the clone and recheck the shadow field before another boot. Do not switch to an exploit, payload, or online attack.

If the host cannot mount the filesystem read-write, do not invent a password and do not write a partial hash. Leave the clone unchanged, create the operator account in the replica, and record that the guest disk was not modified.
