# Educational module: Necromancer

You build and administer a small Debian 12 server, and then you attack it from your
workstation exactly as an outsider would. The machine is called `thenecromancer` and it
serves a private "image catalogue" over HTTP, plus an SNMP agent. The original guest this
exercise is modelled on is OpenBSD 5.9 with 512 MB RAM and `/bin/ksh`; here it is a Debian
stand-in with 384 MB RAM and a 16 GB disk, because that is what this engine boots.

The whole point of the lab is the topology. Only **one** port is published to your
workstation: SSH on `22`. The catalogue is bound to `127.0.0.1:80` inside the guest and the
SNMP agent to `127.0.0.1:161`. A browser on the workstation cannot reach either. So an
attacker's `nmap` shows a single service, the real attack surface is entirely behind SSH,
and the "hidden" web and SNMP services only become interesting *after* you have a shell.
That is the lesson: an exposed-but-weak account on one published service is the whole box.

This lab teaches you to reason about a machine that looks empty from the outside, to
enumerate the one service that is actually reachable, to get a foothold on a weak account,
to re-enumerate from the inside (where the loopback-only services suddenly appear), and to
escalate to root with method instead of luck.

## What you will learn

- **Topology thinking.** Why a workstation `nmap` sees only `22` while the guest runs four
  listeners, and how to prove which bind is on which address with `ss` on both sides.
- **Recon discipline.** TCP and UDP scanning, service/version detection, SSH host-key and
  banner collection, and how to read a nearly-empty result instead of giving up.
- **SSH enumeration.** Banners, `ssh-keyscan`, auth-method probing, and why
  `PermitRootLogin no` pushes you towards a normal account instead of root.
- **Credential attacks on a lab box you own.** Wordlist selection, `hydra` usage, rate
  limiting, and what a lockout/no-lockout posture means for an SSH service.
- **SNMP fundamentals.** Community strings as shared secrets, `snmpwalk`, SNMPv1/v2c
  cleartext on the wire, the difference between `rocommunity` and `rwcommunity`, and how
  an `rw` community turns an agent into a configuration-write primitive.
- **Post-exploitation re-enumeration.** How the loopback catalogue becomes reachable the
  moment you hold a shell, and how to inventory it with `curl`, `gobuster`/`feroxbuster`,
  and the filesystem.
- **Filesystem reconnaissance for privesc.** Reading `/etc/passwd`, `/etc/group`,
  `/etc/sudoers` (and `sudo -l`), SUID/SGID binaries, world-writable paths, cron, home
  directories, and how the *absence* of a rule is itself a finding.
- **Root-shell capture and proof.** Getting `uid=0`, reading the proof file, and writing
  up a clean hand-in with no live passwords in it.
- **The blue-team mirror.** For every step above, the fix: bind addresses, remove `rw`
  communities, kill password SSH or guard it with keys and rate limits, set a real shell
  policy, and monitor the things nobody watches on a loopback-only host.

## Target and topology

| Item | Value |
| --- | --- |
| Guest OS | Debian 12 |
| RAM | 384 MB |
| Disk | 16 GB |
| Host-only address | `192.168.56.17/24` |
| Adapter 1 | host-only (this is how you reach it) |
| Adapter 2 | NAT (this is how it reaches the internet for `apt`) |
| Hostname | `thenecromancer` |
| Original guest | OpenBSD 5.9, 512 MB, `/bin/ksh` — context only, not what you boot here |

### Ports: what is reachable and what is not

| Port | Service | Bind inside the guest | Reachable from the workstation? |
| --- | --- | --- | --- |
| `22` TCP | `sshd` | all interfaces | **yes** — the only published port |
| `80` TCP | `nginx` image catalogue | `127.0.0.1:80` | no |
| `161` UDP | `snmpd` | `127.0.0.1:161` | no |

Deliberately **not** present at all: no mail listener (`smtpd` off, no port 25), no database,
no second web vhost on the host-only address, no cron line, no UDP 666 program, no PHP.

Root SSH login is off (`PermitRootLogin no`). The accounts are:

| Name | uid | Shell | Admin |
| --- | --- | --- | --- |
| `root` | 0 | `/bin/bash` | console only (no SSH) |
| `demonslayer` | 1000 | `/bin/bash` | no — not in group `sudo` |

`demonslayer` is the foothold account and the only login you can realistically use. The
original guest used `/bin/ksh`; bash is the Debian default here.

