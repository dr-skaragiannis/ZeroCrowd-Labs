# Educational module: Raven

Build a Debian 12 virtual machine you administer, then install the desk site: Apache, PHP, MariaDB, Sendmail, and WordPress. The pictures are in the resource folder. You import them into the WordPress media library. You choose every password. Leave passwords out of the hand-in.

The original guest was Debian 8 with 512 MB RAM. This exercise uses Debian 12, 512 MB RAM, and a 16 GB disk. Host-only address `192.168.56.11/24`. Published ports are 22 and 80. MariaDB and Sendmail stay on `127.0.0.1`.

Follow [virtual-machine.md](../../resources/virtual-machine.md) with hostname `raven`, RAM 512 MB, and address `192.168.56.11`. Adapter 1 is host-only. Adapter 2 is NAT, so `apt` works. Copy this lab's `resources` folder to `/opt/student-resources`. That folder is the guest document root: the theme, `img/`, and WordPress. `wp-config.php` is not in the folder.

On your workstation, add a hosts line so the site name resolves:

```text
192.168.56.11 raven.local
```

## Accounts

| Name | uid | Shell | Admin |
| --- | --- | --- | --- |
| root | 0 | /bin/bash | console only |
| michael | 1000 | /bin/bash | no |
| steven | 1001 | /bin/sh | no |
| bloodraven | 1002 | /bin/bash | group `sudo` |

`steven` is a normal account. Do not add a `NOPASSWD` sudo rule.

```bash
sudo apt-get update
sudo apt-get install -y openssh-server sudo
sudo hostnamectl set-hostname raven
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl reload ssh || sudo systemctl reload sshd
sudo useradd -m -u 1000 -s /bin/bash michael
sudo useradd -m -u 1001 -s /bin/sh steven
sudo useradd -m -u 1002 -s /bin/bash bloodraven
sudo usermod -aG sudo bloodraven
sudo passwd michael
sudo passwd steven
sudo passwd bloodraven
```

If you already created `bloodraven` in the Debian installer, skip that `useradd` and only add the sudo group and the other two accounts.

## Packages

```bash
sudo apt-get install -y apache2 php libapache2-mod-php php-mysql php-gd php-xml php-mbstring php-curl php-zip php-intl mariadb-server sendmail curl
echo '127.0.0.1 raven.local' | sudo tee -a /etc/hosts
sudo rm -rf /var/www/html/*
sudo cp -a /opt/student-resources/www/. /var/www/html/
sudo chown -R www-data:www-data /var/www/html
sudo a2enmod rewrite
sudo systemctl reload apache2
```

`php-gd` is what lets WordPress make thumbnails when you import a picture. If `sendmail` asks a question, accept the default local setup. Afterward, port 25 and 587 must be on `127.0.0.1` only.

```bash
echo '@reboot root service sendmail start' | sudo tee /etc/cron.d/sendmail-reboot
sudo chmod 644 /etc/cron.d/sendmail-reboot
```

## Database

MariaDB listens on localhost. Open `/etc/mysql/mariadb.conf.d/50-server.cnf` and set:

```text
bind-address = 127.0.0.1
```

```bash
sudo systemctl restart mariadb
```

Pick a database password and keep it for the WordPress installer. In the command below, replace `CHOOSE` with that password before you run it. Do not leave the word `CHOOSE` in place, and do not put the password in the hand-in.

```bash
sudo mysql <<'SQL'
CREATE DATABASE wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'wp'@'localhost' IDENTIFIED BY 'CHOOSE';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wp'@'localhost';
FLUSH PRIVILEGES;
SQL
```

The installer creates the tables. Do not import a database dump from an appliance.

## Install WordPress

WordPress is already under `/var/www/html/wordpress` after the copy above. It has no `wp-config.php`. The installer writes that file.

```bash
sudo chown -R www-data:www-data /var/www/html/wordpress
sudo find /var/www/html/wordpress -type d -exec chmod 755 {} \;
sudo find /var/www/html/wordpress -type f -exec chmod 644 {} \;
```

On the workstation, open `http://raven.local/wordpress/`.

1. Choose English and continue.
2. Fill in the database screen: database name `wordpress`, username `wp`, password the one you set above, database host `localhost`, table prefix `wp_`.
3. If WordPress says it cannot write `wp-config.php`, the `www-data` ownership step above was skipped. Fix the ownership and reload the page. Use the on-screen file only if you would rather paste the config yourself. The database password in that file stays on the server.
4. Run the installation. Site title: `Raven Desk`. Choose your own admin username and password. Email can be `bloodraven@raven.local`.
5. Log in at `http://raven.local/wordpress/wp-admin/`.

The front page is the theme at `http://raven.local/`. WordPress is at `http://raven.local/wordpress/`.

## Pictures

The guest pictures are already in `/var/www/html/img`. The theme uses them. These are the files to check:

- `img/logo.png`
- `img/header-bg.jpg`
- `img/blog/` (the post and sidebar pictures)
- `img/elements/`
- `img/pages/`

Open `http://raven.local/` and confirm the header and logo load. Then open `http://raven.local/img/logo.png` and `http://raven.local/img/header-bg.jpg` directly.

To put the same files in the WordPress media library, log in at `http://raven.local/wordpress/wp-admin/`, open **Media → Add New**, and upload from `img/` on the server (or from `labs\raven-lab\resources\www\img` on the workstation). A copied file that never goes through **Add New** is not a library item.

## Verify

```bash
ss -lnt | awk 'NR==1 || /:22|:80|:3306|:25|:587/'
curl -s -o /dev/null -w 'root %{http_code}\n' -H 'Host: raven.local' http://127.0.0.1/
curl -s -o /dev/null -w 'logo %{http_code}\n' -H 'Host: raven.local' http://127.0.0.1/img/logo.png
curl -s -o /dev/null -w 'header %{http_code}\n' -H 'Host: raven.local' http://127.0.0.1/img/header-bg.jpg
curl -s -o /dev/null -w 'wp %{http_code}\n' -H 'Host: raven.local' http://127.0.0.1/wordpress/
sudo mysql -N -e "SHOW DATABASES LIKE 'wordpress';"
sudo visudo -c
dpkg-query -W openssh-server apache2 mariadb-server sendmail php php-gd
```

Ports 3306, 25, and 587 show `127.0.0.1`. The logo and header checks return 200. From the workstation, `http://raven.local/` shows the theme pictures, and port 3306 on `192.168.56.11` does not connect.

## Hand-in

Topology, the four accounts, the package lines, and the HTTP status codes. No passwords.

## Leave out

Do not load an appliance database. Do not add a sudo rule that runs an interpreter without a password. Do not publish MariaDB or Sendmail on the host-only address.
