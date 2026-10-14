---
name: repairing-eol-apt-archives
description: >-
  Repairs apt on end-of-life Debian or Ubuntu when current mirrors return 404
  by switching those suites to archive.debian.org or old-releases.ubuntu.com,
  disabling Check-Valid-Until, and setting trusted=yes only after archived
  signing keys fail. Use when apt-get update fails on an old Linux guest,
  Release files are expired, EXPKEYSIG or NO_PUBKEY appears for an archived
  suite, or the user mentions archive.debian.org, old-releases.ubuntu.com,
  Check-Valid-Until, or trusted=yes. Confirms update and a simulated install
  exit 0.
---

# Repair apt on an archived Debian or Ubuntu release

## When to use

`apt-get update` on an owned old Debian or Ubuntu guest fails because the release has left the active mirrors, the Release file is outside its validity window, or the archive signing key is expired.

Run `recovering-linux-admin-offline` first when there is no root shell. After apt works, continue with `inventorying-linux-vm`. Image builds in `building-docker-vm-replica` use this same repair when the base image's suite is archived.

## Related skills

`importing-ova-nat-network`, `recovering-linux-admin-offline`, `inventorying-linux-vm`, `building-docker-vm-replica`, `evaluating-docker-vm-parity`

## Prerequisites

- A root shell on the guest, or a root shell inside the image build.
- `/etc/os-release` shows `ID=debian` or `ID=ubuntu`.
- A copy of the current apt source files can be saved before editing.

## Why this is enough

Archived releases are served from `archive.debian.org` or `old-releases.ubuntu.com`. Their Release files are older than apt's validity window, and the keys that signed them can be past their expiry date. Point the existing suites at the archive host, ignore that date check, and trust only those archived lines when the signature check fails.

## Procedure

Copy this checklist and update it as you go:

```
Apt repair progress:
- [ ] Failure captured from the current mirrors
- [ ] Source files backed up
- [ ] Hosts rewritten, suite names kept
- [ ] Check-Valid-Until disabled
- [ ] trusted=yes added only after a signature failure
- [ ] apt-get update exits 0
- [ ] apt-get install -s exits 0
```

1. Confirm the failure before editing:

```
apt-get update
```

If that command exits 0, stop and leave the sources unchanged.

2. Save the current configuration:

```
cp -a /etc/apt/sources.list /etc/apt/sources.list.pre-archive
cp -a /etc/apt/sources.list.d /etc/apt/sources.list.d.pre-archive
```

Read `ID` and `VERSION_CODENAME` from `/etc/os-release`.

3. Rewrite hosts and keep every distribution and component field as it is.

Debian:

- Lines that use `security.debian.org`, or a path under `/debian-security`, use host `archive.debian.org` and path `/debian-security`.
- Other Debian lines use host `archive.debian.org` and path `/debian`.
- Replace hosts such as `deb.debian.org`, `ftp.debian.org`, and `httpredir.debian.org`.

Ubuntu:

- Replace `archive.ubuntu.com`, `security.ubuntu.com`, and other `*.ubuntu.com` archive hosts with `old-releases.ubuntu.com`.
- Keep the path `/ubuntu` and the existing pocket names.
- If `old-releases.ubuntu.com` returns 404 for that suite while `archive.ubuntu.com` still serves it, put the lines back on `archive.ubuntu.com` and `security.ubuntu.com`. A suite can remain on the active archive after its standard support window. Do not leave it on old-releases once that host has no Release file.

4. Disable the validity-time check for this archived suite:

```
printf 'Acquire::Check-Valid-Until "false";\n' > /etc/apt/apt.conf.d/99archive
```

5. Run `apt-get update` again. If it still reports `EXPKEYSIG`, an expired Release signature, or `NO_PUBKEY` for these archived lines, add `[trusted=yes]` to those `deb` lines only:

```
# Debian — only the archived lines that failed the signature check
deb [trusted=yes] http://archive.debian.org/debian <CODENAME> <COMPONENTS>
# Ubuntu — only the archived lines that failed the signature check
deb [trusted=yes] http://old-releases.ubuntu.com/ubuntu <CODENAME> <COMPONENTS>
```

Add `trusted=yes` only on the archived lines that failed the signature check. Leave a suite that is still on the active mirrors unchanged.

On Debian 8, apt can say `The following packages cannot be authenticated` and then refuse `-y` unless `--force-yes` is also set. That is the same signature failure. Add `[trusted=yes]` on the archived lines. Jessie's apt may still need `--force-yes` on the install command.

On Debian 8-era apt, `trusted=yes` can be ignored and a replacement for `/usr/bin/gpgv` can still fail with "Good signature but could not determine key fingerprint" when the replacement is `/bin/true`. If that message appears, point `Dir::Bin::gpg` at a shell stub that writes `GOODSIG` and `VALIDSIG` to the requested `--status-fd` and exits 0. Use that stub only for this archived suite.

6. Run `apt-get update` again. Then simulate an install of a package the index should already contain:

```
apt-get install -s -y bash
```

## Verification

Both `apt-get update` and `apt-get install -s -y bash` exit 0. The simulated install resolves a candidate version. Record in the work notes that the guest now uses archive mirrors, because `evaluating-docker-vm-parity` treats that as an explicit gap.

## Stop conditions

- `apt-get update` already exits 0.
- `os-release` is not Debian or Ubuntu.
- The rewritten URLs still return 404. Restore the backup and report the failing URL.
- A signature error remains after `trusted=yes` on the archived lines only.
- The change would trust a repository that is still a current supported mirror.

A Debian image can already contain a security revision of `perl-base` that archive `main` does not. Add that suite's updates and `debian-security` lines from `archive.debian.org` before installing. Do not add `trusted=yes` unless the signature check still fails. Debian 10 on that archive keeps the security suite at `buster/updates`, not `buster-security`. Debian 9 keeps it at `stretch/updates`.