> **Read this twice.** The catalogue is loopback-only *on purpose*. From the workstation,
> `http://192.168.56.17/` does not connect — and that is the exercise, not a bug. Do not
> "fix" the bind to make the page load. Everything in the walkthrough is built around the
> fact that ports 80 and 161 are invisible to you until you have a shell.

## Build the lab

Follow [virtual-machine.md](../../resources/virtual-machine.md) with hostname
`thenecromancer`, RAM 384 MB, and address `192.168.56.17`. Adapter 1 is host-only.
Adapter 2 is NAT. Copy this lab's `resources` folder to `/opt/student-resources`.

### 1. Install the services and create the account

```bash
sudo apt-get update
sudo apt-get install -y openssh-server sudo nginx snmpd
sudo hostnamectl set-hostname thenecromancer
sudo sed -i 's/^#\?PermitRootLogin.*/PermitRootLogin no/' /etc/ssh/sshd_config
sudo systemctl reload ssh || sudo systemctl reload sshd
sudo useradd -m -u 1000 -s /bin/bash demonslayer
sudo passwd demonslayer
```

**What this does.** `apt-get` installs the SSH server, `sudo`, `nginx` and the net-snmp
agent. `hostnamectl` sets the name the machine reports and the name that appears in your
SSH prompt. The `sed` rewrites the `PermitRootLogin` line in `/etc/ssh/sshd_config` so that
root cannot log in over the network — the regex handles both a commented default
(`#PermitRootLogin prohibit-password`) and an already-set line, so it is safe to re-run.
`systemctl reload` re-reads that config without dropping your existing session. `useradd`
creates `demonslayer` with uid 1000 and a bash login shell and a home directory, and
`passwd` sets the password interactively.

**Pick the password deliberately.** This lab is a lab you own, and the password you type
here is the credential the walkthrough attacks. Choose something a wordlist would find
quickly (a short, common password) so the credential step behaves like the original box.
Do not reuse a password you use anywhere real.

**You should see.** `passwd` prints `passwd: password updated successfully`. After the
reload, from the workstation: `ssh [email protected]` answers `Permission denied
(publickey,password).` — root cannot authenticate at all.

**If you get stuck.** If `systemctl reload` fails, the service is probably named `sshd` on
your image, hence the `||` fallback. If `useradd` says the uid is taken, check
`getent passwd 1000` — reuse the existing account rather than forcing a second one.

### 2. Publish the catalogue on loopback only

The pictures are `pics/pileoffeathers.jpg`, `pics/necromancer.jpg`, and `pics/magicbook.jpg`.
Nginx must not listen on the host-only address.

```bash
sudo mkdir -p /var/www/htdocs
sudo cp -a /opt/student-resources/www/. /var/www/htdocs/
sudo chown -R www-data:www-data /var/www/htdocs
sudo cp /opt/student-resources/nginx-local.conf /etc/nginx/sites-available/local.conf
sudo rm -f /etc/nginx/sites-enabled/default
sudo ln -sf /etc/nginx/sites-available/local.conf /etc/nginx/sites-enabled/local.conf
sudo nginx -t
sudo systemctl reload nginx
```

**What this does.** `cp -a` copies the web root *and* preserves permissions and timestamps;
the trailing `/.` matters — it copies the *contents* of `www/` into `/var/www/htdocs` rather
than creating a nested `htdocs/www`. `chown www-data` makes the unprivileged nginx worker
the owner, so a compromise of the worker does not hand over root-owned content. The
`nginx-local.conf` in this lab's `resources` folder is the whole vhost:

```text
server {
    listen 127.0.0.1:80;
    root /var/www/htdocs;
    index index.html;
}
```

`listen 127.0.0.1:80` is the single most important line in this lab: it binds the catalogue
to loopback inside the guest, so nothing outside can reach it. Removing
`sites-enabled/default` stops the stock Debian vhost from also binding `0.0.0.0:80`, and
the symlink is how Debian enables a site. `nginx -t` validates the config **before** you
reload — always run it, because a bad vhost takes the web server down on reload.

**You should see.**

```text
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful
```

And from **inside the guest only** (not from the workstation):

```bash
curl -s http://127.0.0.1/ | head
curl -s -o /dev/null -w 'archive %{http_code}\n' http://127.0.0.1/pics/necromancer.jpg
curl -s -o /dev/null -w 'feathers %{http_code}\n' http://127.0.0.1/pics/pileoffeathers.jpg
curl -s -o /dev/null -w 'book %{http_code}\n' http://127.0.0.1/pics/magicbook.jpg
```

You should see the chasm story page, then three `200` lines. `-o /dev/null` throws the body
away and `-w` prints just the HTTP status, which is the cleanest way to record this for
your hand-in.

