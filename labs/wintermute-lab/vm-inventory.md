# VM inventory

The archive contains two guests. Straylight is the dual-homed Debian system. Neuromancer is the Ubuntu system that the setup notes place on Straylight's second network. Neither guest was booted. VirtualBox `modifyvm` wrote the NAT Network attachment and then did not return, and those clients were left running so the other guests would stay up. Listener facts come from unit files and server configuration.

## Straylight

### OS
Debian 9 (stretch). Kernel package 4.9.0-6-amd64. RAM 1024 MB. Two NICs. The appliance shipped them as host-only adapters on two different networks. Both are now attached to NatNetwork.

### Listeners
| proto | address | port | process | loopback |
| --- | --- | --- | --- | --- |
| tcp | 0.0.0.0 | 80 | apache2 | no |
| tcp | 0.0.0.0 | 25 | postfix | no |
| tcp | 0.0.0.0 | 3000 | ntopng | no |
| tcp | 127.0.0.1 | 3306 | mariadb | yes |
| tcp | 127.0.0.1 | 6379 | redis-server | yes |
| udp | 127.0.0.1 | 161 | snmpd | yes |

PostgreSQL 9.6 is installed and its data directory exists. Its unit is not enabled. There is no SSH server.

### Users
| name | uid | gid | home | shell | admin |
| --- | --- | --- | --- | --- | --- |
| root | 0 | 0 | /root | /bin/bash | yes |
| wintermute | 1000 | 1000 | /home/wintermute | /bin/bash | no |
| turing-police | 1001 | 1001 | /home/turing-police | /bin/bash | no |
| bloodraven | 1002 | 1002 | /home/bloodraven | /bin/bash | yes |

`www-data` is uid 33. The guest had no sudo package. The operator drop-in was added on the disk clone.

### Sudoers
`/etc/sudoers.d/bloodraven`:

```
bloodraven ALL=(ALL:ALL) ALL
```

### Service packages
| package | version |
| --- | --- |
| apache2 | 2.4.25-3+deb9u4 |
| php7.0 | 7.0.27-0+deb9u1 |
| mariadb-server-10.1 | 10.1.26-0+deb9u1 |
| postfix | 3.1.8-0+deb9u1 |
| redis-server | 3:3.2.6-1 |
| snmpd | 5.7.3+dfsg-1.7 |
| cron | 3.0pl1-128+deb9u1 |

ntopng is `/usr/local/bin/ntopng` with docs under `/usr/local/share/ntopng`. It is not a deb.

### Web
Default vhost `*:80`, document root `/var/www/html`, no ServerName. ntopng HTTP is `0.0.0.0:3000`. MariaDB has no application schema. password: not present.

### Databases
No application schema. MariaDB system schemas were not dumped. PostgreSQL was not enabled.

### Cron
`/etc/cron.d/php` session cleanup. No user crontab. `bolo.service` and `free.service` curl the local web root on a timer. They are not listeners.

### Mail
postfix, `inet_interfaces = all`, smtp on port 25. No submission service.

## Neuromancer

### OS
Ubuntu 16.04.4 LTS (xenial). Kernel package 4.4.0-116-generic. RAM 1024 MB. The enabled NIC is slot 1. It shipped as a host-only adapter and is now on NatNetwork. Root is LVM `neuromancer-vg/root`.

### Listeners
| proto | address | port | process | loopback |
| --- | --- | --- | --- | --- |
| tcp | 0.0.0.0 | 34483 | sshd | no |
| tcp | 0.0.0.0 | 8080 | tomcat | no |
| tcp | 0.0.0.0 | 8009 | tomcat AJP | no |
| tcp | 127.0.0.1 | 8005 | tomcat shutdown | yes |

`lxd` and `snapd` are enabled. Their ports were not observed.

### Users
| name | uid | gid | home | shell | admin |
| --- | --- | --- | --- | --- | --- |
| root | 0 | 0 | /root | /bin/bash | yes |
| ta | 1000 | 1000 | /home/ta | /bin/bash | no |
| lady3jane | 1001 | 1001 | /home/lady3jane | /bin/bash | no |
| bloodraven | 1002 | 1002 | /home/bloodraven | /bin/bash | yes |

### Sudoers
`root ALL=(ALL:ALL) ALL` and `%sudo ALL=(ALL:ALL) ALL`. The sudo group was empty before the operator was added.

`/etc/sudoers.d/bloodraven`:

```
bloodraven ALL=(ALL:ALL) ALL
```

`PermitRootLogin prohibit-password`. SSH password authentication is the default.

### Service packages
| package | version |
| --- | --- |
| openssh-server | 1:7.2p2-4ubuntu2.4 |
| sudo | 1.8.16-0ubuntu1.5 |
| cron | 3.0pl1-128ubuntu2 |

Tomcat 9.0.0.M26 and JDK 1.8.0_171 are trees under `/usr/local/tomcat` and `/usr/lib/jvm/jdk1.8.0_171`, started as user `ta`.

### Web
No Apache vhost. Tomcat HTTP 8080 and AJP 8009. Webapps are the stock Tomcat tree plus `struts2_2.3.15.1-showcase`. No database name, user, host, or port. password: not present.

### Databases
No database server is enabled.

### Cron
Root crontab: `*/3 * * * * /bin/bash /home/lady3jane/server-check.sh`. That script file is not on the disk. `/etc/cron.d` also has `mdadm` and `popularity-contest`.

### Mail
No mail-transfer listener.

### Sizes
Straylight disk 5 GiB. Neuromancer disk 5.95 GiB. The Tomcat tree is 58 MB and the JDK tree is 374 MB.
