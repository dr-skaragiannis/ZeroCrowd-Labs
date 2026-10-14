# Replica parity

Replica status: built

Container `matrix`, image `matrix-lab`, address `172.31.11.10`, memory cap 384m. Ports 80, 22, and 31337 are published on `10.88.10.12`. The guest did not boot. VirtualBox left machine `Matrix` locked after a hung settings read, and that lock was not cleared without restarting the service that also runs the other guests. Listener facts for the guest come from `rc.local` and `sshd_config`.

| Area | VM | Replica | Status | Gap |
| --- | --- | --- | --- | --- |
| Listening ports | sshd 0.0.0.0:22, python 0.0.0.0:80, python 0.0.0.0:31337, from startup files | sshd *:22, python *:80, python *:31337, from `ss` | partial | Live `ss` on the guest was not collected |
| Localhost-only services unpublished | the three listeners above are not loopback | Compose publishes only 10.88.10.12:80, :22, and :31337 | pass | |
| Package versions | Slackware openssh 7.7p1, sudo 1.8.22, python 2.7.14 | Python interpreter 2.7.14. Debian packages openssh 1:6.7p1-5+deb8u8, sudo 1.8.10p3-1+deb8u7, python2.7 2.7.9-2+deb8u1 | partial | Slackware package strings are not reproduced |
| Users | root, guest 1000 rbash, trinity 1001, bloodraven 1002 | same uids, gids, homes, and shells | pass | |
| Sudoers | bloodraven ALL, wheel commented, drop-ins included | `visudo -c` parsed OK, including `/etc/sudoers.d/bloodraven` | pass | |
| Vhosts | no named vhost; directories `/tmp/server/80` and `/tmp/server/31337` | the same two directories | pass | |
| Web paths | startup serves those directories | `http://10.88.10.12/` and `http://10.88.10.12:31337/` returned 200 | pass | |
| Databases | none | none | pass | |
| Cron | no user crontab and no `rc.crond` | no cron daemon | pass | |
| Mail | no port 25 listener | no port 25 listener | pass | |
| Application URL | the two HTTP roots above | both URLs returned 200 | pass | |

## Explicit gaps
- Version substitution: Debian Jessie packages for SSH and sudo, in place of Slackware 7.7p1 and 1.8.22. The `python` command is 2.7.14.
- Archive apt: yes. Jessie has left `deb.debian.org`. The image uses `archive.debian.org` with `Check-Valid-Until` false and `trusted=yes`. Jessie apt also required `--force-yes`.
- Second kernel: no, container shares the host kernel. WSL kernel 6.18.54.1-microsoft-standard-WSL2. The guest kernel was not collected.
- Other: supervisord in place of Slackware sysv init. Memory cap 384m, guest allocation 512 MB. A Windows route to 10.88.10.12 was not added because that command requires elevation. The address answers from the WSL engine host.
