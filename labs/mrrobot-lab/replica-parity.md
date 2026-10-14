# Replica parity

Replica status: built and running.

Container `mrrobot`, image `mrrobot-lab`, compose project `mrrobot-lab`. Address `172.31.17.10` on `172.31.17.0/24`. Memory `402653184` bytes (384 MiB). Published ports are `10.88.10.18:22->22/tcp`, `10.88.10.18:80->80/tcp`, and `10.88.10.18:443->443/tcp`. `http://10.88.10.18/` and `https://10.88.10.18/` return 200.

| Area | VM | Replica | Status | Gap |
| --- | --- | --- | --- | --- |
| Listening ports | sshd `0.0.0.0:22`, Apache `*:80` and `*:443`, MySQL `127.0.0.1:3306` | sshd `*:22` and `[::]:22`, Apache `*:80` and `*:443`, MySQL `127.0.0.1:3306` | pass | Guest list is from config. The guest was not booted. |
| Localhost-only services unpublished | MySQL `127.0.0.1:3306`. vsftpd is installed for `127.0.0.1` and is not in `rc2.d`. phpMyAdmin allows only localhost. | MySQL stays on `127.0.0.1:3306`. vsftpd is not running. phpMyAdmin returns 403 from `10.88.10.18`. Docker resolver `127.0.0.11` is unpublished. | pass | |
| Package versions | openssh `1:6.6p1-2ubuntu2`, cron `3.0pl1-124ubuntu2`, sudo `1.8.9p5-1ubuntu1.1`, vsftpd `3.0.2-1ubuntu2.14.04.1`, Bitnami Apache `2.4.16`, PHP `5.5.29`, MySQL `5.6.26` | openssh `1:6.6p1-2ubuntu2.13`, cron `3.0pl1-124ubuntu2`, sudo `1.8.9p5-1ubuntu1.4`, vsftpd `3.0.2-1ubuntu2.14.04.1`, same Bitnami Apache, PHP, and MySQL strings | partial | cron, vsftpd, and the Bitnami tree match. OpenSSH and sudo are newer archive revisions. |
| Users | root, robot (empty shell), bitnamiftp, mysql | root, robot (`/bin/sh`), bitnamiftp (`/bin/false`), mysql, operator uid 1003 | partial | The operator account is on the clone and in the replica. `robot` and `bitnamiftp` shells differ from the guest fields. |
| Sudoers | root and `%admin` | the same rules, operator in group `admin`, `visudo -c` OK | pass | |
| Vhosts | `_default_:80` and `_default_:443`, document root moved to the WordPress tree, phpMyAdmin at `/phpmyadmin` for localhost | the same files | pass | |
| Web paths | Bitnami WordPress tree under `/opt/bitnami` | the same tree, homepage 200 on port 80 and 443 | pass | |
| Databases | `bitnami_wordpress` on MySQL 5.6.26 | the same schema and server version | pass | |
| Cron | package crontab plus the Bitnami stats line | the same line | pass | The guest has no `bitnami` account for that line. The replica keeps that fact. |
| Mail | none | no port 25 | pass | |
| Application URL | stored `http://127.0.0.1/wordpress/`; the vhost serves the tree at `/` | stored `http://10.88.10.18/`, HTTP 200 | partial | The stored URL was pointed at the published address. |

## Explicit gaps

- Version substitution: OpenSSH `1:6.6p1-2ubuntu2.13` for `1:6.6p1-2ubuntu2`, sudo `1.8.9p5-1ubuntu1.4` for `1.8.9p5-1ubuntu1.1`. cron, vsftpd, and the Bitnami Apache, PHP, and MySQL strings match.
- Archive apt: yes. `old-releases.ubuntu.com` returned 404 for trusty. The image uses `archive.ubuntu.com` and `security.ubuntu.com` with `Acquire::Check-Valid-Until "false"`. `trusted=yes` was not required.
- Second kernel: no. The container uses the WSL kernel, not `3.13.0-55-generic`.
- Other: supervisord in place of sysv init. Memory 384 MiB against a 512 MB guest. The original bridged NIC was not recreated. The VM session stayed locked, so the RAW clone was not attached and the guest was not booted. Docker's resolver on `127.0.0.11` is unpublished. `10.88.10.18` is on the WSL interface.
