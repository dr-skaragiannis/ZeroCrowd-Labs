# Educational module: Seven Kingdoms

Build one Debian 12 virtual machine you administer and install every service on that host. The research replica splits the same jobs across containers. Here you install them yourself so each config file is one you can read.

The original guest was Debian 9 with 1512 MB RAM. Use 1512 MB RAM and a 16 GB disk. Hostname `7kingdoms`. Host-only address `192.168.56.19/24`. Keep Adapter 1 on the host-only network. Adapter 2 is NAT, for `apt` only. Do not bridge Adapter 1.

Follow [virtual-machine.md](../../resources/virtual-machine.md), then copy this lab's `resources` folder to `/opt/student-resources`. The guest picture files were not on the replica. On the workstation:

```text
192.168.56.19 winterfell.local
```

## What listens where

| Service | Address | Port |
| --- | --- | --- |
| sshd | 192.168.56.19 | 22 |
| apache, gate page | 192.168.56.19 | 80 |
| apache, Winterfell vhost | 192.168.56.19 | 80, name `winterfell.local` |
| nginx, the Rock | 192.168.56.19 | 1337 |
| nginx, harbor page | 192.168.56.19 | 10000 |
| Dovecot IMAP | 192.168.56.19 | 143 |
| MariaDB | 127.0.0.1 | 3306 |
| PostgreSQL | 127.0.0.1 | 5432 |
| BIND | 127.0.0.1 | 53 |
| vsftpd | 127.0.0.1 | 21 |

Port 10000 is a static page. It is not a control panel. SMTP stays off. Anonymous FTP stays off. DNS recursion stays off. The database passwords, if you add any later, stay on the host.

## Accounts

| Name | uid | Shell | Admin |
| --- | --- | --- | --- |
| root | 0 | /bin/bash | console only |
| daenerystargaryen | 1000 | /bin/bash | no |
| branstark | 1001 | /bin/bash | no |
| bloodraven | 1002 | /bin/bash | group `sudo` |
| postclerk | — | /usr/sbin/nologin | mailbox only |

```bash
sudo apt-get update
sudo apt-get install -y openssh-server sudo
sudo hostnamectl set-hostname 7kingdoms
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl reload ssh || sudo systemctl reload sshd
sudo useradd -m -u 1000 -s /bin/bash daenerystargaryen
sudo useradd -m -u 1001 -s /bin/bash branstark
sudo useradd -m -u 1002 -s /bin/bash bloodraven
sudo usermod -aG sudo bloodraven
sudo useradd -m -s /usr/sbin/nologin postclerk
sudo passwd daenerystargaryen
sudo passwd branstark
sudo passwd bloodraven
sudo passwd postclerk
```

Skip `useradd` for an account the installer already created. There is no crontab to add.

## Gate and Winterfell

Apache serves two trees. The guest picture files were not kept on the replica, so these pages are text only. `/var/www/html` is the gate. `/var/www/html2` is Winterfell, selected by the host name.

```bash
sudo apt-get install -y apache2
sudo mkdir -p /var/www/html2
echo '<html><body><h1>Gate</h1></body></html>' | sudo tee /var/www/html/index.html
echo '<html><body><h1>Winterfell</h1></body></html>' | sudo tee /var/www/html2/index.html
sudo cp /opt/student-resources/winterfell.conf /etc/apache2/sites-available/winterfell.conf
sudo a2ensite winterfell
sudo chown -R www-data:www-data /var/www/html /var/www/html2
echo '127.0.0.1 winterfell.local' | sudo tee -a /etc/hosts
sudo systemctl reload apache2
```

From the workstation:

- `http://192.168.56.19/` shows the gate page
- `http://winterfell.local/` shows the Winterfell page

## The Rock and the harbor page

Install nginx after Apache is already bound to port 80. Remove the packaged default site before you start nginx again, or nginx will try to take port 80 and fail.

