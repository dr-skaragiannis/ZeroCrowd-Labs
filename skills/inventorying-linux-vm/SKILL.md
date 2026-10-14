---
name: inventorying-linux-vm
description: >-
  Inventories an owned Linux VM before containerization: listening ports,
  human users, sudoers, service package versions, web roots, vhosts,
  application database name/user/host, a logical dump of application
  databases only, cron, mail, and directory sizes. Use when the user asks
  what a Linux appliance runs, wants a service inventory for a Docker
  replica, or asks to list listeners, sudo rules, vhosts, crontabs, or
  databases with ss or netstat. Redacts secrets, hashes, and flags.
---

# Inventory a Linux VM for containerization

## When to use

An owned Linux guest is running and an admin shell is available. The next goal is a Docker replica (`building-docker-vm-replica`) or a parity review (`evaluating-docker-vm-parity`).

Use `recovering-linux-admin-offline` when there is no admin login. Use `repairing-eol-apt-archives` when a missing inventory tool must be installed and apt fails with 404s.

## Related skills

`importing-ova-nat-network`, `recovering-linux-admin-offline`, `repairing-eol-apt-archives`, `building-docker-vm-replica`, `evaluating-docker-vm-parity`

## Prerequisites

- Root or sudo on the guest.
- `<WORK_DIR>` on the host (or a directory on the guest that can be copied off) for the inventory and dumps.
- Permission to export application data from this appliance.

Write secrets only into local working files the replica build needs. In the inventory document and in chat, record database name, user, and host, and replace password, key, hash, and flag values with `<redacted>`.

## Procedure

Copy this checklist and update it as you go:

```
Inventory progress:
- [ ] Listeners classified
- [ ] Human users and sudoers copied
- [ ] Service package versions recorded
- [ ] Web roots and vhosts recorded
- [ ] App database fields recorded, secrets redacted
- [ ] App databases dumped, system schemas skipped
- [ ] Cron and mail recorded
- [ ] Directory sizes recorded
```

1. Listeners. Prefer `ss`. Use `netstat` when `ss` is absent.

```
ss -lntup || netstat -lntup
```

For each row record protocol, bind address, port, and process. Mark the bind as loopback when it is `127.0.0.1` or `::1`. Mark every other address as non-loopback.

2. Human accounts and sudo. List uid 0 and uids at or above 1000 whose shell is interactive, plus membership of `sudo` or `wheel`:

```
awk -F: '($3==0 || $3>=1000) && $7 !~ /(nologin|false)$/ {print $1, $3, $6, $7}' /etc/passwd
getent group sudo wheel
```

Copy `/etc/sudoers` and `/etc/sudoers.d/*` into the inventory. Also record uid, gid, home, and shell for service accounts that own application files (`www-data`, the database user, and similar). Store a local shadow extract for later `chpasswd -e` use under `<WORK_DIR>` with mode `600`. Do not print that file.

3. Service packages. Map each listener's binary to a package and record name and version:

```
dpkg-query -W -f='${Package}\t${Version}\n' <PACKAGE>
```

On rpm systems use `rpm -q <PACKAGE>`. Cover the web server, database, PHP or other app runtime, SSH, cron, and mail packages that are actually installed.

4. Web roots and vhosts. Record `DocumentRoot` and server names from the active site files:

```
apachectl -S
nginx -T
```

List the real path of each web root. Note which config files exist. For application config, copy only these fields into the inventory: database name, database user, database host, and database port. Write `password: <redacted>` when a password field exists.

5. Databases. List schemas, then dump only application databases. Skip `mysql`, `information_schema`, `performance_schema`, and `sys`.

```
mysql --batch --skip-column-names -e 'SHOW DATABASES;'
mysqldump --single-transaction --routines --databases <APP_DB> > "<WORK_DIR>/app.sql"
```

Repeat `--databases` for each application schema. Use the local admin socket. If a second engine is installed (PostgreSQL or SQLite), list its application databases the same way and dump those with that engine's logical dump tool. Do not dump database system catalogs.

6. Cron and mail.

```
ls -la /etc/crontab /etc/cron.d /etc/cron.daily /etc/cron.hourly /var/spool/cron 2>/dev/null
awk -F: '{print $1}' /etc/passwd | while read -r u; do crontab -u "$u" -l; done
systemctl list-timers --all
```

Record mail packages, whether port 25 is listening, and whether `/var/mail` has local mail. Redact relay passwords if a mail config printout includes them.

7. Directory sizes, to decide what the replica copies:

```
du -xhd1 /var /home /opt /srv /usr/share
```

8. Write `<WORK_DIR>/vm-inventory.md` with the sections below. Keep the raw SQL, web-root archive, and shadow extract beside it, outside any public commit. If `<WORK_DIR>` is inside a git checkout, gitignore it before those files are written.

## Inventory template

```markdown
# VM inventory

## OS
ID, VERSION_ID, VERSION_CODENAME, kernel

## Listeners
| proto | address | port | process | loopback |

## Users
| name | uid | gid | home | shell | admin |

## Sudoers
verbatim rules, secrets redacted

## Service packages
| package | version |

## Web
vhost, server name, document root, config path
database name, user, host, port
password: <redacted>
application base URL (siteurl or equivalent), with no secrets

## Databases
application schema names and dump path

## Cron
schedule, user, command

## Mail
package, listener, local mail present

## Sizes
path and du output
```

## Verification

- Every listener has a loopback or non-loopback mark.
- Every interactive human user appears in the users table.
- `app.sql` restores as a logical dump and contains no `mysql` system schema.
- The inventory document contains no password, key, hash, or flag value.
- Web and database facts are sufficient for `building-docker-vm-replica` to choose one container when the database host is localhost.

## Stop conditions

- There is no admin shell.
- The database server is up but the admin socket cannot list schemas. Report that auth blocked the dump; do not hunt for credentials to publish.
- A dump includes system schemas. Delete it and dump only application databases.
- The operator does not own the guest.

The WSL kernel has no UFS. `mount -t ufs` failing does not mean the slice is empty. Read an OpenBSD FFS slice with Sleuth Kit `fsstat`, `fls`, and `icat`. A disklabel slice can show up twice; use the one whose last mount point is `/`. Do not copy password hashes, community strings, or flag files into the inventory.

Docker Engine 17 can leave `GraphDriver.UpperDir` empty in `config.v2.json` while the layer files are under `/var/lib/docker/overlay2`. Read published host ports from each container's `hostconfig.json` `PortBindings`, and exposed-but-unpublished ports from `Config.ExposedPorts`. Do not print image environment values, and do not copy the graph into the replica.
