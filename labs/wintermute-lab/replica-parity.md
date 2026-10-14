# Replica parity

Replica status: built

Two containers on bridge `172.31.12.0/24`. `straylight` is `172.31.12.10`, memory cap 512m, published on `10.88.10.13` ports 80, 3000, and 25. `neuromancer` is `172.31.12.20`, memory cap 512m, published on `10.88.10.14` ports 34483, 8080, and 8009. The guests were not booted. Listener facts for the guests come from unit files and server configuration.

| Area | VM | Replica | Status | Gap |
| --- | --- | --- | --- | --- |
| Listening ports | Straylight 80, 25, 3000, and loopback 3306, 6379, 161. Neuromancer 34483, 8080, 8009, and loopback 8005 | the same binds, from `ss` and `/proc/net/tcp` | partial | ntopng capture interfaces are eth0 and lo. lxd and snapd are not installed. Live `ss` on the guests was not collected |
| Localhost-only services unpublished | MariaDB, Redis, SNMP, and the Tomcat shutdown port | those ports are absent from Compose | pass | |
| Package versions | Debian 9 and Ubuntu 16.04 revisions listed in the inventory. JDK 1.8.0_171. Tomcat 9.0.0.M26 | JDK and the Tomcat tree match. Cron on Neuromancer matches. Archive revisions are newer for Apache, PHP, MariaDB, Postfix, Redis, SNMP, Straylight cron, OpenSSH, and sudo | partial | Snapshot pins were not applied |
| Users | wintermute, turing-police, ta, lady3jane, root, bloodraven | same uids, gids, and shells | pass | |
| Sudoers | operator drop-in on both. Neuromancer also has root and `%sudo` | `visudo -c` parsed OK on both | pass | |
| Vhosts | Apache `*:80` root `/var/www/html`. Tomcat webapps as shipped | the same roots | pass | |
| Web paths | those HTTP servers | `http://10.88.10.13/` returned 200, `http://10.88.10.13:3000/` returned 302, `http://10.88.10.14:8080/` returned 200 | pass | |
| Databases | MariaDB with no application schema. PostgreSQL installed and not enabled. Neuromancer has none | MariaDB on 127.0.0.1:3306 and no application schema. No PostgreSQL | pass | |
| Cron | PHP session clean. Neuromancer root line every 3 minutes | `/etc/cron.d/php` and the same root line | pass | |
| Mail | Postfix 3.1.8-0+deb9u1 on port 25. Neuromancer has no mail listener | Postfix 3.1.15-0+deb9u1 on port 25. Neuromancer has no mail listener | partial | Postfix revision differs |
| Application URL | the two HTTP roots and ntopng | all three URLs answered | pass | |

## Explicit gaps
- Version substitution: Debian archive revisions and Ubuntu archive revisions are newer than the guest package strings. The JDK and Tomcat trees are the guest copies.
- Archive apt: yes. Stretch uses `archive.debian.org`. Xenial is still on `archive.ubuntu.com` (`old-releases.ubuntu.com` returned 404). `Check-Valid-Until` is false. `trusted=yes` was not required.
- Second kernel: no, the containers share the host kernel. WSL kernel 6.18.54.1-microsoft-standard-WSL2. Guest kernels 4.9.0-6-amd64 and 4.4.0-116-generic.
- Other: supervisord in place of systemd. Memory cap 512m, guest allocation 1024 MB on each. Straylight's two host-only networks were not recreated. A Windows route to 10.88.10.13 and 10.88.10.14 was not added. The addresses answer from the WSL engine host. PostgreSQL on Straylight was not enabled and was not copied.
