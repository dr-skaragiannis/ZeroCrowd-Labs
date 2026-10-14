# Educational modules

Each lab has its own guide. You build a host you administer, on a virtual machine you own. Adapter 1 is host-only, `192.168.56.0/24`. Adapter 2 is NAT so package installs can reach the network. Choose every password yourself and leave it out of the hand-in.

Site files and pictures are in [resources](resources/README.md). Copy that folder onto the virtual machine before you follow a lab guide. [virtual-machine.md](resources/virtual-machine.md) is the Debian 12 setup shared by every lab.

The guide matches that lab's listeners, accounts, and which ports stay on loopback. It uses current Debian 12 packages. The original version strings stay in `vm-inventory.md`. `PermitRootLogin` is `no` in every student build.

| Lab | Module | Address in the exercise |
| --- | --- | --- |
| raven-lab | [Educational-Module.md](labs/raven-lab/Educational-Module.md) | 192.168.56.11 |
| moria-lab | [Educational-Module.md](labs/moria-lab/Educational-Module.md) | 192.168.56.12 |
| vikings-lab | [Educational-Module.md](labs/vikings-lab/Educational-Module.md) | 192.168.56.13 |
| matrix-lab | [Educational-Module.md](labs/matrix-lab/Educational-Module.md) | 192.168.56.14 |
| wintermute-lab | [Educational-Module.md](labs/wintermute-lab/Educational-Module.md) | 192.168.56.15 and .16 |
| necromancer-lab | [Educational-Module.md](labs/necromancer-lab/Educational-Module.md) | 192.168.56.17 |
| gaara-lab | [Educational-Module.md](labs/gaara-lab/Educational-Module.md) | 192.168.56.18 |
| got-lab | [Educational-Module.md](labs/got-lab/Educational-Module.md) | 192.168.56.19 |
| mrrobot-lab | [Educational-Module.md](labs/mrrobot-lab/Educational-Module.md) | not built |

Hand in, for the lab you built: topology, accounts, `dpkg-query -W` lines, and the verification status codes.
