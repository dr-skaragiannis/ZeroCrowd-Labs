# Educational module: Gaara

Build a Debian 12 virtual machine you administer. The original guest was Debian 10 with 1024 MB RAM. This exercise uses 512 MB RAM and a 16 GB disk. Host-only address `192.168.56.18/24`.

Published ports are 22 and 80. There is no database and no mail listener. The office site is two pages plus two pictures from `resources/gaara`. Cron and anacron use the package schedule only.

Follow [virtual-machine.md](../../resources/virtual-machine.md) with hostname `Gaara`, RAM 512 MB, and address `192.168.56.18`. Adapter 1 is host-only. Adapter 2 is NAT. Copy this lab's `resources` folder to `/opt/student-resources`. The only page on the guest was `www/index.html`. Its picture is a remote URL inside that file. There is no image file on the guest disk.

## Accounts

| Name | uid | Shell | Admin |
| --- | --- | --- | --- |
| root | 0 | /bin/bash | console only |
| gaara | 1001 | /bin/bash | no |
| bloodraven | 1002 | /bin/bash | group `sudo` |

```bash
sudo apt-get update
sudo apt-get install -y openssh-server sudo apache2 cron anacron
sudo hostnamectl set-hostname Gaara
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl reload ssh || sudo systemctl reload sshd
sudo useradd -m -u 1001 -s /bin/bash gaara
sudo useradd -m -u 1002 -s /bin/bash bloodraven
sudo usermod -aG sudo bloodraven
sudo passwd gaara
sudo passwd bloodraven
```

Skip `useradd` for an account the installer already created. `gaara` is not in group `sudo`.

## Office site

```bash
sudo rm -rf /var/www/html/*
sudo cp /opt/student-resources/www/index.html /var/www/html/index.html
sudo chown www-data:www-data /var/www/html/index.html
sudo a2dismod ssl || true
sudo systemctl reload apache2
sudo systemctl enable --now cron anacron
```

On the workstation, open `http://192.168.56.18/`. The page is the guest file. The picture tag points at a remote address, so it loads only when that address answers. There is no second local page and no local image file.

## Verify

```bash
ss -lnt | awk 'NR==1 || /:22|:80|:443/'
curl -s -o /dev/null -w 'home %{http_code}\n' http://127.0.0.1/
getent passwd gaara bloodraven
sudo visudo -c
sudo ls /etc/cron.d
dpkg-query -W apache2 openssh-server cron anacron sudo
```

The home check returns 200. Port 443 is absent.

## Hand-in

Topology, accounts, package lines, and the status codes. No passwords.
