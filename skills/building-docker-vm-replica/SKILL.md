---
name: building-docker-vm-replica
description: >-
  Builds a lower-resource Docker Compose replica of an owned Linux VM: one
  container when the database is on localhost, web and SSH published only on
  127.0.0.1, a fixed IPv4 on a dedicated bridge, users restored with
  chpasswd -e, sudo rules preserved, a process supervisor, a memory cap, and
  an entrypoint that initializes the application database once. Use when
  the user asks to containerize a Linux appliance, write a Docker Compose
  replica of a VM, or shrink a
  VirtualBox guest into Docker. Says when Docker or WSL is missing and never
  claims the image was built unless it was.
---

# Build a Docker Compose replica of a Linux VM

## When to use

`<WORK_DIR>/vm-inventory.md` from `inventorying-linux-vm` exists and the operator wants a smaller local replica of that guest. Use `repairing-eol-apt-archives` inside the image build when the chosen suite returns apt 404s. Finish with `evaluating-docker-vm-parity`.

## Related skills

`importing-ova-nat-network`, `recovering-linux-admin-offline`, `repairing-eol-apt-archives`, `inventorying-linux-vm`, `evaluating-docker-vm-parity`

## Prerequisites

- An inventory with listeners, users, sudoers, web root, database fields, and an application SQL dump.
- A local shadow extract of the accounts to recreate, mode `600`, never printed.
- The database host field is `localhost`, `127.0.0.1`, or a local socket, and the web server and database lived on the same guest. That layout is one container. If the inventory shows a database on another host, stop and ask before adding containers.
- Docker may be absent. Confirm it before describing any build result.

## Procedure

Copy this checklist and update it as you go:

```
Replica progress:
- [ ] Docker daemon reachable, or blocker reported
- [ ] One service chosen for a localhost database
- [ ] Subnet free
- [ ] Image definition written
- [ ] Image built
- [ ] Compose up and health checks passed
```

1. Check Docker. Run `docker info` and `docker compose version`.

If the client is missing, or the daemon is not reachable, the replica status is **not built**. Report the operator action below and stop. Files drafted on disk are not a built image:

- On Windows, `wsl -l -v` shows whether a Linux environment exists. Installing it is `wsl --install` from an elevated shell, followed by a reboot. Docker Desktop also needs an elevated install and a running engine afterward.
- Do not bypass the elevation prompt. After reboot, start again at `docker info`.
- Write "not built" in the final report. A Dockerfile on disk is not a built image.

2. Choose resources from the inventory. Set `<MEM_LIMIT>` below the VM's RAM (512m is a reasonable default when the guest is larger). Pick `<SUBNET>` (default `172.28.0.0/24`) and `<CONTAINER_IP>` (default `172.28.0.10`) only after `docker network ls` and inspect show no overlap.

3. Place the build context in `<WORK_DIR>/replica/`: `app.sql`, a gitignored `shadow-users.txt` of `username:<SHADOW_FIELD>` lines, the sudoers drop-ins, and a copy of the web root. Preserve ownership uids from the inventory.

```
mkdir -p "<WORK_DIR>/replica/webroot"
tar -C "<WEB_ROOT>" -cf - . | tar -C "<WORK_DIR>/replica/webroot" -xf -
```

4. Write a Dockerfile that installs only the services that were listening, plus a process supervisor. For a pass on package versions, start from the guest distribution and release, and install the inventory package names (`mysql-server`, not MariaDB, when the guest ran MySQL). A newer official language image (for example `php:5.6-apache` on the next Debian release) or a newer point release of the same major (for example `centos:7` when the guest is 7.3) is a substitution: record it as partial and do not call the package row a pass.

A live Slackware or Porteus guest has no `dpkg`. The `python` command can match the inventory interpreter while `dpkg-query` still prints the Debian package that shipped in the base image. That package row stays partial.

A JDK, Tomcat, or ntopng tree that is not a distro package is copied into the image with its documentation and shared libraries. The binary alone does not open the port. Publish the inventory SSH port even when it is not 22. Comment any other `Port` line. Appending a second `Port` makes `sshd` listen on both.

Debian or Ubuntu: when apt inside the build returns 404, follow `repairing-eol-apt-archives`. If `archive.debian.org` only has a later Debian revision than the inventory, add the `snapshot.debian.org` timestamp that still contains each inventoried revision and install that exact version (`package=version`). Those revisions are often not current on the same day, so one snapshot line per revision is normal. Ubuntu snapshots on `snapshot.ubuntu.com` start at 1 March 2023. When the oldest snapshot of a suite is already newer than an inventoried revision, that revision is not in the snapshot index. The Launchpad librarian still serves many of those debs at `https://launchpad.net/ubuntu/+archive/primary/+files/<file>`. Install those files with apt so their dependencies come from the archive. Do not call the package row a pass until `dpkg-query` matches the inventory strings.

