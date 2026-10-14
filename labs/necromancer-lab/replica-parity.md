# Replica parity

Replica status: built and running.

Container `necromancer`, image `necromancer-lab`, compose project `necromancer-lab`. Address `172.31.14.10` on `172.31.14.0/24`. Memory `402653184` bytes (384 MiB). The only published port is `10.88.10.15:22->22/tcp`. `http://127.0.0.1/` inside the container returns 200. `http://10.88.10.15/` from the WSL host does not connect.

| Area | VM | Replica | Status | Gap |
| --- | --- | --- | --- | --- |
| Listening ports | sshd `0.0.0.0:22`, httpd `127.0.0.1:80`, snmp `127.0.0.1:161` UDP, Python `127.0.0.1:666` UDP | the same four binds; sshd also on `[::]:22` | pass | Guest list is from config. The guest was not booted. |
| Localhost-only services unpublished | 80, 161, and 666 are loopback | those three are absent from the published ports | pass | |
| Package versions | OpenBSD 5.9 pkg and base | Debian 11: openssh `1:8.4p1-5+deb11u7`, nginx `1.18.0-6.1+deb11u8`, snmpd `5.9+dfsg-4+deb11u3`, python2.7 `2.7.18-8+deb11u1`, sudo `1.9.5p2-3+deb11u4`, cron `3.0pl1-137` | partial | A BSD guest cannot be the Docker base image on this Linux engine. |
| Users | root and demonslayer, both `/bin/ksh` | both, plus operator uid 1001 shell `/bin/ksh` | pass | The operator account is only in the replica. |
| Sudoers | `root ALL=(ALL) SETENV: ALL` | that rule, plus the operator rule; `visudo -c` OK | pass | |
| Vhosts | OpenBSD httpd, `default`, `127.0.0.1:80`, root `/htdocs` | nginx, same bind and root | partial | nginx stands in for OpenBSD httpd. |
| Web paths | `index.html`, `pics/`, and the two child directories | the same tree under `/var/www/htdocs` | pass | |
| Databases | none | none | pass | |
| Cron | root minute script plus base periodic lines | the minute line is installed; `newsyslog` and `/etc/daily` are not in the image | partial | The added job is present. The base maintenance programs are not. |
| Mail | smtpd off, no listener | no port 25 | pass | |
| Application URL | `http://127.0.0.1/` | 200 from inside the container | pass | The URL stays on loopback. |

## Explicit gaps

- Version substitution: Debian 11 for OpenBSD 5.9. nginx for OpenBSD httpd. Python 2.7.18 for 2.7.11. net-snmp 5.9 for 5.7.3p6.
- Archive apt: yes. `archive.debian.org` bullseye, bullseye-updates, and bullseye-security, with `Acquire::Check-Valid-Until "false"`. `trusted=yes` was not required.
- Second kernel: no. The container uses the WSL kernel, not OpenBSD 5.9 GENERIC.
- Other: supervisord in place of OpenBSD rc. Memory 384 MiB against a 512 MB guest. The original host-only network was not recreated. The boot script's packet filter is not loaded. The guest disk was not modified. Docker's resolver on `127.0.0.11` is unpublished and is not a guest service. PHP is installed on the guest and is not started. No Windows route was added for `10.88.10.15`; that address is on the WSL interface.
