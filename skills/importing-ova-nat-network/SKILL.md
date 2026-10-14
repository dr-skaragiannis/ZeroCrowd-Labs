---
name: importing-ova-nat-network
description: >-
  Imports one Linux OVA or OVF into VirtualBox, sets --vmname, and attaches
  only that VM's NICs to an existing NAT Network. Use when the user asks to
  import an OVA, OVF, or VulnHub-style appliance, run VBoxManage import
  --dry-run, register a virtual appliance, or set a NIC attachment to
  natnetwork. Leaves every unrelated VM unchanged.
---

# Import an OVA onto an existing NAT Network

## When to use

The operator has a Linux appliance file (`.ova` or `.ovf`) and wants it registered in VirtualBox on a NAT Network that already exists.

Skip this skill when the VM is already registered and only the guest OS needs work. Continue with `recovering-linux-admin-offline` when the login password is unknown, or with `inventorying-linux-vm` when an admin shell already exists.

## Related skills

`recovering-linux-admin-offline`, `repairing-eol-apt-archives`, `inventorying-linux-vm`, `building-docker-vm-replica`, `evaluating-docker-vm-parity`

## Prerequisites

- VirtualBox is installed and `VBoxManage` runs in the operator's shell.
- `<OVA_PATH>` points at a local appliance file the operator owns.
- `<NAT_NETWORK_NAME>` is already listed by VirtualBox. This skill does not create a NAT Network.
- `<VM_NAME>` is a new name chosen for this import only.
- `<WORK_DIR>` is a host folder for the before/after VM lists.

## Procedure

Copy this checklist and update it as you go:

```
Import progress:
- [ ] NAT Network exists
- [ ] VM name is unused
- [ ] Dry-run captured
- [ ] Import finished
- [ ] Only the new VM's NICs use the NAT Network
- [ ] Unrelated VMs unchanged
```

1. Record the current VM list before any change:

```
VBoxManage list vms > "<WORK_DIR>/vms-before.txt"
VBoxManage list natnetworks
```

Stop if `<NAT_NETWORK_NAME>` is absent. Stop if `<VM_NAME>` already appears in the VM list.

2. Dry-run the import and read the suggested name, OS type, disk units, and NIC count. Quote paths that contain spaces. If the appliance is inside a zip that `tar` and Python cannot extract, that zip is using Deflate64. Extract it with 7-Zip, then dry-run the `.ova`. An enabled adapter whose dry-run slot is 1 is `nic2`, even when `nic1` is disabled.

```
VBoxManage import "<OVA_PATH>" --dry-run
```

Apply a network change flag printed by the dry-run only when that flag belongs to this appliance. Ignore suggested edits for any other machine.

3. Import only this appliance. Accept a packaged license prompt only after the operator agrees:

```
VBoxManage import "<OVA_PATH>" --vsys 0 --vmname "<VM_NAME>" --eula accept
```

If the import reports a MAC address collision, rerun that same import with `--options keepallmacs`.

4. While `<VM_NAME>` is powered off, attach each NIC that the appliance enabled to the existing NAT Network. Repeat for nic2 and later only when the dry-run showed that adapter.

```
VBoxManage modifyvm "<VM_NAME>" --nic1 natnetwork --nat-network1 "<NAT_NETWORK_NAME>"
```

The attachment type value is `natnetwork`. Leave disabled adapters disabled. Do not start the VM in this skill.

5. Diff the VM list. The only added line is `<VM_NAME>`.

```
VBoxManage list vms > "<WORK_DIR>/vms-after.txt"
```

## Verification

`VBoxManage showvminfo "<VM_NAME>" --machinereadable` shows `VMState="poweroff"` and, for each enabled adapter, `nicN="natnetwork"` with `nat-networkN="<NAT_NETWORK_NAME>"`.

Compare `vms-before.txt` and `vms-after.txt`. Every previously listed VM keeps the same name and UUID.

## Stop conditions

- Dry-run fails, or it would overwrite an existing disk file.
- `<NAT_NETWORK_NAME>` does not already exist.
- `<VM_NAME>` collides with a registered VM.
- The after list changes any VM other than the one just imported.
- The operator does not own the appliance file.

On a stop, leave unrelated VMs as they were and report the failing command output.

Before import, confirm the file is an appliance. A CDN timeout can return a short error body and a successful curl status. Check the size and the published checksum, and check that the file starts as an OVA or OVF, before `VBoxManage import`.

If the dry-run shows a bridged adapter, attach that same slot to the existing NAT Network. The original bridged network is not recreated. Record that as a gap.

A full GET of a large appliance can return a short body, such as a gateway timeout notice, and still exit 0. Sequential ranges of about 8MB can succeed when the full object times out. Many parallel ranges can make the host return 503, so retry one range at a time and check each part size. Verify the checksum against the publisher checksum list for that filename, not against a guessed catalog id.

If `modifyvm` produces no output and the settings file already shows the NAT Network on that slot, leave that client running. Do not start another `modifyvm` or `storageattach` for the same machine.
