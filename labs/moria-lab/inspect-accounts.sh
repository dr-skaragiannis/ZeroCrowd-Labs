#!/bin/bash
set -eu
echo USERS
awk -F: '$3==0 || $3>=1000 {print $1, $3, $4, $6, $7}' /mnt/moria/etc/passwd
echo GROUPS
getent -f /mnt/moria/etc/group wheel sudo 2>/dev/null || true
grep -E '^(wheel|sudo):' /mnt/moria/etc/group || true
echo SSHD
grep -E '^(PermitRootLogin|PasswordAuthentication|#PermitRootLogin|#PasswordAuthentication)' /mnt/moria/etc/ssh/sshd_config || true
echo SUDO
ls /mnt/moria/etc/sudoers.d || true
grep -n wheel /mnt/moria/etc/sudoers | head
