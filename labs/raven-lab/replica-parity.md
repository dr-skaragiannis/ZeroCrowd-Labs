# Replica parity

Replica status: built

Compared 13 Oct 2026. Guest facts are in `vm-inventory.md`. Replica is container `raven` at 172.30.10.10, image `raven-lab`, memory cap 512m.

| Area | VM | Replica | Status | Gap |
| --- | --- | --- | --- | --- |
| Listening ports | ssh 22, http 80, mysql 3306, sendmail 25 and 587, rpcbind 111, rpc.statd | same listeners, including rpc.statd | pass | |
| Localhost-only services unpublished | 3306, 25, 587 | same binds, absent from published ports | pass | |
| Package versions | Debian 8.11, Apache 2.4.10-10+deb8u12, PHP 5.6.36+dfsg-0+deb8u1, MySQL 5.5.60-0+deb8u1, OpenSSH 1:6.7p1-5+deb8u4, Sendmail 8.14.4-8+deb8u2, cron 3.0pl1-127+deb8u1, sudo 1.8.10p3-1+deb8u5 | same version strings | pass | |
| Users | root, michael, steven, bloodraven | same names, uids, and shells | pass | |
| Sudoers | root, %sudo, steven python, bloodraven | same four rules | pass | |
| Vhosts | *:80 raven.local, /var/www/html | *:80 raven.local, /var/www/html | pass | |
| Web paths | /var/www/html including wordpress | same tree, homepage and /wordpress/ return 200 | pass | |
| Databases | schema wordpress on MySQL 5.5.60, host localhost | schema wordpress on MySQL 5.5.60, host localhost | pass | |
| Cron | cron, root @reboot sendmail, cron.d php5 and sendmail | same crontab line and both cron.d files | pass | |
| Mail | Sendmail 8.14.4 on 127.0.0.1:25 and :587 | same package and listeners | pass | |
| Application URL | http://raven.local/wordpress on port 80 | http://raven.local/wordpress/ returns 200 | pass | |

## Explicit gaps
- Version substitution: none
- Archive apt: yes, snapshot.debian.org and archive.debian.org with trusted=yes
- Second kernel: no, container shares the WSL kernel (6.18.40.1) rather than 3.16.0-6-amd64
- Other: supervisord in place of sysv init; memory cap equals the 512 MB guest; web and SSH are published on 10.88.10.10 ports 80 and 22
