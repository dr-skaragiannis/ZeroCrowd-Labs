# VM inventory

Collected from the running guest over the serial console. Passwords, hashes, and flag values are omitted.

## OS
ID=debian, VERSION_ID=8, VERSION_CODENAME=jessie, kernel 3.16.0-6-amd64. Memory 512 MB. NIC on NAT Network.

## Listeners
| proto | address | port | process | loopback |
| --- | --- | --- | --- | --- |
| tcp | * | 22 | sshd | no |
| tcp | ::: | 80 | apache2 | no |
| tcp | 127.0.0.1 | 3306 | mysqld | yes |
| tcp | 127.0.0.1 | 25 | sendmail-mta | yes |
| tcp | 127.0.0.1 | 587 | sendmail-mta | yes |
| tcp | * | 111 | rpcbind | no |
| tcp | * | high | rpc.statd | no |

## Users
| name | uid | gid | home | shell | admin |
| --- | --- | --- | --- | --- | --- |
| root | 0 | 0 | /root | /bin/bash | yes |
| michael | 1000 | 1000 | /home/michael | /bin/bash | no |
| steven | 1001 | 1001 | /home/steven | /bin/sh | sudo command only |
| bloodraven | 1002 | 1002 | /home/bloodraven | /bin/bash | yes |

## Sudoers
- root ALL=(ALL:ALL) ALL
- %sudo ALL=(ALL:ALL) ALL
- steven ALL=(ALL) NOPASSWD: /usr/bin/python
- bloodraven ALL=(ALL:ALL) ALL

## Service packages
| package | version |
| --- | --- |
| apache2 | 2.4.10-10+deb8u12 |
| php5 | 5.6.36+dfsg-0+deb8u1 |
| mysql-server | 5.5.60-0+deb8u1 |
| openssh-server | 1:6.7p1-5+deb8u4 |
| sendmail | 8.14.4-8+deb8u2 |
| cron | 3.0pl1-127+deb8u1 |
| sudo | 1.8.10p3-1+deb8u5 |

## Web
vhost `*:80` name `raven.local`, document root `/var/www/html`, site file `/etc/apache2/sites-enabled/000-default.conf`.
database name wordpress, user root, host localhost, port 3306.
password: <redacted>
application base URL: `http://raven.local/wordpress`

## Databases
application schema `wordpress`. Dump path `import/wordpress.sql`.

## Cron
root crontab: `@reboot service sendmail start`.
`/etc/cron.d` contains `php5` and `sendmail`.

## Mail
package sendmail, listeners 127.0.0.1:25 and 127.0.0.1:587.

## Sizes
web tree and the application database were already copied into `import/`.