CentOS or RHEL: `repairing-eol-apt-archives` does not apply. Point yum at `vault.centos.org/<RELEASE>/os` and `vault.centos.org/<RELEASE>/updates` for that exact release, set `gpgcheck=0` only on those vault lines, and `yum install` the inventoried `name-version` strings. `FROM centos:<MAJOR>` can ship a newer systemd than that vault, and a pinned postfix then fails on `systemd-sysv`. Use the matching point-release tag (for example `centos:7.3.1611`) instead of downgrading systemd by hand. Do not call the package row a pass until `rpm -q` matches the inventory strings. Record the vault mirror as the same kind of explicit gap as archive apt.

If the inventory has no database, still use one container. Skip the database volume, the SQL import, and any database publish. Publish every non-loopback TCP listener the inventory recorded (web, SSH, and FTP when those were listening), on `127.0.0.1` and the guest port numbers. Leave loopback listeners unpublished.

Changing the database engine requires a new data volume. Do not mount an existing MariaDB data directory into MySQL, or the reverse.

When the inventory shows `rpc.statd`, install the package that owns it (`nfs-common` on Debian) and run it in the foreground after `rpcbind`. The distro PHP package installs its `/etc/cron.d` snippet; keep that file. Keep the guest application base URL. Map that hostname to the dedicated local IP in the host `hosts` file, and inside the container map it to `127.0.0.1`, instead of rewriting the stored URL to a raw IP.

Recreate accounts from the existing hashes:

```
useradd -u <UID> -g <GID> -m -s /bin/bash <USER>
echo '<USER>:<SHADOW_FIELD>' | chpasswd -e
```

`chpasswd -e` expects the shadow field, including its algorithm prefix. Copy sudoers to `/etc/sudoers.d/` with mode `440` and run `visudo -c` during the build. Keep the database bound to `127.0.0.1` inside the container.

5. Write `compose.yaml`. Publish every non-loopback TCP listener the inventory recorded, including a high port that is not 80 or 22. Leave database, mail, and other loopback guest services unpublished.

Set `name:` to the appliance work directory. Two replicas that both keep `compose.yaml` in a folder named `replica` otherwise share one Compose project, and `docker compose down --remove-orphans` in one folder removes the other container.

Default publish address is loopback. When the operator asks for a dedicated local IP instead of localhost, or when `127.0.0.1` and the guest port are already published by another replica, assign a new address on the engine host (a /32 that is not `127.0.0.1` and not an address already used by another replica) and publish web and SSH only on that address, on the same port numbers the guest used. Do not also publish those ports on `127.0.0.1`. Do not change the guest port numbers to free a busy loopback port. On WSL, add the address before `compose up`, and repeat it from `[boot] command` in `/etc/wsl.conf` so a later start can bind. Add the guest hostname for that IP in the same boot command, because WSL regenerates `/etc/hosts`.

```yaml
services:
  appliance:
    build: .
    mem_limit: <MEM_LIMIT>
    networks:
      replica:
        ipv4_address: <CONTAINER_IP>
    ports:
      - "127.0.0.1:<HOST_WEB_PORT>:80"
      - "127.0.0.1:<HOST_SSH_PORT>:22"
networks:
  replica:
    driver: bridge
    ipam:
      config:
        - subnet: <SUBNET>
```

Add `443` only when the inventory listed it. Drop the SSH publish line when the guest had no SSH listener.

6. Supervise the long-running processes the inventory found (web server, database, SSH, cron). One program stanza per daemon, in foreground form. Example pattern:

```
[supervisord]
nodaemon=true
[program:web]
command=/usr/sbin/apachectl -D FOREGROUND
[program:db]
command=/usr/sbin/mysqld --bind-address=127.0.0.1
[program:ssh]
command=/usr/sbin/sshd -D
[program:cron]
command=/usr/sbin/cron -f
```

Omit any program the guest was not running. If a guest crontab line only starts a daemon that you already supervise, keep one supervisor program for that daemon and also install the crontab line so the schedule exists. The cron start can be later than the supervisor start; confirm the listening port after cron has run, not only in the first seconds.

CentOS 7 base images do not include supervisor. A shell entrypoint that starts each daemon in the foreground and `wait`s is acceptable. Record that shell, or supervisord, in place of systemd or sysv init as an explicit gap. Foreground forms that stay attached: `httpd -D FOREGROUND`, `sshd -D`, `crond -n`, and `vsftpd` with `background=NO`. Guest vsftpd often sets `listen=NO` and `listen_ipv6=YES`; a container without IPv6 needs `listen=YES` and `listen_ipv6=NO` or port 21 never opens. Run postfix as `/usr/libexec/postfix/master` rather than `postfix start`, which returns immediately. Chrony 2.1 has no `-x` flag and exits when `adjtimex` fails; add `CAP_SYS_TIME` and run `chronyd -d -n`. Later chrony can use `-x` instead of that capability.

