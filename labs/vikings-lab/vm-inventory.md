# VM inventory

## OS
Ubuntu 18.04 (bionic), kernel 4.15.0-154-generic. Guest RAM 1024 MB. Hostname `vikings`. NIC on NatNetwork, address 10.0.2.49/24 at inventory time.

## Listeners
| proto | address | port | process | loopback |
| --- | --- | --- | --- | --- |
| udp | 127.0.0.53 | 53 | systemd-resolve | yes |
| udp | 10.0.2.49 | 68 | systemd-networkd | no |
| tcp | 127.0.0.1 | 34181 | containerd | yes |
| tcp | 0.0.0.0 | 80 | apache2 | no |
| tcp | 127.0.0.53 | 53 | systemd-resolve | yes |
| tcp | 0.0.0.0 | 22 | sshd | no |
| tcp | 127.0.0.1 | 18812 | python3 | yes |

`containerd` was started as `/usr/bin/containerd` with no `/etc/containerd/config.toml`. Port 34181 is the port that process held at inventory time, not a port named in a config file. `docker ps` was empty. DHCP port 68 is the guest network client.

## Users
| name | uid | gid | home | shell | admin |
| --- | --- | --- | --- | --- | --- |
| root | 0 | 0 | /root | /bin/bash | yes |
| floki | 1000 | 1000 | /home/floki | /bin/bash | no |
| ragnar | 1001 | 1001 | /home/ragnar | /bin/sh | no |
| bloodraven | 1002 | 1002 | /home/bloodraven | /bin/bash | yes |
| www-data | 33 | 33 | /var/www | nologin or equivalent | no |

`sudo` is group 27 and contains bloodraven. `lxd` is group 108 and contains floki. `docker` is group 113 and is empty. A shadow extract for `chpasswd -e` is `replica/shadow-users.txt`.

## Sudoers
```
Defaults	env_reset
Defaults	mail_badpass
Defaults	secure_path="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/snap/bin"
root	ALL=(ALL:ALL) ALL
%admin ALL=(ALL) ALL
%sudo	ALL=(ALL:ALL) ALL
```

`/etc/sudoers.d/99-snapd.conf`:

```
Defaults    secure_path += /snap/bin
```

`/etc/sudoers.d/bloodraven`:

```
bloodraven ALL=(ALL:ALL) ALL
```

## Service packages
| package | version |
| --- | --- |
| apache2 | 2.4.29-1ubuntu4.16 |
| apache2-bin | 2.4.29-1ubuntu4.16 |
| apache2-data | 2.4.29-1ubuntu4.16 |
| openssh-server | 1:7.6p1-4ubuntu0.5 |
| cron | 3.0pl1-128.1ubuntu1 |
| sudo | 1.8.21p2-3ubuntu1.4 |
| python3 | 3.6.7-1~18.04 |
| dma | 0.11-1build1 |
| containerd | 1.5.2-0ubuntu1~18.04.2 |
| docker.io | 20.10.7-0ubuntu1~18.04.1 |
| rsyslog | 8.32.0-1ubuntu4 |
| systemd | 237-3ubuntu10.51 |

RPyC 5.0.1 and plumbum 1.7.0 are installed under `/usr/local/lib/python3.6/dist-packages`, not as Debian packages. The classic server is `/usr/local/bin/rpyc_classic.py`. postfix is not installed.

## Web
vhost `*:80`, server name unset (apache reports `127.0.0.1`), document root `/var/www/html`, config `/etc/apache2/sites-enabled/000-default.conf`.

No database name, user, host, or port. password: not present.

On the guest, `http://127.0.0.1/`, `http://127.0.0.1/site/`, and `http://127.0.0.1/site/index.html` each returned HTTP 200. The document root contains only the `site` directory. `autoindex` is enabled, which is why `/` answers.

## Databases
No database server is installed. No application dump.

## Cron
Root crontab: `@reboot python3 /usr/local/bin/rpyc_classic.py`.

`/etc/cron.d/cron-apt`: `0 4 * * *` root `cron-apt`.

`/etc/cron.d/dma`: `*/5 * * * *` root `dma -q1`.

`/etc/cron.d/mdadm`: `57 0 * * 0` root, first Sunday of the month, redundancy check when the helper exists.

`/etc/cron.d/popularity-contest`: `34 13 * * *` root.

floki and ragnar crontabs contain no commands. `/etc/crontab` runs the hourly, daily, weekly, and monthly `run-parts` directories.

## Mail
dma 0.11-1build1. Ports 25 and 587 were not listening. Local mailbox files exist for root and floki. Their contents are not copied into this inventory.

## Sizes
`/var/www` 2.1M. `/home` 108K. `/opt` 16K. `/srv` 4K. `/var` 1.1G, mostly cache, logs, and `/var/lib`.
