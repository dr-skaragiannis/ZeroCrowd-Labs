# Replica parity

Replica status: built

Image `moria-lab`, container `moria`, address 172.30.11.10, memory 512m. Web, SSH, and FTP are published on 127.0.0.1 ports 80, 22, and 21.

| Area | VM | Replica | Status | Gap |
| --- | --- | --- | --- | --- |
| Listening ports | sshd 22, httpd 80, vsftpd 21, postfix 25 on loopback, chronyd UDP 323 on loopback | same ports; FTP is IPv4 because the container has no IPv6 | pass | |
| Localhost-only services unpublished | 25 and 323 not on the host | `docker port` shows 21, 22, and 80 only | pass | |
| Package versions | httpd 2.4.6-45.el7.centos, php 5.4.16-42.el7, openssh-server 6.6.1p1-33.el7_3, cronie 1.4.11-14.el7_2.1, postfix 2.10.1-6.el7, vsftpd 3.0.2-21.el7, chrony 2.1.1-4.el7.centos, firewalld 0.4.3.2-8.1.el7_3.2 | `rpm -q` matches those strings | pass | |
| Users | root, abatchy 1000, Balrog 1001 nologin, Ori 1002, bloodraven 1003 in wheel | same uid, gid, home, and shell | pass | |
| Sudoers | root ALL, %wheel ALL | same lines, `visudo -c` parsed OK | pass | |
| Vhosts | none; DocumentRoot /var/www/html; apache uid 48 | `httpd -S` matches; php5_module loaded | pass | |
| Web paths | index, image, and the two nested trees | same paths and byte sizes | pass | |
| Databases | none | mariadb-server and mysql-server absent | pass | |
| Cron | root `*/3` knockknock.sh; cron.d 0hourly and raid-check | same crontab and both cron.d files | pass | |
| Mail | postfix 2.10.1 on 127.0.0.1:25 and ::1:25 | same package and listeners | pass | |
| Application URL | no stored site URL; document root is /var/www/html | http://127.0.0.1/ returns 200 | pass | |

## Explicit gaps

- Version substitution: none for the inventoried service packages. `mariadb-libs` is installed only because postfix links `libmysqlclient`; it is not a database server.
- Archive apt: no. CentOS vault is the equivalent gap: `vault.centos.org/7.3.1611` with `gpgcheck=0`.
- Second kernel: no. The container uses the WSL kernel 6.18.54.1-microsoft-standard-WSL2. The guest kernel is 3.10.0-514.el7.x86_64.
- Other: a shell entrypoint replaces systemd. Memory is capped at 512m; the guest has 1024 MB. Chrony 2.1 needs `CAP_SYS_TIME` because `adjtimex` fails without it. vsftpd `listen=YES` and `background=NO` are container adaptations. firewalld is installed and not started, matching the inventory where it was not a listener.
