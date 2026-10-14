# VM inventory

Guest was powered off. Listeners below are from unit files and from each container's `hostconfig.json` port bindings, not from a live `ss`.

## OS

Debian 9 (stretch). Hostname `7kingdoms`. Installed kernel module trees `4.9.0-2-amd64` and `4.9.0-3-amd64`. Settings file: 1 CPU, 1512 MB RAM, 12 GiB disk. NIC slot 0 was bridged and is now attached to NAT Network `NatNetwork`.

## Listeners

Host `sshd` listens on port 22. `PermitRootLogin no`. Port and password authentication are left at the package defaults. `rsync` is installed with the daemon disabled. `fail2ban` is installed. `netfilter-persistent` is enabled. No host web server.

The guest also runs Docker Engine `17.05.0~ce`. Nine containers were stopped with the guest and are set to restart with the daemon. Published host ports (empty HostIp, so every interface):

| proto | address | port | process | loopback |
| --- | --- | --- | --- | --- |
| tcp | 0.0.0.0 | 22 | host sshd | no |
| tcp | 0.0.0.0 | 80 | basecamp-winterfell apache | no |
| tcp | 0.0.0.0 | 1337 | rock nginx | no |
| tcp | 0.0.0.0 | 53 | ironislands named | no |
| udp | 0.0.0.0 | 53 | ironislands named | no |
| tcp | 0.0.0.0 | 143 | reach | no |
| tcp | 0.0.0.0 | 3306 | kingslanding mysqld | no |
| tcp | 0.0.0.0 | 5432 | mountainandthevale postgres | no |
| tcp | 0.0.0.0 | 21 | dorne pure-ftpd | no |
| tcp | 0.0.0.0 | 30000-30009 | dorne passive range | no |
| tcp | 0.0.0.0 | 10000 | stormlands | no |

`reach` also exposes 25, 587, and 993, and those are not in port bindings. `dragonglassmine` exposes 22 and has no host port binding. Container networks are `isolated_nw1` through `isolated_nw8`.

## Users

| name | uid | gid | home | shell | admin |
| --- | --- | --- | --- | --- | --- |
| root | 0 | 0 | /root | /bin/bash | yes |
| daenerystargaryen | 1000 | 1000 | /home/daenerystargaryen | /bin/bash | no |
| branstark | 1001 | 1001 | /home/branstark | /bin/bash | no |
| bloodraven | 1002 | 1002 | /home/bloodraven | /bin/bash | yes, operator account added on the clone |

## Sudoers

`root ALL=(ALL:ALL) ALL` and `%sudo ALL=(ALL:ALL) ALL`, with `#includedir /etc/sudoers.d`. The operator account has a mode 440 drop-in. The sudo group was empty before that account was added.

## Service packages

| package | version |
| --- | --- |
| openssh-server | 1:7.4p1-10 |
| sudo | 1.8.19p1-2.1 |
| cron | 3.0pl1-128+b1 |
| fail2ban | 0.9.6-2 |
| rsync | 3.1.2-1 |
| docker-engine | 17.05.0~ce-0~debian-stretch |

The nine service images are not host packages. Their engines (Apache, nginx, BIND, the database servers, pure-ftpd, and the service on port 10000) live in those images.

## Web

Host Apache is not installed. The winterfell container serves port 80 with a default site on `/var/www/html` and a second `*:80` vhost named `winterfell.7kingdoms.ctf` with document root `/var/www/html2`. The rock container serves port 1337 with root `/var/www/gitlist`. Port 10000 is the stormlands container. Those trees were not copied.

## Databases

`kingslanding` publishes MySQL-compatible port 3306. `mountainandthevale` publishes PostgreSQL port 5432. Application schemas were not dumped.

## Cron

`cron.service` is enabled. `/etc/cron.d` is empty. The root crontab has no jobs.

## Mail

No host mail package and no host port 25. The reach container exposes SMTP and submission ports and does not publish them. Only IMAP port 143 is published.

## Sizes

The disk image is 12 GiB. The Docker overlay graph is about 2.9 GiB and was not copied into the replica.
