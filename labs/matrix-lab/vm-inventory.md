# VM inventory

## OS
Matrix 6.4, Porteus 4.0, Slackware-style live system. Guest RAM 512 MB. The writable root is `porteus/changes` over squashfs modules. The guest did not boot: VirtualBox left the machine `Matrix` locked, so the running kernel string was not collected. The kernel image is `/boot/syslinux/vmlinuz`.

## Listeners
Taken from startup scripts and `sshd_config`, not from a live `ss`.

| proto | address | port | process | loopback |
| --- | --- | --- | --- | --- |
| tcp | 0.0.0.0 | 22 | sshd | no |
| tcp | 0.0.0.0 | 80 | python | no |
| tcp | 0.0.0.0 | 31337 | python | no |

`/etc/rc.d/rc.local` starts `python /tmp/server/80/80.py` and `python /tmp/server/31337/31337.py`. Each script binds `TCPServer` on all interfaces. `sshd_config` in the changes tree sets port 22 and `ListenAddress 0.0.0.0`.

## Users
| name | uid | gid | home | shell | admin |
| --- | --- | --- | --- | --- | --- |
| root | 0 | 0 | /root | /bin/bash | yes |
| guest | 1000 | 100 | /home/guest | /bin/rbash | no |
| trinity | 1001 | 1001 | /home/trinity | /bin/bash | no |
| bloodraven | 1002 | 1002 | /home/bloodraven | /bin/bash | yes |

`wheel` is group 10 and contains root and bloodraven. A shadow extract for `chpasswd -e` is `replica/shadow-users.txt`.

## Sudoers
The base sudoers file leaves `%wheel` commented and includes `/etc/sudoers.d`.

`/etc/sudoers.d/bloodraven`:

```
bloodraven ALL=(ALL:ALL) ALL
```

## Service packages
| package | version |
| --- | --- |
| openssh | 7.7p1-x86_64-2 |
| sudo | 1.8.22-x86_64-1 |
| python | 2.7.14-x86_64-1 |
| dcron | 4.5-x86_64-5 |

These are Slackware package names from `/var/log/packages`. `rc.crond` is not present.

## Web
No Apache or nginx vhost. Two Python `SimpleHTTPServer` processes.

Port 80 document root `/tmp/server/80`. Port 31337 document root `/tmp/server/31337`.

No database name, user, host, or port. password: not present.

## Databases
No database server is installed. No application dump.

## Cron
No user crontabs. `dcron` is installed and `rc.crond` is absent.

## Mail
No mail-transfer package and no port 25 listener were found. A local mailbox file exists for trinity. Its contents are not copied.

## Sizes
The boot disk is 8 GB. The site tree under `porteus/changes/tmp/server` is the web content copied into the replica.
