# VM inventory

Guest: Necromancer. VirtualBox UUID `{6fc73655-a4fe-4a62-ac3c-96fee3e8efed}`. Powered off. The disk was read from a RAW clone. The guest was not booted, and the host has no writable UFS, so this list comes from `rc.conf`, `rc.conf.local`, `httpd.conf`, `sshd_config`, the net-snmp config, and the boot script those files start.

## OS

OpenBSD 5.9 (GENERIC) #1761, built Fri Feb 26 01:15:04 MST 2016. Hostname `thenecromancer`. One CPU, 512 MB RAM, 2 GiB disk. The root, `/usr`, and `/home` slices are UFS 1. The enabled NIC was host-only; the settings file now attaches it to NatNetwork. The host-only network was not recreated.

## Listeners

| Bind | Program | Scope |
| --- | --- | --- |
| `0.0.0.0:22` TCP | base `sshd` (`sshd_flags` empty, `PermitRootLogin yes`) | non-loopback |
| `127.0.0.1:80` TCP | base `httpd`, root `/htdocs/` inside the `/var/www` chroot | loopback |
| `127.0.0.1:161` UDP | `pkg_scripts=netsnmpd`, agent address in the net-snmp config | loopback |
| `127.0.0.1:666` UDP | Python 2 script started by the boot script | loopback |

`smtpd_flags=NO`. Base `snmpd_flags=NO`. `php54_fpm` is commented out. No database listener.

## Users

| name | uid | gid | home | shell |
| --- | --- | --- | --- | --- |
| root | 0 | 0 | /root | /bin/ksh |
| demonslayer | 1000 | 1000 | /home/demonslayer | /bin/ksh |

`wheel` contains root. The operator account is not on this disk. The clone was left unchanged because the host cannot mount UFS read-write.

## Sudoers

`root ALL=(ALL) SETENV: ALL`. The `%wheel` rules are commented out. `demonslayer` has no sudo rule.

## Service packages

| package | version |
| --- | --- |
| base sshd, httpd, cron | OpenBSD 5.9 |
| net-snmp | 5.7.3p6 |
| python | 2.7.11 |
| php | 5.4.45p2, not enabled |
| sudo | 1.8.15 |
| smtpd | base, not started |

## Web

One OpenBSD `httpd` server, name `default`, listen `127.0.0.1` port 80, document root `/var/www/htdocs`. Files: `index.html`, `pics/`, `amagicbridgeappearsatthechasm/`, `thenecromancerwillabsorbyoursoul/`. Application URL: `http://127.0.0.1/` on the guest. It is not a published host port.

## Databases

None.

## Cron

The boot script installs the root crontab. The added line is `* * * * * /bin/sh /root/scripts/netcatsend.sh`. The same file also has the base OpenBSD `newsyslog`, `daily`, `weekly`, and `monthly` lines.

## Mail

`smtpd` is disabled. No mail listener. The `femail` package is installed and not a listener.

## Sizes

Disk image 2 GiB. Guest RAM 512 MB.
