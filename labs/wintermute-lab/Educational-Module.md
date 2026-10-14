# Educational module: Wintermute

Build two Debian 12 virtual machines you administer. Straylight's web root is the guest page and pictures in this lab's `resources/straylight` folder. Neuromancer's Tomcat root is `resources/neuromancer/webapp`. The original guests were Debian 9 and Ubuntu 16.04, 1024 MB each. This exercise uses 512 MB and a 16 GB disk on each.

| Machine | Address | Published | Loopback only |
| --- | --- | --- | --- |
| Straylight | 192.168.56.15 | 80 and 3000 | 3306, 6379, SNMP 161 |
| Neuromancer | 192.168.56.16 | 34483 and 8080 | Tomcat shutdown, and 8009 if that connector exists |

Follow [virtual-machine.md](../../resources/virtual-machine.md) once per machine. Adapter 1 is host-only. Adapter 2 is NAT. Straylight has no SSH daemon, so use the download method below on that machine. Neuromancer can use `scp`.

## Copy resources onto Straylight

On the workstation, from `ZeroCrowd-Labs`:

```powershell
tar -C C:\Users\bloodraven\Projects\ZeroCrowd-Labs\labs\wintermute-lab -cf resources.tar resources
python -m http.server 8088 --bind 192.168.56.1
```

If `python` is missing, try `py -m http.server 8088 --bind 192.168.56.1`. Leave that window open. On the Straylight console:

```bash
curl -fsSL -o /tmp/resources.tar http://192.168.56.1:8088/resources.tar
sudo mkdir -p /opt
sudo tar -C /opt -xf /tmp/resources.tar
sudo mv /opt/resources /opt/student-resources
sudo chmod -R a+rX /opt/student-resources
```

Stop the workstation server after the file is on the virtual machine. Neuromancer can use the same tarball or `scp` after SSH is installed.

## Straylight — 192.168.56.15

Hostname `straylight`. Do not install `openssh-server`. Administer this machine from the virtual machine console.

| Name | Shell | Admin |
| --- | --- | --- |
| root | /bin/bash | console |
| wintermute | /bin/bash | no |
| turing-police | /bin/bash | no |
| bloodraven | /bin/bash | group `sudo` |

```bash
sudo apt-get update
sudo apt-get install -y sudo apache2 php libapache2-mod-php php-mysql mariadb-server redis-server snmpd python3
sudo hostnamectl set-hostname straylight
sudo useradd -m -s /bin/bash wintermute
sudo useradd -m -s /bin/bash turing-police
sudo useradd -m -s /bin/bash bloodraven
sudo usermod -aG sudo bloodraven
sudo passwd wintermute
sudo passwd turing-police
sudo passwd bloodraven
```

### Lobby page

MariaDB stays installed and bound to `127.0.0.1`. The guest had no application tables, so do not load a notices dump. The site files are the guest web root: `index.html`, `sky.jpg`, `freeside/freeside.jpg`, and the pictures under `turing-bolo/`.

```bash
sudo sed -i 's/^bind-address.*/bind-address = 127.0.0.1/' /etc/mysql/mariadb.conf.d/50-server.cnf
sudo systemctl restart mariadb
sudo rm -rf /var/www/html/*
sudo cp -a /opt/student-resources/straylight/. /var/www/html/
sudo chown -R www-data:www-data /var/www/html
sudo systemctl reload apache2
```

Open `http://192.168.56.15/`, `http://192.168.56.15/sky.jpg`, and `http://192.168.56.15/freeside/freeside.jpg`. The bolo page is `http://192.168.56.15/turing-bolo/` and its pictures are `c7.png` and `ta.png`.

### Redis, SNMP, and port 3000

Redis stays on localhost. In `/etc/redis/redis.conf`, `bind` must be `127.0.0.1` (the packaged default already is). In `/etc/snmp/snmpd.conf`, set the agent line to:

```text
agentaddress 127.0.0.1
```

Do not add a community that listens on every interface. Leave packaged community lines commented.

