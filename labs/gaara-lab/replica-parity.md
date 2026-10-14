# Replica parity

Replica status: built and running.

Container `gaara`, image `gaara-lab`, compose project `gaara-lab`. Address `172.31.15.10` on `172.31.15.0/24`. Memory `536870912` bytes (512 MiB). Published ports are `10.88.10.16:22->22/tcp` and `10.88.10.16:80->80/tcp`. `http://10.88.10.16/` returns 200.

| Area | VM | Replica | Status | Gap |
| --- | --- | --- | --- | --- |
| Listening ports | sshd `0.0.0.0:22`, apache `*:80` | sshd `0.0.0.0:22` and `[::]:22`, apache `0.0.0.0:80` | pass | Guest list is from config. The guest was not booted. |
| Localhost-only services unpublished | none | Docker resolver `127.0.0.11` is unpublished | pass | |
| Package versions | apache2 `2.4.38-3+deb10u4`, openssh `1:7.9p1-10+deb10u2`, cron `3.0pl1-134+deb10u1`, anacron `2.3-28`, sudo `1.8.27-1+deb10u2` | apache2 `2.4.59-1~deb10u1`, openssh `1:7.9p1-10+deb10u4`, cron `3.0pl1-134+deb10u1`, anacron `2.3-28`, sudo `1.8.27-1+deb10u6` | partial | cron and anacron match. The archive security revisions of apache, OpenSSH, and sudo are newer. |
| Users | root and gaara, both `/bin/bash` | both, plus operator uid 1002 | pass | The operator account is on the clone and in the replica. |
| Sudoers | root and `%sudo` | the same rules, operator in group `sudo`, `visudo -c` OK | pass | |
| Vhosts | `*:80`, root `/var/www/html`, no ServerName | the same default site | pass | |
| Web paths | `index.html`, `iamGaara`, `Temari`, `Kazekage`, `Cryoserver` | the same names and sizes | pass | |
| Databases | none | none | pass | |
| Cron | `cron.d/anacron`, no user crontab | the same | pass | |
| Mail | none | no port 25 | pass | |
| Application URL | `http://<host>/` on port 80 | 200 from `http://10.88.10.16/` | pass | |

## Explicit gaps

- Version substitution: apache2 `2.4.59-1~deb10u1` for `2.4.38-3+deb10u4`, OpenSSH `deb10u4` for `deb10u2`, sudo `deb10u6` for `deb10u2`. cron and anacron match.
- Archive apt: yes. `archive.debian.org` buster, buster-updates, and `debian-security` `buster/updates`, with `Acquire::Check-Valid-Until "false"`. `trusted=yes` was not required.
- Second kernel: no. The container uses the WSL kernel, not 4.19.0-13-amd64.
- Other: supervisord in place of systemd. Memory 512 MiB against a 1024 MB guest. The original bridged NIC was not recreated. The RAW clone was not attached back to the VM. Docker's resolver on `127.0.0.11` is unpublished. No Windows route was added for `10.88.10.16`; that address is on the WSL interface.
