# Moria guest inventory

Collected from the running guest over the serial console. Passwords, shadow fields, private keys, and file contents are omitted.

## Host

- Name: Moria
- OS: CentOS Linux release 7.3.1611 (Core)
- Kernel: 3.10.0-514.el7.x86_64
- RAM: 1024 MB
- NIC: enp0s17, DHCP 10.0.2.48/24 on NatNetwork at inventory time
- Disk: DOS label, XFS `/boot`, LVM volume group `cl` with an XFS root LV and a swap LV

## Listeners

| Address | Port | Process | Publish |
| --- | --- | --- | --- |
| *:22 and :::22 | 22 | sshd | yes, loopback |
| :::80 | 80 | httpd | yes, loopback |
| :::21 | 21 | vsftpd | yes, loopback |
| 127.0.0.1:25 and ::1:25 | 25 | postfix master | no |
| 127.0.0.1:323 and ::1:323 | 323/udp | chronyd | no |

dhclient UDP sockets are not services. firewalld was installed and was not a listener in this capture.

## Packages

- httpd-2.4.6-45.el7.centos.x86_64
- php-5.4.16-42.el7.x86_64
- php-cli-5.4.16-42.el7.x86_64
- openssh-server-6.6.1p1-33.el7_3.x86_64
- cronie-1.4.11-14.el7_2.1.x86_64
- postfix-2.10.1-6.el7.x86_64
- vsftpd-3.0.2-21.el7.x86_64
- chrony-2.1.1-4.el7.centos.x86_64
- firewalld-0.4.3.2-8.1.el7_3.2.noarch

Not installed: nginx, php-mysql, php-mysqlnd, mariadb, mariadb-server, mysql-server, sendmail, dovecot, mod_ssl. `httpd -M` includes `php5_module (shared)`.

## Users

| User | uid | gid | Home | Shell |
| --- | --- | --- | --- | --- |
| root | 0 | 0 | /root | /bin/bash |
| abatchy | 1000 | 1003 (notBalrog) | /home/abatchy | /bin/bash |
| Balrog | 1001 | 1001 (prison) | /prison | /sbin/nologin |
| Ori | 1002 | 1003 (notBalrog) | /home/Ori | /bin/bash |
| bloodraven | 1003 | 1004 (bloodraven) | /home/bloodraven | /bin/bash |

bloodraven is also in group wheel. Sudoers: `root ALL=(ALL) ALL` and `%wheel ALL=(ALL) ALL`.

## Web

- No name-based virtual hosts
- ServerRoot `/etc/httpd`
- DocumentRoot `/var/www/html`
- ServerName commented (`www.example.com:80`)
- User apache (48)
- Tree includes `index.php`, `moria.jpg`, `w/h/i/s/p/e/r/the_abyss/`, and `QlVraKW4fbIkXau9zkAPNGzviT3UKntl/`
- No application database configuration under `/var/www`, `/home`, `/opt`, or `/srv`

## FTP

`/etc/vsftpd/vsftpd.conf`: anonymous_enable=NO, local_enable=YES, write_enable=NO, listen=NO, listen_ipv6=YES, userlist_enable=YES.

## Cron

- `/etc/cron.d/0hourly`
- `/etc/cron.d/raid-check`
- root crontab: `*/3 * * * * /home/abatchy/knockknock.sh`

## Mail

Postfix listens on loopback port 25. Spool names exist for abatchy, Balrog, bloodraven, Ori, and root. Message bodies were not copied.

## Database

None. The mysql client is not installed.

## Copy notes

The replica tree excludes `id_rsa`. Shadow fields for root, abatchy, Balrog, Ori, and bloodraven are in `import/shadow.snippet` (mode 600) and are not recorded here.