Supervise sendmail with `sendmail -bD` so it stays in the foreground. `sendmail -bd` forks and the parent exits, and supervisor then marks that program stopped even if a child is still listening. Sendmail 8.14 sleeps about 60 seconds after its startup DNS lookup and syslog attempt before it binds. Shortening `Timeout.ident`, `Timeout.fileopen`, and the resolver settings does not remove that sleep, and neither does providing `/dev/log`. Keep `startsecs` short so later programs are not held for that minute, and check ports 25 and 587 after the sleep.

7. Initialize the application database once, then start the supervisor. Wait until the server accepts connections before the import. Shut it down, write the marker, then exec the supervisor so a later start does not import again.

Read the application password from the config file as text. Do not execute the config through the application runtime (`php -r 'include ...'`). A bootstrap prints extra output, and that extra text becomes the database password. Split the assignment line and take only the quoted value.

On a later start the data directory already has a password. Accept either an empty local administrator login (first boot) or a login with the parsed password. Do not set the password again from a captured command substitution.

Point the application runtime at the database socket the server actually creates. `localhost` in PHP uses a Unix socket, and the image default is often `/tmp/mysql.sock` while MariaDB creates `/var/run/mysqld/mysqld.sock`. TCP to `127.0.0.1` can succeed while the application still fails. Write a PHP conf snippet:

```
mysqli.default_socket=/var/run/mysqld/mysqld.sock
pdo_mysql.default_socket=/var/run/mysqld/mysqld.sock
mysql.default_socket=/var/run/mysqld/mysqld.sock
```

After `COPY`, `chmod 644` every file under `/etc/mysql/conf.d/`. MariaDB and MySQL ignore a world-writable client or server option file.

If the application stores a base URL, record it in the inventory. A redirect to that URL leaves the published host port when the stored URL has no port or a different host. Either publish the port the stored URL uses, or set the stored URL to the host address you publish and mark that row partial in `evaluating-docker-vm-parity`.

A `docker cp` into a running container disappears on recreate. Put the socket snippet, the password parser, and the option-file mode in the image and rebuild.

On Windows, PowerShell expands `$()` before WSL sees the command. Write the shell script to a file, strip CR (`sed -i 's/\r$//'`), and run that file. Do not generate entrypoint scripts through a PowerShell double-quoted string.

```sh
#!/bin/sh
set -eu
if [ ! -f /var/lib/replica/db.ready ]; then
  mysqld --bind-address=127.0.0.1 &
  pid=$!
  until mysqladmin ping --silent; do sleep 1; done
  mysql < /seed/app.sql
  mysqladmin shutdown
  wait "$pid"
  mkdir -p /var/lib/replica
  touch /var/lib/replica/db.ready
fi
exec supervisord -n -c /etc/supervisor/supervisord.conf
```

Use the server binary the package actually provides. Import only `<WORK_DIR>/replica/app.sql`.

8. Build and start:

```
docker compose -f "<WORK_DIR>/replica/compose.yaml" build
docker compose -f "<WORK_DIR>/replica/compose.yaml" up -d
```

## Verification

Treat each statement as true only when the command shows it:

- `docker image ls` contains the built image. Otherwise status is **not built**.
- `docker compose ps` shows the service running. Otherwise status is **not running**.
- `docker inspect` shows `HostConfig.Memory` at the cap, `IPAddress` equal to `<CONTAINER_IP>`, and port bindings only on `127.0.0.1`.
- From the host, the published web port answers and the database port does not.
- `docker exec` shows the human users, `visudo -c` succeeds, and the application schema is present after a second `compose up` (the marker blocked a second import).

## Stop conditions

- The inventory is missing.
- The database host is not local and the operator has not chosen a split.
- `docker info` fails. Report the elevated install or reboot step. Status: **not built**.
- The image build fails. Status: **not built**. Include the last error. Do not describe a running replica.
- A loopback-only guest service was published on the host. Remove that publish and recreate.
- The operator does not own the guest data being copied into the image.

A BSD guest cannot be the image base on a Linux Docker engine. Start from a Linux image that can open the same sockets, and leave the package row partial. Keep a listener unpublished when its config bind is `127.0.0.1`. Debian net-snmp opens TCP 199 in addition to the configured UDP agent address unless the command includes `-I -smux`.

An nginx process started with `-c` needs a complete configuration. A file that contains only a `server` block is rejected. When a packaged daemon calls `capset` for `CAP_DAC_READ_SEARCH` and `CAP_SYS_NICE` and the default Docker set lacks them, the process can exit 252 and write its message to stdin, so `docker logs` stays empty. Add those two capabilities. On the Debian `pure-ftpd` package, `-B` backgrounds the process; leave it off when that binary is PID 1. Docker Engine 17 can show an empty `GraphDriver.UpperDir` while the layer files are under `overlay2`. Read published ports from `hostconfig.json`. Do not copy that graph into the image.
