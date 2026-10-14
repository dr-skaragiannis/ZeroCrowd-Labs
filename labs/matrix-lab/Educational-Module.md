# Educational module: Matrix

Build a Debian 12 virtual machine you administer. The original guest was a Slackware-style live system with 512 MB RAM. This exercise uses 384 MB RAM and a 16 GB disk. Host-only address `192.168.56.14/24`.

Published ports are 22, 80, and 31337. Each web port is a Python file server with its own tree from `resources/matrix`. There is no database and no mail listener.

Follow [virtual-machine.md](../../resources/virtual-machine.md) with hostname `matrix`, RAM 384 MB, and address `192.168.56.14`. Adapter 1 is host-only. Adapter 2 is NAT. Copy this lab's `resources` folder to `/opt/student-resources`. Port 80 is `http80/`. Port 31337 is `http31337/`. Both pages use `assets/img/p0rt_31337.png`.

## Accounts

| Name | uid | Shell | Admin |
| --- | --- | --- | --- |
| root | 0 | /bin/bash | console only |
| guest | 1000 | /bin/rbash | no |
| trinity | 1001 | /bin/bash | no |
| bloodraven | 1002 | /bin/bash | group `sudo` |

```bash
sudo apt-get update
sudo apt-get install -y openssh-server sudo python3
sudo hostnamectl set-hostname matrix
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl reload ssh || sudo systemctl reload sshd
sudo useradd -m -u 1000 -s /bin/rbash guest
sudo useradd -m -u 1001 -s /bin/bash trinity
sudo useradd -m -u 1002 -s /bin/bash bloodraven
sudo usermod -aG sudo bloodraven
sudo passwd guest
sudo passwd trinity
sudo passwd bloodraven
```

`/bin/rbash` is provided by the `bash` package. If `useradd` says the shell is missing, install `bash` and run `sudo ln -sf bash /bin/rbash` only if `/bin/rbash` is absent.

## Two boards

Copy each resource tree into its own document root. The HTML in each tree references one picture.

```bash
sudo rm -rf /srv/http80 /srv/http31337
sudo cp -a /opt/student-resources/http80 /srv/http80
sudo cp -a /opt/student-resources/http31337 /srv/http31337
sudo tee /etc/systemd/system/http80.service >/dev/null <<'EOF'
[Unit]
Description=Lobby board on port 80
[Service]
WorkingDirectory=/srv/http80
ExecStart=/usr/bin/python3 -m http.server 80 --bind 0.0.0.0
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
sudo tee /etc/systemd/system/http31337.service >/dev/null <<'EOF'
[Unit]
Description=Terminal board on port 31337
[Service]
WorkingDirectory=/srv/http31337
ExecStart=/usr/bin/python3 -m http.server 31337 --bind 0.0.0.0
Restart=on-failure
[Install]
WantedBy=multi-user.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now http80 http31337
```

Port 80 is privileged. The system unit runs as root, which is what makes that bind succeed. Do not start cron.

On the workstation, open:

- `http://192.168.56.14/`
- `http://192.168.56.14/assets/img/p0rt_31337.png`
- `http://192.168.56.14:31337/`
- `http://192.168.56.14:31337/assets/img/p0rt_31337.png`

The lobby page shows the lobby picture. The terminal page shows the terminal picture.

## Verify

```bash
ss -lnt | awk 'NR==1 || /:22|:80|:31337/'
curl -s -o /dev/null -w '80 %{http_code}\n' http://127.0.0.1/
curl -s -o /dev/null -w 'img80 %{http_code}\n' http://127.0.0.1/assets/img/p0rt_31337.png
curl -s -o /dev/null -w '31337 %{http_code}\n' http://127.0.0.1:31337/
curl -s -o /dev/null -w 'img31337 %{http_code}\n' http://127.0.0.1:31337/assets/img/p0rt_31337.png
getent passwd guest trinity bloodraven
sudo visudo -c
systemctl is-active http80 http31337
```

All four HTTP checks return 200. Both units are `active`.

## Hand-in

Topology, accounts, the four status codes. No passwords.
