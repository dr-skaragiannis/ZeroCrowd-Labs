# Virtual machine for every lab

Build this once per lab, then follow that lab's `Educational-Module.md`. The machine is one you administer. Use Debian 12 (bookworm), amd64.

## VirtualBox

1. Install VirtualBox from the Oracle site. Create a host-only network if one does not exist: File → Tools → Network Manager → Host-Only Networks → Create. Address `192.168.56.1`, mask `255.255.255.0`. Turn DHCP off on that network so the lab address stays the one in the module.
2. New virtual machine. Type: Linux. Version: Debian (64-bit). RAM and disk size are in the lab module. Disk type VDI, dynamically allocated, at least 16 GB.
3. Settings → System → Motherboard: enable EFI only if you need it. BIOS is enough.
4. Settings → Network:
   - Adapter 1: Host-only, attached to the `192.168.56.0/24` network. This is the address students and your workstation use.
   - Adapter 2: NAT. This adapter is only for `apt` and for downloading WordPress. Do not publish lab services on a bridged adapter.
5. Settings → Storage: attach the Debian 12 netinst ISO from [debian.org/download](https://www.debian.org/download). Choose the amd64 small installation image.
6. Start the machine. In the installer, set the hostname given in the lab module. Create one account you will use for `sudo` (the modules use `bloodraven` for that role; you can create it here). When the task selector appears, enable **SSH server** and **standard system utilities**. Leave a desktop unselected so the small RAM sizes stay usable. Browse the sites from your workstation.

The installer gets an address on the NAT adapter by DHCP. That is expected. You set the host-only address after the first boot.

## Host-only address

Log in on the console. List the interfaces:

```bash
ip -br addr
```

The NAT interface usually has an address in `10.0.2.0/24`. The host-only interface has no address yet, or an address outside that range. Write the host-only interface name down as `IFACE`. Replace `IFACE` and the address below. The address comes from the lab module.

```bash
sudo tee /etc/network/interfaces.d/hostonly.conf >/dev/null <<EOF
auto IFACE
iface IFACE inet static
    address 192.168.56.11
    netmask 255.255.255.0
EOF
sudo systemctl restart networking || sudo ifup IFACE
ip -br addr
```

From the workstation, `ping 192.168.56.11` should answer. `apt-get update` on the virtual machine should also succeed, because the NAT adapter still has a route to the internet. If `apt` fails, check that Adapter 2 is still NAT and that `ip route` shows a default route.

## Copy the lab folder

On the workstation, copy that lab's `resources` directory. Raven is the example. Change the lab name and the address.

```powershell
scp -r C:\Users\bloodraven\Projects\ZeroCrowd-Labs\labs\raven-lab\resources bloodraven@192.168.56.11:/home/bloodraven/resources
```

On the virtual machine:

```bash
sudo mkdir -p /opt/student-resources
sudo cp -a "$HOME/resources/." /opt/student-resources/
sudo chmod -R a+rX /opt/student-resources
```

Passwords you set with `passwd` stay on the machine. Do not put them in the hand-in.
