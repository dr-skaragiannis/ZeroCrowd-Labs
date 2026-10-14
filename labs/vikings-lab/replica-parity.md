# Replica parity

Replica status: built

Container `vikings`, image `vikings-lab`, address `172.31.10.10`, memory cap 512m. Web and SSH are published on `10.88.10.11` ports 80 and 22. Loopback port 18812 is not published. `127.0.0.1:80` and `127.0.0.1:22` were already published by another replica, so this replica uses a dedicated address and the guest port numbers.

| Area | VM | Replica | Status | Gap |
| --- | --- | --- | --- | --- |
| Listening ports | tcp 0.0.0.0:80 apache2, tcp 0.0.0.0:22 sshd, tcp 127.0.0.1:18812 python3, tcp/udp 127.0.0.53:53 systemd-resolve, tcp 127.0.0.1:34181 containerd, udp :68 DHCP client | tcp 0.0.0.0:80 apache2, tcp 0.0.0.0:22 sshd, tcp 127.0.0.1:18812 python3 | partial | systemd-resolved is not running. containerd is not running. Port 34181 was not set in a containerd config file. DHCP port 68 is the guest NIC client. |
| Localhost-only services unpublished | 18812, 53, and the containerd port are not on the host | Compose publishes only 10.88.10.11:80 and 10.88.10.11:22. 18812 stays on 127.0.0.1 inside the container | pass | |
| Package versions | apache2 2.4.29-1ubuntu4.16, openssh-server 1:7.6p1-4ubuntu0.5, cron 3.0pl1-128.1ubuntu1, sudo 1.8.21p2-3ubuntu1.4, python3 3.6.7-1~18.04, dma 0.11-1build1, containerd 1.5.2-0ubuntu1~18.04.2, docker.io 20.10.7-0ubuntu1~18.04.1 | The six service rows match those strings. containerd and docker.io are not installed | partial | No container was running on the guest, and containerd had no config file naming its port. |
| Users | root, floki 1000, ragnar 1001, bloodraven 1002 | same uids, homes, and shells; bloodraven in sudo; floki in lxd | pass | |
| Sudoers | root and %sudo ALL, bloodraven ALL, snap secure_path drop-in | `visudo -c` parsed OK, including `/etc/sudoers.d/bloodraven` | pass | |
| Vhosts | *:80, server name unset, document root /var/www/html | *:80, server name unset, document root /var/www/html | pass | |
| Web paths | / , /site/ , and /site/index.html returned 200 | same three paths on http://10.88.10.11 returned 200 | pass | |
| Databases | none | none | pass | |
| Cron | root @reboot python3 /usr/local/bin/rpyc_classic.py; cron.d cron-apt, dma, mdadm, popularity-contest | same @reboot line and the same four cron.d files | pass | |
| Mail | dma 0.11-1build1, ports 25 and 587 not listening | dma 0.11-1build1, ports 25 and 587 not listening | pass | |
| Application URL | http://127.0.0.1/site/ returned 200 | http://10.88.10.11/site/ returned 200 | pass | |

## Explicit gaps
- Version substitution: containerd and docker.io are not in the replica. The apache, ssh, cron, sudo, python3, and dma version strings match.
- Archive apt: yes. `old-releases.ubuntu.com` returned 404 for bionic. The image uses `archive.ubuntu.com`, one `snapshot.ubuntu.com` timestamp (20230301T030400Z) for OpenSSH 1:7.6p1-4ubuntu0.5, and Launchpad librarian debs for Apache 2.4.29-1ubuntu4.16 and sudo 1.8.21p2-3ubuntu1.4. `Acquire::Check-Valid-Until` is false. `trusted=yes` was not required.
- Second kernel: no, container shares the host kernel. WSL kernel 6.18.54.1-microsoft-standard-WSL2, guest kernel 4.15.0-154-generic.
- Other: supervisord in place of systemd. Memory cap 512m, guest allocation 1024 MB. A Windows route to 10.88.10.11 was not added because that command requires elevation. The address answers from the WSL engine host.
