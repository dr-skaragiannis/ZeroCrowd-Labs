# VM inventory

Guest: MrRobot. VirtualBox UUID `{f462d51e-6e7b-4b57-8db5-94d23198bbb0}`. Ubuntu 14.04.2 LTS (trusty), kernel `3.13.0-55-generic`. Hostname `linux`. One CPU, 512 MB RAM, 17 GiB disk. Root is ext4 on the first partition. Swap is the second partition.

The OVF NIC was bridged. The registered settings file still attaches slot 0 to the MediaTek Wi-Fi adapter. The session stayed `Unlocking` inside VirtualBox's service, so the NIC was not moved to NatNetwork and the RAW clone was not attached. Listeners below come from unit links and config files. The guest was not booted.

## Listeners

| proto | address | port | process | loopback |
| --- | --- | --- | --- | --- |
| TCP | `0.0.0.0` | 22 | `sshd`, `Port 22`, `PermitRootLogin without-password` | no |
| TCP | `*` | 80 | Bitnami Apache 2.4.16, `Listen 80` | no |
| TCP | `*` | 443 | Bitnami Apache, `Listen 443`, SSL engine on | no |
| TCP | `127.0.0.1` | 3306 | Bitnami MySQL 5.6.26 | yes |

`vsftpd` is installed with `listen_address=127.0.0.1` and `anonymous_enable=NO`, and it is not linked from `rc2.d`. Monit is linked from `rc2.d`. Its HTTP listener is commented out, so it has no listen port. Varnish is present and is not part of the default `ctlscript.sh start` from the init script's no-argument start. No mail listener.

## Users

| name | uid | gid | home | shell | admin |
| --- | --- | --- | --- | --- | --- |
| root | 0 | 0 | /root | /bin/bash | yes |
| robot | 1002 | 1002 | /home/robot | empty | no |
| bloodraven | 1003 | 1003 | /home/bloodraven | /bin/bash | group `admin`, added on the clone |

Service accounts that own application files: `daemon` 1 (`/usr/sbin`, nologin) runs Apache and PHP-FPM, `www-data` 33, `mysql` 1001, `bitnamiftp` 1000 with shell `/bin/bitnami_ftp_false`. The `sudo` and `admin` groups had no members on the original image.

## Sudoers

`root ALL=(ALL) ALL` and `%admin ALL=(ALL) ALL`. `Defaults !lecture,tty_tickets,!fqdn`. `secure_path` includes the Bitnami bin directories. No `NOPASSWD` rules. `visudo -c` succeeded on the clone after the operator drop-in.

## Service packages

| package | version |
| --- | --- |
| openssh-server | 1:6.6p1-2ubuntu2 |
| cron | 3.0pl1-124ubuntu2 |
| sudo | 1.8.9p5-1ubuntu1.1 |
| vsftpd | 3.0.2-1ubuntu2.14.04.1 |
| apache (Bitnami tree) | 2.4.16 |
| php (Bitnami tree) | 5.5.29 |
| mysql (Bitnami tree) | 5.6.26 |
| wordpress stack | 4.3.1-0 |

Apache, PHP, and MySQL are the Bitnami tree under `/opt/bitnami`, not distro packages.

## Web

Vhosts `_default_:80` and `_default_:443`. The prefix config sets the document root to `/opt/bitnami/apps/wordpress/htdocs`. `ServerName localhost:80`. PHP-FPM is defined because `mod_php` is not loaded. Socket `/opt/bitnami/php/var/run/wordpress.sock`. phpMyAdmin is aliased at `/phpmyadmin`.

database name: `bitnami_wordpress`
database user: `bn_wordpress`
database host: `localhost`
database port: `3306`
password: `<redacted>`

Application base URL stored in the guest database: `http://127.0.0.1/wordpress/`. The vhost serves that tree at `/`.

## Databases

Application schema `bitnami_wordpress`. Logical dump: `replica/app.sql`. System schemas `mysql` and `performance_schema` were not dumped. The empty `test` schema was not dumped.

## Cron

`/etc/crontab` runs `cron.hourly`, `cron.daily`, `cron.weekly`, and `cron.monthly`. One extra line, user `bitnami`, runs `/opt/bitnami/stats/agent.bin`. There is no `bitnami` account in `passwd`. No files in `/etc/cron.d`. Package scripts live in `cron.daily`.

## Mail

No mail package and no mail listener. `/var/mail` is empty.

## Sizes

`/opt/bitnami` 851M. `/var` 118M. `/home` 16K. Guest RAM 512 MB. Disk 17 GiB, about 1.92 GiB populated.