**If you get stuck.** If `curl` says `Connection refused`, nginx is not running —
`systemctl status nginx`. If it returns the Debian welcome page instead of the chasm story,
you forgot to remove `sites-enabled/default` and the default vhost is winning. If you get
`403`, check `chown`/`chmod` on `/var/www/htdocs`.

### 3. SNMP on loopback only

In `/etc/snmp/snmpd.conf`, set:

```text
agentaddress 127.0.0.1
```

Do not add a community that listens on every interface.

```bash
sudo systemctl restart snmpd
```

**What this does.** `agentaddress` tells the agent which local addresses to bind. With
`127.0.0.1` the agent answers only from inside the guest; from the workstation, UDP 161 is
simply not there. The community line that ships in the net-snmp example config
(`rocommunity public default`) is a *global* read-only community — leaving it in place is
the classic SNMP mistake, because a community string is a shared secret that travels in
cleartext and, unrestricted, answers to anyone who asks. In this lab you keep the agent
loopback-bound and you do not publish a community to the host-only network. The read-write
community (`rwcommunity`) is what makes an agent writeable, and it is the thing the
walkthrough exercises from the *inside* later.

**You should see.** `ss -lnu` shows `127.0.0.1:161` bound by `snmpd`, and a `snmpwalk` from
inside the guest with the community you configured returns the system group.

**If you get stuck.** If `snmpwalk` from the guest times out, the agent is bound to the
wrong address or not running; check `ss -lnu` and `systemctl status snmpd`. If it returns
nothing but exits 0, you queried an OID the configured view does not include.

### 4. What you deliberately do NOT add

Do not add a crontab line. Do not start a program on UDP 666. Leave PHP uninstalled. Do
not add a mail listener. Do not bind nginx or snmpd to the host-only address. These
exclusions are the parity contract with the original guest, and each one is also a
defensive lesson: no cron job means no scheduled root process to hijack, no UDP 666 means
no unauthenticated local listener to abuse, and no PHP means no interpreter on the web
path.

### 5. Verify the build

```bash
ss -lnt | awk 'NR==1 || /:22|:80/'
ss -lnu | awk 'NR==1 || /:161/'
getent passwd demonslayer
```

**What this does.** `ss -lnt` lists listening **TCP** sockets, `ss -lnu` listening **UDP**
sockets; the `awk` prints the header plus only the lines matching the ports you care about,
so the output stays readable on a small VM. `getent passwd demonslayer` resolves the
account through NSS and shows you the uid and shell the system actually resolved.

**You should see.** On TCP: `22` on `0.0.0.0` and `80` on `127.0.0.1`. On UDP: `161` on
`127.0.0.1`. The `getent` line shows uid 1000 and `/bin/bash`.

Port 80 is `127.0.0.1`. SNMP is `127.0.0.1:161`. From the workstation,
`http://192.168.56.17/` does not connect, and SSH on port 22 does.

```bash
# from the workstation, to prove it
curl -sS --max-time 5 http://192.168.56.17/ ; echo "exit=$?"
ssh -o BatchMode=yes -o ConnectTimeout=5 [email protected] ; echo "exit=$?"
```

**You should see.** The `curl` fails (exit code 7, "Failed to connect") — nothing is
listening on `192.168.56.17:80`. The `ssh` fails only because no key was offered
(`Permission denied (publickey,password)`, exit 255) — that proves port 22 is open and
answering, which is different from a connection failure.

### Common problems

| Symptom | Cause | Fix |
| --- | --- | --- |
| `curl: (7) Failed to connect` from the guest | nginx not running, or default vhost removed but `local.conf` not enabled | `systemctl status nginx`, `ls -l /etc/nginx/sites-enabled/` |
| Debian welcome page instead of the chasm page | `sites-enabled/default` still present | remove it, `nginx -t`, reload |
| `403` on the pictures | ownership or mode on `/var/www/htdocs` | `chown -R www-data:www-data`, check `chmod` |
| `ss` shows `80` on `0.0.0.0` | wrong `listen` line in the vhost | it must be `listen 127.0.0.1:80;` |
| `snmpwalk` times out from the workstation | `agentaddress` still set to a public address, or the agent is off | set `127.0.0.1`, restart `snmpd` |
| `ssh root@...` succeeds | `PermitRootLogin` was not written | re-run the `sed`, `sshd -T \| grep permitrootlogin` |
| VM unreachable from the workstation | wrong adapter selected | Adapter 1 host-only, `192.168.56.0/24`; check the guest got `.17` |
