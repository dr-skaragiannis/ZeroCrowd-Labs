# Replica parity

Replica status: built and running.

Compose project `got-lab`, image `got-lab`, nine containers on `172.31.16.0/24`. Published address `10.88.10.17`. Memory caps total 1408 MiB (256+128×6+192×2), under the guest's 1512 MB. `http://10.88.10.17/` returns 200.

| Area | VM | Replica | Status | Gap |
| --- | --- | --- | --- | --- |
| Listening ports | host ssh 22; published 80, 1337, 53/tcp, 53/udp, 143, 3306, 5432, 21, 30000-30009, 10000 | the same port numbers on `10.88.10.17`; 22, 80, 1337, 53, 143, 3306, 5432, 21, and 10000 accept a connection | partial | Port 10000 is nginx rather than the guest service. 3306 is MariaDB. 143 is dovecot. The guest images were not loaded. The unpublished internal sshd is not running. Passive ports are published and are not bound until a transfer. |
| Localhost-only services unpublished | reach exposes 25, 587, and 993 without host bindings; dragonglassmine exposes 22 with no host binding | those ports are absent from the compose publish list | pass | |
| Package versions | openssh `1:7.4p1-10`, sudo `1.8.19p1-2.1`, cron `3.0pl1-128+b1`, fail2ban `0.9.6-2`, docker-engine `17.05.0~ce` | openssh `1:7.4p1-10+deb9u7`, sudo `1.8.19p1-2.1+deb9u3`, cron `3.0pl1-128+deb9u2`, fail2ban `0.9.6-2`, apache2 `2.4.25-3+deb9u13`, nginx `1.10.3-1+deb9u7`, bind9 `1:9.10.3.dfsg.P4-12.3+deb9u12`, dovecot-imapd `1:2.2.27-3+deb9u7`, mariadb-server `10.1.48-0+deb9u2`, postgresql `9.6+181+deb9u3`, pure-ftpd `1.0.43-3` | partial | fail2ban matches. Archive revisions of OpenSSH, sudo, and cron are newer. docker-engine is not installed. |
| Users | root, daenerystargaryen uid 1000, branstark uid 1001 | the same, plus operator uid 1002 | pass | The operator account is on the clone and in the replica. |
| Sudoers | root, `%sudo`, and an operator drop-in | the same rules, `visudo -c` OK | pass | |
| Vhosts | default `*:80` plus `winterfell.7kingdoms.ctf` on `/var/www/html2` | `apache2ctl -S` shows both | pass | |
| Web paths | guest document trees for ports 80, 1337, and 10000 | placeholder page on `/var/www/html2`; empty `/var/www/gitlist` (HTTP 403); stock page on port 10000 (HTTP 200) | partial | The guest trees were not copied. |
| Databases | published 3306 and 5432 | both ports listen | partial | MariaDB stands in for the guest MySQL image. Application schemas were not dumped. |
| Cron | enabled, no jobs | cron package installed, no jobs | pass | |
| Mail | no host port 25 | no published port 25 | pass | |
| Application URL | port 80 | 200 from `http://10.88.10.17/` | pass | Port 1337 returns 403 and port 10000 returns 200. |

## Explicit gaps

- Version substitution: Debian 9 packages stand in for nine guest images and for docker-engine 17.05. MariaDB stands in for the MySQL image. nginx on port 10000 stands in for that guest service. dovecot stands in for the reach image.
- Archive apt: yes. `archive.debian.org` stretch and `debian-security` `stretch/updates`, with `Acquire::Check-Valid-Until "false"`. `trusted=yes` was not required.
- Second kernel: no. The containers use the WSL kernel, not 4.9.0-3-amd64.
- Other: one process per container instead of docker-engine and systemd. Memory 1408 MiB against a 1512 MB guest. The original bridged NIC was not recreated. The RAW clone was not attached back to the VM. Guest networks `isolated_nw1` through `isolated_nw8` are one bridge, `172.31.16.0/24`. The packet filter was not loaded. No Windows route was added for `10.88.10.17`; that address is on the WSL interface.