```bash
sudo systemctl restart redis-server snmpd
redis-cli ping
sudo rm -rf /srv/port3000
sudo mkdir -p /srv/port3000
echo '<html><body><h1>port 3000</h1></body></html>' | sudo tee /srv/port3000/index.html
sudo tee /etc/systemd/system/port3000.service >/dev/null <<'EOF'
[Unit]
Description=Status board on port 3000
[Service]
WorkingDirectory=/srv/port3000
ExecStart=/usr/bin/python3 -m http.server 3000 --bind 0.0.0.0
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now port3000 apache2
```

`redis-cli ping` prints `PONG`. Port 3000 on the guest was the monitor program, and that program's files are not in this folder. The page on port 3000 is only a listener check. PostgreSQL stays uninstalled. Mail stays uninstalled. The original Postfix listened on all interfaces. Do not repeat that.

## Neuromancer — 192.168.56.16

Hostname `neuromancer`. SSH listens on 34483. Tomcat on 8080 serves the guest root application, which is the packaged Tomcat page and its pictures.

| Name | Shell | Admin |
| --- | --- | --- |
| root | /bin/bash | console |
| ta | /bin/bash | no |
| lady3jane | /bin/bash | no |
| bloodraven | /bin/bash | group `sudo` |

```bash
sudo apt-get update
sudo apt-get install -y openssh-server sudo tomcat10
sudo hostnamectl set-hostname neuromancer
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
echo 'Port 34483' | sudo tee /etc/ssh/sshd_config.d/port.conf
sudo systemctl restart ssh || sudo systemctl restart sshd
sudo useradd -m -s /bin/bash ta
sudo useradd -m -s /bin/bash lady3jane
sudo useradd -m -s /bin/bash bloodraven
sudo usermod -aG sudo bloodraven
sudo passwd ta
sudo passwd lady3jane
sudo passwd bloodraven
```

Copy the guest root application into Tomcat. Debian's webapps directory is `/var/lib/tomcat10/webapps`.

```bash
sudo systemctl stop tomcat10
sudo rm -rf /var/lib/tomcat10/webapps/ROOT
sudo mkdir -p /var/lib/tomcat10/webapps/ROOT
sudo cp -a /opt/student-resources/neuromancer/webapp/. /var/lib/tomcat10/webapps/ROOT/
sudo chown -R tomcat:tomcat /var/lib/tomcat10/webapps/ROOT
```

Open `/etc/tomcat10/server.xml`. The shutdown port is already `127.0.0.1`. If a `Connector` with `port="8009"` is present and not commented out, set `address="127.0.0.1"` on that element. This exercise does not publish 8009. Do not add a crontab.

```bash
sudo systemctl start tomcat10
```

From the workstation, open `http://192.168.56.16:8080/` and `http://192.168.56.16:8080/tomcat.svg`. SSH is `192.168.56.16` port 34483.

## Verify

On Straylight:

```bash
ss -lnt | awk 'NR==1 || /:80|:3000|:3306|:6379/'
ss -lnu | awk 'NR==1 || /:161/'
curl -s -o /dev/null -w 'page %{http_code}\n' http://127.0.0.1/
curl -s -o /dev/null -w 'sky %{http_code}\n' http://127.0.0.1/sky.jpg
curl -s -o /dev/null -w 'freeside %{http_code}\n' http://127.0.0.1/freeside/freeside.jpg
curl -s -o /dev/null -w '3000 %{http_code}\n' http://127.0.0.1:3000/
```

Ports 3306 and 6379 are `127.0.0.1`. SNMP is `127.0.0.1:161`.

On Neuromancer:

```bash
ss -lnt | awk 'NR==1 || /:34483|:8080|:8005|:8009/'
curl -s -o /dev/null -w '8080 %{http_code}\n' http://127.0.0.1:8080/
curl -s -o /dev/null -w 'svg %{http_code}\n' http://127.0.0.1:8080/tomcat.svg
```

8009 does not appear on `0.0.0.0`.

## Hand-in

Both hosts: addresses, accounts, which ports are loopback, and the status codes. No passwords.