```bash
sudo apt-get install -y nginx
sudo systemctl stop nginx
sudo rm -f /etc/nginx/sites-enabled/default
sudo mkdir -p /var/www/rock /var/www/harbor
echo '<html><body><h1>The Rock</h1></body></html>' | sudo tee /var/www/rock/index.html
echo '<html><body><h1>Harbor watch</h1></body></html>' | sudo tee /var/www/harbor/index.html
sudo cp /opt/student-resources/nginx-1337.conf /etc/nginx/sites-available/rock.conf
sudo cp /opt/student-resources/nginx-10000.conf /etc/nginx/sites-available/harbor.conf
sudo ln -sf /etc/nginx/sites-available/rock.conf /etc/nginx/sites-enabled/rock.conf
sudo ln -sf /etc/nginx/sites-available/harbor.conf /etc/nginx/sites-enabled/harbor.conf
sudo nginx -t
sudo systemctl start nginx
```

Open `http://192.168.56.19:1337/` and `http://192.168.56.19:10000/`.

## IMAP

Plaintext IMAP is acceptable only because the listener is the host-only address. Do not move this virtual machine onto a bridged adapter.

```bash
sudo apt-get install -y dovecot-imapd netcat-openbsd
sudo cp /opt/student-resources/dovecot-99.conf /etc/dovecot/conf.d/99-student.conf
sudo systemctl restart dovecot
nc -v -w 2 192.168.56.19 143
```

The banner starts with `* OK`. Press Ctrl-C. If port 993 is also listening, set `ssl = no` in `/etc/dovecot/conf.d/10-ssl.conf` and restart Dovecot. `postclerk` is the mailbox user. Do not enable POP or a sieve listener, and do not install Postfix.

## Databases

Both servers stay on localhost. Load the place lists from the resource folder.

```bash
sudo apt-get install -y mariadb-server postgresql
sudo sed -i 's/^bind-address.*/bind-address = 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb
sudo mysql < /opt/student-resources/registry.sql
sudo -u postgres psql -c "CREATE DATABASE registry;"
sudo -u postgres psql -d registry -f /opt/student-resources/places.sql
```

Confirm PostgreSQL is not using `listen_addresses = '*'`. In `/etc/postgresql/*/main/postgresql.conf` it stays `localhost`. Restart PostgreSQL if you had to change it.

```bash
sudo mysql -N -e "SELECT name FROM registry.places;"
sudo -u postgres psql -d registry -c "SELECT name FROM places;"
```

Both lists include `winterfell` and `the rock`.

## DNS

Replace the options file with the resource copy. It listens on `127.0.0.1` and refuses recursion.

```bash
sudo apt-get install -y bind9
sudo cp /opt/student-resources/named.conf.options /etc/bind/named.conf.options
sudo named-checkconf
sudo systemctl restart bind9
dig @127.0.0.1 debian.org
```

`dig` reports a refusal. That is the result you want. Do not turn recursion on.

## FTP

Edit `/etc/vsftpd.conf`. Set these keys and leave the rest of the packaged file:

```text
listen=YES
listen_ipv6=NO
listen_address=127.0.0.1
anonymous_enable=NO
local_enable=YES
write_enable=NO
```

```bash
sudo apt-get install -y vsftpd ftp
sudo cp /opt/student-resources/ftp/readme.txt /home/branstark/readme.txt
sudo chown branstark:branstark /home/branstark/readme.txt
sudo systemctl restart vsftpd
```

On the virtual machine, `ftp 127.0.0.1`, log in as `branstark`, and `ls`. You should see `readme.txt`. `put` fails. Quit with `bye`.

## Verify

```bash
ss -lnt | awk 'NR==1 || /:22|:80|:1337|:10000|:143|:3306|:5432|:53|:21/'
curl -s -o /dev/null -w 'gate %{http_code}\n' http://127.0.0.1/
curl -s -o /dev/null -w 'winter %{http_code}\n' -H 'Host: winterfell.local' http://127.0.0.1/
curl -s -o /dev/null -w 'rock %{http_code}\n' http://127.0.0.1:1337/
curl -s -o /dev/null -w 'harbor %{http_code}\n' http://192.168.56.19:10000/
getent passwd daenerystargaryen branstark bloodraven postclerk
sudo visudo -c
```

3306, 5432, 53, and 21 show `127.0.0.1`. The picture checks return 200. From the workstation, port 3306 on `192.168.56.19` does not connect.

## Hand-in

The listener list, the account table, the picture status codes, and the two database name lists. No passwords.
