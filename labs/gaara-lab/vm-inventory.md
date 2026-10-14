# VM inventory

Guest: Gaara. VirtualBox UUID `{67ae4ff3-2fb6-45df-b93a-d05d4d078faf}`. Powered off. Debian 10 (buster), kernel 4.19.0-13-amd64. Hostname `Gaara`. One CPU, 1024 MB RAM, 8 GiB disk. Root is ext4. The enabled NIC was bridged; the settings file now attaches slot 0 to NatNetwork. The bridged network was not recreated.

Listeners below come from unit links and config files. The guest was not booted.

## Listeners

| Bind | Program | Scope |
| --- | --- | --- |
| `0.0.0.0:22` TCP | `ssh.service`, `sshd_config` leaves port 22 and password authentication at their defaults, `PermitRootLogin` stays `prohibit-password` | non-loopback |
| `*:80` TCP | `apache2.service`, `Listen 80`, site `000-default` | non-loopback |

`Listen 443` is inside the SSL module block, and that module is not enabled. No database listener. No mail listener.

## Users

| name | uid | gid | home | shell |
| --- | --- | --- | --- | --- |
| root | 0 | 0 | /root | /bin/bash |
| gaara | 1001 | 1001 | /home/gaara | /bin/bash |

The `sudo` group has no members on the original image. The operator account was added on the RAW clone only. That clone was not attached back, because the settings change never returned, so the registered disk is still the original VMDK.

## Sudoers

`root ALL=(ALL:ALL) ALL` and `%sudo ALL=(ALL:ALL) ALL`. `#includedir /etc/sudoers.d`. `visudo -c` succeeded on the clone after the operator drop-in.

## Service packages

| package | version |
| --- | --- |
| apache2 | 2.4.38-3+deb10u4 |
| openssh-server | 1:7.9p1-10+deb10u2 |
| cron | 3.0pl1-134+deb10u1 |
| anacron | 2.3-28 |
| sudo | 1.8.27-1+deb10u2 |

No PHP, database, or mail package.

## Web

One vhost, `*:80`, document root `/var/www/html`, `ServerName` commented out. Files: `index.html`, `iamGaara`, `Temari`, `Kazekage`, `Cryoserver`. Application URL: `http://<host>/` on port 80.

## Databases

None.

## Cron

`cron.service` and `anacron.service` are enabled. `/etc/cron.d/anacron` is the package file. No user crontab.

## Mail

No mail configuration and no mail listener.

## Sizes

Disk image 8 GiB. Guest RAM 1024 MB.
