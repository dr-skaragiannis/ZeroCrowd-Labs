# Educational module: Moria

Build a Debian 12 virtual machine you administer. The original guest was CentOS 7.3 with 1024 MB RAM. This exercise uses Debian packages for the same jobs, 512 MB RAM, and a 16 GB disk. Host-only address `192.168.56.12/24`.

Published ports are 22, 80, and 21. Postfix and Chrony stay on loopback. Anonymous FTP is off, and FTP users cannot upload. The gatehouse site and its pictures come from `resources/moria`.

Follow [virtual-machine.md](../../resources/virtual-machine.md) with hostname `Moria`, RAM 512 MB, and address `192.168.56.12`. Adapter 1 is host-only. Adapter 2 is NAT. Copy this lab's `resources` folder to `/opt/student-resources`. The page is `www/index.php` and the picture is `www/moria.jpg`.

## Accounts

| Name | Shell | Admin |
| --- | --- | --- |
| root | /bin/bash | console only |
| abatchy | /bin/bash | no |
| Balrog | /sbin/nologin | no |
| Ori | /bin/bash | no |
| bloodraven | /bin/bash | group `sudo` |

```bash
sudo apt-get update
sudo apt-get install -y openssh-server sudo apache2 php libapache2-mod-php vsftpd postfix chrony ftp
sudo hostnamectl set-hostname Moria
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl reload ssh || sudo systemctl reload sshd
sudo useradd -m -s /bin/bash abatchy
sudo useradd -m -d /prison -s /sbin/nologin Balrog
sudo useradd -m -s /bin/bash Ori
sudo useradd -m -s /bin/bash bloodraven
sudo usermod -aG sudo bloodraven
sudo passwd abatchy
sudo passwd Ori
sudo passwd bloodraven
```

Skip `useradd` for `bloodraven` if the installer already created that account. `Balrog` has no password and cannot log in.

## Web site

Replace the default page with the gatehouse site. The HTML already points at the three pictures.

```bash
sudo rm -rf /var/www/html/*
sudo cp -a /opt/student-resources/www/. /var/www/html/
sudo chown -R www-data:www-data /var/www/html
sudo systemctl reload apache2
```

On the workstation, open `http://192.168.56.12/`. The page is the gate picture. Then open `http://192.168.56.12/moria.jpg` directly.

Each page check returns 200, and `moria.jpg` loads. A 200 on the page with a broken image is not finished.

## FTP

The picture is the web file above. Edit `/etc/vsftpd.conf` and set these keys. Leave the rest of the packaged file as it is.

```text
listen=YES
listen_ipv6=NO
anonymous_enable=NO
local_enable=YES
write_enable=NO
```

```bash
sudo systemctl restart vsftpd
```

On the virtual machine, run `ftp 127.0.0.1`. Log in as `abatchy` with the password you chose. `put` must fail. Quit with `bye`. Do not record the password.

## Mail and time

Postfix is local only.

```bash
sudo debconf-set-selections <<'EOF'
postfix postfix/mailname string moria.local
postfix postfix/main_mailer_type string Local only
EOF
sudo postconf -e 'inet_interfaces = loopback-only'
sudo systemctl restart postfix
sudo systemctl enable --now chrony
```

Do not add a root crontab entry.

## Verify

```bash
ss -lnt | awk 'NR==1 || /:21|:22|:25|:80/'
ss -lnu | awk 'NR==1 || /:323/'
curl -s -o /dev/null -w 'page %{http_code}\n' http://127.0.0.1/
curl -s -o /dev/null -w 'jpg %{http_code}\n' http://127.0.0.1/moria.jpg
getent passwd abatchy Balrog Ori bloodraven
sudo visudo -c
dpkg-query -W apache2 vsftpd postfix chrony openssh-server
```

Ports 21, 22, and 80 are on `0.0.0.0` or `*`. Port 25 is `127.0.0.1`. Both HTTP checks return 200.

## Hand-in

Topology, accounts, package lines, the four status codes, and the FTP `ls` filenames. No passwords.
