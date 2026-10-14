# raven-lab

raven-lab is a local boot-to-root style lab. An owned VulnHub-style Linux appliance was imported into VirtualBox on the NAT Network `NatNetwork`, then replicated as a lower-resource Docker Compose container so the replica keeps the guest's configuration. This README is the basis for designing later scenarios of the same kind.

Facts below come from `vm-inventory.md`, `replica-parity.md` (compared 13 Oct 2026), and `docker-compose.yml`. Passwords, hashes, flags, and shadow fields are omitted.

## What this project is

The guest is a self-contained Debian 8 (Jessie) appliance. The parity report records it as Debian 8.11, kernel `3.16.0-6-amd64`, with 512 MB of memory and its NIC on a NAT Network. The replica is one container, `raven`, image `raven-lab`, with the same memory cap.

The conversion is staged: import the appliance, recover local administration, repair end-of-life apt, inventory the guest, build one container, and score that container against the inventory. `paper/Introduction-Problem.md` states the success definition used here. The Dockerfile records the settings that were chosen. The parity report records which of those settings still match the guest, and which gaps must stay visible.

## The idea

A boot-to-root style lab, in this project, means a self-contained guest with intentional old services, local accounts, and a web application. The replica is scored by whether it matches that guest.

Completeness is the parity checklist. Each row is `pass`, `partial`, or `missing`. A public writeup is not the score, and an attack chain is not the success condition. The rows cover listeners, package version strings, users, sudoers, virtual hosts, web paths, the application database, cron, mail, and the application URL.

Three facts stay visible even when those rows pass: archive or snapshot apt was required, the container shares the host kernel, and a process supervisor replaced the guest init system. A newer base image that installs and answers HTTP while substituting another Debian release or another database is a failed score on the version row.

## Services on this appliance

These services are present on the guest and marked `pass` on the replica.

| Service | Where it listens | Debian 8 package version |
| --- | --- | --- |
| Apache | port 80; vhost `raven.local`; document root `/var/www/html`; site file `/etc/apache2/sites-enabled/000-default.conf` | `2.4.10-10+deb8u12` |
| PHP | used by the web tree | `5.6.36+dfsg-0+deb8u1` |
| WordPress | base URL `http://raven.local/wordpress`; schema `wordpress` on MySQL at `localhost` | application tree under `/var/www/html` |
| MySQL 5.5 | `127.0.0.1:3306` only | `5.5.60-0+deb8u1` |
| OpenSSH | port 22 | `1:6.7p1-5+deb8u4` |
| Sendmail | `127.0.0.1:25` and `127.0.0.1:587` | `8.14.4-8+deb8u2` |
| cron | guest crontab plus `/etc/cron.d` entries `php5` and `sendmail` | `3.0pl1-127+deb8u1` |
| rpcbind | port 111, not loopback-only | listed as a listener; no package version in the parity report |
| rpc.statd | a high port, not loopback-only | listed as a listener; no package version in the parity report |

sudo is `1.8.10p3-1+deb8u5`. Local accounts are named only by the roles already in the inventory: `root`, `michael`, `steven`, and `bloodraven`. Sudo rules exist. This document does not quote them.

The application database dump used for the replica is `import/wordpress.sql`. The homepage and `/wordpress/` return HTTP 200 on the replica.

## How the replica is reached

Web and SSH are published on `10.88.10.10` ports 80 and 22. The application hostname is `raven.local`. Inside the container that name resolves to `127.0.0.1`. Compose sets the container hostname to `raven`.

The container address is `172.30.10.10` on the bridge `raven-net` (`172.30.10.0/24`, gateway `172.30.10.1`). The memory cap is `512m`. MySQL and mail stay on loopback and are not published. A volume holds `/var/lib/mysql`.

## Gaps a new scenario must keep honest

Every parity row in the current report is `pass`. Version substitution is none: the replica keeps Debian 8 and MySQL 5.5. These gaps are still true, and a later scenario has to leave them visible:

- **Archive and snapshot apt.** Packages come from `snapshot.debian.org` and `archive.debian.org`, with `trusted=yes`.
- **No second kernel.** The container shares the WSL kernel (`6.18.40.1`) rather than the guest kernel `3.16.0-6-amd64`.
- **supervisord instead of sysv init.** Process supervision is not the guest's init system.

## Six-skill procedure

The same conversion is meant to be repeated on another owned OVA. The chat that produced this replica does not travel with the next appliance. The procedure is six skills, in this order:

1. **Import onto an existing NAT network.** Import one owned OVA or OVF into VirtualBox, set the VM name, and attach only that VM's NICs to a NAT Network that already exists. Leave every unrelated VM unchanged.
2. **Offline admin recovery.** When the guest login password is unknown, recover local root and sudo on that owned appliance by editing the guest filesystem offline, then confirm a local login. This step is administration of a machine you already own.
3. **End-of-life apt repair.** When current mirrors return 404 for an archived Debian or Ubuntu suite, point apt at the archive or old-releases host for that suite and confirm that update and a simulated install succeed.
4. **Inventory, with secrets redacted.** Record listeners, human users by role, the fact that sudo rules exist, service package versions, web roots and vhosts, the application database name and host, cron, and mail. Omit passwords, hashes, flags, and shadow fields.
5. **One Docker container when the database is local.** If the database listens on localhost, build a single container. Publish only the services that were not loopback-only. Keep a fixed container address, a memory cap, and localhost-only services unpublished.
6. **Parity evaluation.** Score each checklist row `pass`, `partial`, or `missing` against the inventory. Archive or snapshot apt, the shared kernel, and the supervisor substitution stay in the gap list when they are true.

## Designing a new scenario

Write the new scenario as a guest description and a parity contract. Fill in these six decisions before any container is built.

1. **Guest story.** Name the owned appliance, the operating system and point release, the kernel, the memory size, and the NAT Network it will use. State that the guest is self-contained: old services, local accounts, and one web application. Keep the story at the level of what is installed and what is supposed to match.
2. **Services that listen.** List every listener that should exist, with protocol, address, port, and process. Include network services that are easy to forget, such as rpcbind, when the inventory shows them.
3. **Loopback-only services.** Say which listeners must stay on `127.0.0.1` and must stay off the published port list. On this lab that set is MySQL and Sendmail. A new scenario chooses its own set and then refuses to publish it.
4. **Application URL.** Give the vhost name, the document root, and the base URL operators will request. On this lab that is `raven.local`, `/var/www/html`, and `http://raven.local/wordpress`.
5. **Parity rows.** The report has to prove, each as `pass`, `partial`, or `missing`: listening ports; localhost-only services unpublished; package version strings with no silent substitution; users and the existence of sudo rules; vhosts; web paths and HTTP status of the application URL; database engine, version, schema, and host; cron; mail. A row passes only when the replica matches the inventory.
6. **Gaps that stay visible.** Require the report to say whether apt is archive or snapshot, whether a second kernel is absent, and whether supervisord stands in for sysv init. Those three do not become `pass` by being explained.

Scenario documents stop at that contract. They do not include exploit steps, payloads, credentials, flag locations, or an attack chain.

## Records

| Record | Role |
| --- | --- |
| `vm-inventory.md` | Guest facts, already redacted |
| `replica-parity.md` | Current pass/gap score |
| `docker-compose.yml` | Published addresses, container address, memory cap |
| `paper/Introduction-Problem.md` | Why the score is configuration parity |
