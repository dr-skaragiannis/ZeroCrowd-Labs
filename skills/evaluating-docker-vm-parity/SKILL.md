---
name: evaluating-docker-vm-parity
description: >-
  Scores a Docker Compose replica against the original Linux VM as pass,
  partial, or missing. Use when the user asks how complete a container
  replica is, wants a parity checklist versus the VM, or asks to compare
  listening ports, package versions, users, sudoers, vhosts, web paths,
  databases, cron, and whether localhost-only services stayed unpublished.
  Records gaps such as MariaDB substituted for MySQL, archive apt, and no
  second kernel. Fidelity only; no exploit writeup.
---

# Evaluate a Docker replica against the VM

## When to use

A VirtualBox guest and a Docker Compose replica of that guest both exist, or the replica attempt finished with status not built. The operator wants a fidelity checklist, not a vulnerability writeup.

Collect VM facts with `inventorying-linux-vm` when `<WORK_DIR>/vm-inventory.md` is missing. Build or rebuild with `building-docker-vm-replica`. Apt and login gaps refer back to `repairing-eol-apt-archives` and `recovering-linux-admin-offline`.

## Related skills

`importing-ova-nat-network`, `recovering-linux-admin-offline`, `repairing-eol-apt-archives`, `inventorying-linux-vm`, `building-docker-vm-replica`

## Prerequisites

- `<WORK_DIR>/vm-inventory.md` from the original guest.
- Either a running replica or an explicit **not built** / **not running** result from `building-docker-vm-replica`.
- `docker inspect` and `docker exec` against the replica when it is running.

Compare behavior and configuration. If a version is old or vulnerable, record the version strings only. Do not add an exploit, payload, or attack procedure.

Completeness for a challenge replica is this checklist, not a public writeup and not an attack chain. Do not install an offensive distribution to score the replica. Do not search for or follow a challenge writeup. If a check would require an exploit, record the package version and stop that line.

Also request the published web URL and the application URL. A database-connection error, or a redirect off the published port, is a replica defect to fix with `building-docker-vm-replica`. It is not a reason to attack the service.

## Procedure

Copy this checklist and update it as you go:

```
Parity progress:
- [ ] Inventory loaded
- [ ] Replica runtime state recorded, or not-built recorded
- [ ] Each row scored pass, partial, or missing
- [ ] Explicit gaps listed
- [ ] Localhost-only services checked
```

1. Read the inventory sections: listeners, users, sudoers, service packages, web, databases, cron, mail.

2. If the replica was not built or is not running, score every runtime row `missing`, set the gaps list to the builder's blocker, and stop. Do not infer ports or packages from the Dockerfile.

3. On a running replica, collect the same facts:

```
docker compose -f "<WORK_DIR>/replica/compose.yaml" ps
docker inspect "<CONTAINER>"
docker exec "<CONTAINER>" ss -lntup
docker exec "<CONTAINER>" dpkg-query -W -f='${Package}\t${Version}\n'
```

Also read `/etc/passwd`, sudoers, web vhost files, database schema list, and cron from inside the container. On rpm images, use `rpm -q`.

4. Score each row:

- `pass`: the same listener, account, rule, path, schema, schedule, or package version string is present with the same practical result. A dedicated local IP that the operator requested, on the guest's port numbers, is a pass for those published ports. Archive apt, or a CentOS vault mirror, alone does not make the package row partial when the version strings match. On rpm guests, compare `rpm -q` output, not `dpkg-query`. A guest with no database is a pass on the database row when the replica also has none.
- `partial`: the item exists with a stated substitution (different package version, MariaDB where the guest ran MySQL, web on a different port, a missing listener such as `rpc.statd`).
- `missing`: the item is absent, or a localhost-only guest service was published on the host.

Do not mark a row pass while the substitution is still there. Close it in the replica, then rescore. The host kernel cannot be made to match; leave that in explicit gaps and do not invent a pass row for it. Supervisor in place of the guest init, and archive apt, stay in explicit gaps even when the checklist rows pass.

Score mail from `ss`, not from supervisor status. A forking `sendmail -bd` shows stopped while a child may already be listening, and a foreground `sendmail -bD` shows running during the startup sleep before ports 25 and 587 open. That sleep is about a minute on Sendmail 8.14; check the listeners after it. The mail row is pass only when those listeners match and the package version string matches.

5. Write `<WORK_DIR>/replica-parity.md` using the template. Fill the gaps section even when it is short. Always record these facts when they are true:

- The container uses the host kernel, so the guest kernel is not reproduced.
- Archive mirrors, `trusted=yes`, or a CentOS vault mirror were required.
- The database engine or version differs from the guest. Omit this line when they match.
- A process supervisor replaced the guest's init system.
- Memory is capped below the VM allocation. A cap equal to the guest allocation is not a gap.
- Published host ports are loopback-only.

## Report template

```markdown
# Replica parity

Replica status: built | not built | not running

| Area | VM | Replica | Status | Gap |
| --- | --- | --- | --- | --- |
| Listening ports | | | pass/partial/missing | |
| Localhost-only services unpublished | | | pass/partial/missing | |
| Package versions | | | pass/partial/missing | |
| Users | | | pass/partial/missing | |
| Sudoers | | | pass/partial/missing | |
| Vhosts | | | pass/partial/missing | |
| Web paths | | | pass/partial/missing | |
| Databases | | | pass/partial/missing | |
| Cron | | | pass/partial/missing | |
| Mail | | | pass/partial/missing | |
| Application URL | | | pass/partial/missing | |

## Explicit gaps
- Version substitution: <engine or distro, or "none">
- Archive apt: yes | no
- Second kernel: no, container shares the host kernel
- Other: <init, memory, bind address, or "none">
```

## Example scoring

VM listens on `0.0.0.0:80` and `127.0.0.1:3306`. The replica publishes `127.0.0.1:8080->80` and does not publish `3306`. Port row: `partial` (HTTP remains, host exposure reduced). Localhost-only row: `pass`. Database engine MySQL on the VM and MariaDB in the replica: database row `partial`, and the gaps list names that substitution.

## Verification

- Every template row has one of `pass`, `partial`, or `missing`.
- Every `partial` or `missing` has a gap note.
- The localhost-only row is `pass` only when those guest binds are absent from `docker compose ps` ports.
- The report contains no exploit steps and no secret, hash, or flag values.

## Stop conditions

- The inventory is missing. Run `inventorying-linux-vm` first.
- The replica status is unknown. Re-check `docker compose ps` rather than guessing.
- Scoring would require attacking a service. Record the version and stop that line of inquiry.
