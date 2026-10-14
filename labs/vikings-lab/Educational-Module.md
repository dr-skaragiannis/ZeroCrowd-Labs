# Educational module: Vikings

Build a Debian 12 virtual machine you administer. The original guest was Ubuntu 18.04 with 1024 MB RAM. This exercise uses 512 MB RAM and a 16 GB disk. Host-only address `192.168.56.13/24`.

Published ports are 22 and 80. There is no database. The camp site, three pictures, and the records directory come from `resources/vikings`.

Follow [virtual-machine.md](../../resources/virtual-machine.md) with hostname `vikings`, RAM 512 MB, and address `192.168.56.13`. Adapter 1 is host-only. Adapter 2 is NAT. Copy this lab's `resources` folder to `/opt/student-resources`. The camp page is `www/index.html`. The pictures are `www/images/split.jpg`, `favicon.png`, and `webclip.jpg`.

## Accounts

| Name | uid | Shell | Admin |
| --- | --- | --- | --- |
| root | 0 | /bin/bash | console only |
| floki | 1000 | /bin/bash | no |
| ragnar | 1001 | /bin/sh | no |
| bloodraven | 1002 | /bin/bash | group `sudo` |

```bash
sudo apt-get update
sudo apt-get install -y openssh-server sudo apache2
sudo hostnamectl set-hostname vikings
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl reload ssh || sudo systemctl reload sshd
sudo useradd -m -u 1000 -s /bin/bash floki
sudo useradd -m -u 1001 -s /bin/sh ragnar
sudo useradd -m -u 1002 -s /bin/bash bloodraven
sudo usermod -aG sudo bloodraven
sudo passwd floki
sudo passwd ragnar
sudo passwd bloodraven
```

Skip `useradd` for an account the installer already created.

## Web site

`/site/` is the guest page. The pictures in that tree are `split.jpg`, `favicon.png`, and `webclip.jpg`.

```bash
sudo mkdir -p /var/www/html/site
echo '<html><body><p><a href="/site/">site</a></p></body></html>' | sudo tee /var/www/html/index.html
sudo cp -a /opt/student-resources/www/. /var/www/html/site/
sudo chown -R www-data:www-data /var/www/html
sudo systemctl reload apache2
```

On the workstation, open:

- `http://192.168.56.13/site/`
- `http://192.168.56.13/site/images/split.jpg`
- `http://192.168.56.13/site/images/favicon.png`
- `http://192.168.56.13/site/images/webclip.jpg`

Do not add an `@reboot` crontab line.

## Verify

```bash
ss -lnt | awk 'NR==1 || /:22|:80/'
curl -s -o /dev/null -w 'site %{http_code}\n' http://127.0.0.1/site/
curl -s -o /dev/null -w 'split %{http_code}\n' http://127.0.0.1/site/images/split.jpg
curl -s -o /dev/null -w 'favicon %{http_code}\n' http://127.0.0.1/site/images/favicon.png
curl -s -o /dev/null -w 'webclip %{http_code}\n' http://127.0.0.1/site/images/webclip.jpg
getent passwd floki ragnar bloodraven
sudo visudo -c
dpkg-query -W openssh-server apache2
```

The HTTP checks return 200.

## Hand-in

Topology, accounts, and the status codes. No passwords.
